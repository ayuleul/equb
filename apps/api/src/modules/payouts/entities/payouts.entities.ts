import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { PayoutStatus } from '@prisma/client';

export class PayoutUserResponseDto {
  @ApiProperty()
  id!: string;

  @ApiPropertyOptional({ nullable: true })
  fullName!: string | null;

  @ApiProperty()
  phone!: string;
}

export class PayoutResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  groupId!: string;

  @ApiProperty()
  cycleId!: string;

  @ApiProperty()
  toUserId!: string;

  @ApiProperty()
  amount!: number;

  @ApiProperty({ enum: PayoutStatus })
  status!: PayoutStatus;

  @ApiPropertyOptional({ nullable: true })
  proofFileKey!: string | null;

  @ApiPropertyOptional({ nullable: true })
  paymentRef!: string | null;

  @ApiPropertyOptional({ nullable: true })
  note!: string | null;

  @ApiProperty()
  createdByUserId!: string;

  @ApiProperty()
  createdAt!: Date;

  @ApiPropertyOptional({ nullable: true })
  confirmedByUserId!: string | null;

  @ApiPropertyOptional({ nullable: true })
  confirmedAt!: Date | null;

  @ApiProperty({ type: () => PayoutUserResponseDto })
  toUser!: PayoutUserResponseDto;
}
