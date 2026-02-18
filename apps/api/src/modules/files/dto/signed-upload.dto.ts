import { ApiProperty } from '@nestjs/swagger';
import { IsEnum, IsNotEmpty, IsString, IsUUID } from 'class-validator';

export enum UploadPurpose {
  CONTRIBUTION_PROOF = 'contribution_proof',
  PAYOUT_PROOF = 'payout_proof',
}

export class SignedUploadDto {
  @ApiProperty({
    enum: UploadPurpose,
    example: UploadPurpose.CONTRIBUTION_PROOF,
  })
  @IsEnum(UploadPurpose)
  purpose!: UploadPurpose;

  @ApiProperty({ format: 'uuid' })
  @IsUUID()
  groupId!: string;

  @ApiProperty({ format: 'uuid' })
  @IsUUID()
  cycleId!: string;

  @ApiProperty({ example: 'image/jpeg' })
  @IsString()
  @IsNotEmpty()
  contentType!: string;

  @ApiProperty({ example: 'proof.jpg' })
  @IsString()
  @IsNotEmpty()
  fileName!: string;
}
