import { Body, Controller, Get, Post, Query, UseGuards } from '@nestjs/common';
import {
  ApiBadRequestResponse,
  ApiBearerAuth,
  ApiBody,
  ApiForbiddenResponse,
  ApiNotFoundResponse,
  ApiOkResponse,
  ApiOperation,
  ApiQuery,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';

import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import type { AuthenticatedUser } from '../../common/types/authenticated-user.type';
import { SignedDownloadDto } from './dto/signed-download.dto';
import { SignedUploadDto } from './dto/signed-upload.dto';
import { FilesService } from './files.service';

@ApiTags('Files')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@ApiUnauthorizedResponse({ description: 'Missing or invalid access token' })
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
  @ApiForbiddenResponse({
    description:
      'User is not authorized to upload for this group/cycle/purpose',
  })
  @ApiBadRequestResponse({
    description: 'Invalid file metadata or unsupported upload purpose',
  })
  @ApiNotFoundResponse({ description: 'Cycle not found for group' })
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
  @ApiForbiddenResponse({
    description: 'Active membership required for key scope',
  })
  @ApiBadRequestResponse({ description: 'Invalid key format' })
  createSignedDownload(
    @CurrentUser() currentUser: AuthenticatedUser,
    @Query() query: SignedDownloadDto,
  ): Promise<{ downloadUrl: string; expiresInSeconds: number }> {
    return this.filesService.createSignedDownload(currentUser, query);
  }
}
