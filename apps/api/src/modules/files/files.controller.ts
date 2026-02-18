import { Body, Controller, Get, Post, Query, UseGuards } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiBody,
  ApiOkResponse,
  ApiOperation,
  ApiQuery,
  ApiTags,
} from '@nestjs/swagger';

import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import type { AuthenticatedUser } from '../../common/types/authenticated-user.type';
import { SignedDownloadDto } from './dto/signed-download.dto';
import { SignedUploadDto } from './dto/signed-upload.dto';
import { FilesService } from './files.service';

@ApiTags('files')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('files')
export class FilesController {
  constructor(private readonly filesService: FilesService) {}

  @Post('signed-upload')
  @ApiOperation({ summary: 'Create signed upload URL for file storage' })
  @ApiBody({ type: SignedUploadDto })
  @ApiOkResponse({
    schema: {
      type: 'object',
      properties: {
        key: { type: 'string' },
        uploadUrl: { type: 'string' },
        expiresInSeconds: { type: 'number' },
      },
    },
  })
  createSignedUpload(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Body() dto: SignedUploadDto,
  ): Promise<{ key: string; uploadUrl: string; expiresInSeconds: number }> {
    return this.filesService.createSignedUpload(currentUser, dto);
  }

  @Get('signed-download')
  @ApiOperation({ summary: 'Create signed download URL for file storage' })
  @ApiQuery({ name: 'key', required: true, type: String })
  @ApiOkResponse({
    schema: {
      type: 'object',
      properties: {
        downloadUrl: { type: 'string' },
        expiresInSeconds: { type: 'number' },
      },
    },
  })
  createSignedDownload(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Query() query: SignedDownloadDto,
  ): Promise<{ downloadUrl: string; expiresInSeconds: number }> {
    return this.filesService.createSignedDownload(currentUser, query);
  }
}
