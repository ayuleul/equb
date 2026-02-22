import { ConfigService } from '@nestjs/config';
import { Test, TestingModule } from '@nestjs/testing';
import { MemberRole, MemberStatus } from '@prisma/client';

import type { AuthenticatedUser } from '../../common/types/authenticated-user.type';
import { PrismaService } from '../../common/prisma/prisma.service';
import { FilesService } from './files.service';
import { UploadPurpose } from './dto/signed-upload.dto';

describe('FilesService', () => {
  let service: FilesService;

  const prismaMock = {
    equbCycle: {
      findUnique: jest.fn(),
    },
    equbMember: {
      findUnique: jest.fn(),
    },
  } as unknown as PrismaService;

  const configValues: Record<string, string> = {
    S3_ENDPOINT: 'http://localhost:9000',
    S3_PUBLIC_ENDPOINT: 'http://10.0.2.2:9000',
    S3_REGION: 'us-east-1',
    S3_ACCESS_KEY: 'minioadmin',
    S3_SECRET_KEY: 'minioadmin',
    S3_BUCKET: 'equb-dev',
    S3_FORCE_PATH_STYLE: 'true',
    S3_SIGNED_URL_EXPIRES_SECONDS: '900',
  };

  const configServiceMock = {
    get: (key: string): string | undefined => configValues[key],
  } as ConfigService;

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        FilesService,
        {
          provide: PrismaService,
          useValue: prismaMock,
        },
        {
          provide: ConfigService,
          useValue: configServiceMock,
        },
      ],
    }).compile();

    service = module.get<FilesService>(FilesService);
  });

  it('creates presigned upload URL without checksum query parameters', async () => {
    const user: AuthenticatedUser = {
      id: 'cmlvzvfm6000bsoe3sd05z269',
      phone: '+251900000000',
    };

    prismaMock.equbCycle.findUnique = jest.fn().mockResolvedValue({
      id: '1a0787c5-41d6-4d0a-9435-e5d7444288aa',
      groupId: '14a0b24f-41f8-4905-8cd7-a4bd76062762',
    });
    prismaMock.equbMember.findUnique = jest.fn().mockResolvedValue({
      status: MemberStatus.ACTIVE,
      role: MemberRole.MEMBER,
    });

    const result = await service.createSignedUpload(user, {
      purpose: UploadPurpose.CONTRIBUTION_PROOF,
      groupId: '14a0b24f-41f8-4905-8cd7-a4bd76062762',
      cycleId: '1a0787c5-41d6-4d0a-9435-e5d7444288aa',
      contentType: 'image/jpeg',
      fileName: 'proof photo.jpg',
    });

    const signedUrl = new URL(result.uploadUrl);
    const searchParams = signedUrl.searchParams;

    expect(searchParams.get('x-amz-sdk-checksum-algorithm')).toBeNull();
    expect(searchParams.get('x-amz-checksum-crc32')).toBeNull();
    expect(signedUrl.origin).toBe('http://10.0.2.2:9000');
    expect(result.key).toMatch(
      /^groups\/14a0b24f-41f8-4905-8cd7-a4bd76062762\/cycles\/1a0787c5-41d6-4d0a-9435-e5d7444288aa\/users\/cmlvzvfm6000bsoe3sd05z269\/[^/]+_proof_photo\.jpg$/,
    );
  });
});
