import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { MemberRole } from '@prisma/client';
import {
  GetObjectCommand,
  PutObjectCommand,
  S3Client,
} from '@aws-sdk/client-s3';
import { formatUrl } from '@aws-sdk/util-format-url';
import {
  getSignedUrl,
  S3RequestPresigner,
} from '@aws-sdk/s3-request-presigner';
import { HttpRequest } from '@smithy/protocol-http';
import { randomUUID } from 'crypto';

import { isParticipatingMemberStatus } from '../../common/membership/member-status.util';
import { PrismaService } from '../../common/prisma/prisma.service';
import type { AuthenticatedUser } from '../../common/types/authenticated-user.type';
import {
  buildContributionProofPrefix,
  buildPayoutProofPrefix,
  parseGroupScopedStorageKey,
  sanitizeFileName,
} from '../contributions/utils/proof-key.util';
import { SignedDownloadDto } from './dto/signed-download.dto';
import { SignedUploadDto, UploadPurpose } from './dto/signed-upload.dto';

@Injectable()
export class FilesService {
  private readonly s3Client: S3Client;

  constructor(
    private readonly configService: ConfigService,
    private readonly prisma: PrismaService,
  ) {
    this.s3Client = new S3Client({
      region: this.s3Region,
      endpoint: this.s3PublicEndpoint,
      forcePathStyle: this.s3ForcePathStyle,
      requestChecksumCalculation: 'WHEN_REQUIRED',
      credentials: {
        accessKeyId: this.s3AccessKey,
        secretAccessKey: this.s3SecretKey,
      },
    });
  }

  async createSignedUpload(
    currentUser: AuthenticatedUser,
    dto: SignedUploadDto,
  ): Promise<{ key: string; uploadUrl: string; expiresInSeconds: number }> {
    const cycle = await this.prisma.equbCycle.findUnique({
      where: { id: dto.cycleId },
      select: { id: true, groupId: true },
    });

    if (!cycle || cycle.groupId !== dto.groupId) {
      throw new NotFoundException('Cycle not found in the specified group');
    }

    const membership = await this.prisma.equbMember.findUnique({
      where: {
        groupId_userId: {
          groupId: dto.groupId,
          userId: currentUser.id,
        },
      },
      select: { status: true, role: true },
    });

    if (!membership || !isParticipatingMemberStatus(membership.status)) {
      throw new ForbiddenException('Joined group membership is required');
    }

    let keyPrefix = '';

    if (dto.purpose === UploadPurpose.CONTRIBUTION_PROOF) {
      keyPrefix = buildContributionProofPrefix(
        dto.groupId,
        dto.cycleId,
        currentUser.id,
      );
    }

    if (dto.purpose === UploadPurpose.PAYOUT_PROOF) {
      if (membership.role !== MemberRole.ADMIN) {
        throw new ForbiddenException(
          'Only admins can upload payout proof files',
        );
      }
      keyPrefix = buildPayoutProofPrefix(dto.groupId, dto.cycleId);
    }

    if (!keyPrefix) {
      throw new BadRequestException('Unsupported upload purpose');
    }

    const key = `${keyPrefix}${randomUUID()}_${sanitizeFileName(dto.fileName)}`;

    const command = new PutObjectCommand({
      Bucket: this.s3Bucket,
      Key: key,
      ContentType: dto.contentType,
    });

    let uploadUrl = await getSignedUrl(this.s3Client, command, {
      expiresIn: this.signedUrlExpiresInSeconds,
    });

    if (this.hasChecksumQueryParams(uploadUrl)) {
      uploadUrl = await this.createChecksumlessSignedUploadUrl(key);
    }

    return {
      key,
      uploadUrl,
      expiresInSeconds: this.signedUrlExpiresInSeconds,
    };
  }

  async createSignedDownload(
    currentUser: AuthenticatedUser,
    dto: SignedDownloadDto,
  ): Promise<{ downloadUrl: string; expiresInSeconds: number }> {
    const parsedKey = parseGroupScopedStorageKey(dto.key);

    if (!parsedKey) {
      throw new BadRequestException('Invalid file key format');
    }

    const membership = await this.prisma.equbMember.findUnique({
      where: {
        groupId_userId: {
          groupId: parsedKey.groupId,
          userId: currentUser.id,
        },
      },
      select: {
        status: true,
      },
    });

    if (!membership || !isParticipatingMemberStatus(membership.status)) {
      throw new ForbiddenException('Joined group membership is required');
    }

    const command = new GetObjectCommand({
      Bucket: this.s3Bucket,
      Key: dto.key,
    });

    const downloadUrl = await getSignedUrl(this.s3Client, command, {
      expiresIn: this.signedUrlExpiresInSeconds,
    });

    return {
      downloadUrl,
      expiresInSeconds: this.signedUrlExpiresInSeconds,
    };
  }

  private get s3Endpoint(): string {
    return this.configService.get<string>('S3_ENDPOINT') ?? 'http://minio:9000';
  }

  private get s3PublicEndpoint(): string {
    return (
      this.configService.get<string>('S3_PUBLIC_ENDPOINT') ?? this.s3Endpoint
    );
  }

  private get s3Region(): string {
    return this.configService.get<string>('S3_REGION') ?? 'us-east-1';
  }

  private get s3AccessKey(): string {
    return this.configService.get<string>('S3_ACCESS_KEY') ?? 'minioadmin';
  }

  private get s3SecretKey(): string {
    return this.configService.get<string>('S3_SECRET_KEY') ?? 'minioadmin';
  }

  private get s3Bucket(): string {
    return this.configService.get<string>('S3_BUCKET') ?? 'equb-dev';
  }

  private get s3ForcePathStyle(): boolean {
    const value =
      this.configService.get<string>('S3_FORCE_PATH_STYLE') ?? 'true';
    return value.toLowerCase() === 'true';
  }

  private get signedUrlExpiresInSeconds(): number {
    const value = Number(
      this.configService.get<string>('S3_SIGNED_URL_EXPIRES_SECONDS') ?? '900',
    );

    return Number.isFinite(value) && value > 0 ? value : 900;
  }

  private hasChecksumQueryParams(url: string): boolean {
    const params = new URL(url).searchParams;
    return (
      params.has('x-amz-sdk-checksum-algorithm') ||
      params.has('x-amz-checksum-crc32')
    );
  }

  private async createChecksumlessSignedUploadUrl(
    key: string,
  ): Promise<string> {
    const endpoint = new URL(this.s3PublicEndpoint);
    const basePath = endpoint.pathname.replace(/\/+$/, '');
    const encodedBucket = encodeURIComponent(this.s3Bucket);
    const encodedKey = key.split('/').map(encodeURIComponent).join('/');
    const path = `${basePath}/${encodedBucket}/${encodedKey}`.replace(
      /^([^/])/,
      '/$1',
    );

    const request = new HttpRequest({
      protocol: endpoint.protocol,
      hostname: endpoint.hostname,
      port: endpoint.port ? Number(endpoint.port) : undefined,
      method: 'PUT',
      path,
      headers: {
        host: endpoint.host,
      },
    });

    const presigner = new S3RequestPresigner({
      ...this.s3Client.config,
      applyChecksum: false,
    });

    const presigned = await presigner.presign(request, {
      expiresIn: this.signedUrlExpiresInSeconds,
    });

    return formatUrl(presigned);
  }
}
