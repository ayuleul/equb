import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { AuctionStatus } from '@prisma/client';

export class AuctionBidUserResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  phone!: string;

  @ApiPropertyOptional({ nullable: true })
  fullName!: string | null;
}

export class CycleBidResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  cycleId!: string;

  @ApiProperty()
  userId!: string;

  @ApiProperty()
  amount!: number;

  @ApiProperty()
  createdAt!: Date;

  @ApiProperty()
  updatedAt!: Date;

  @ApiProperty({ type: () => AuctionBidUserResponseDto })
  user!: AuctionBidUserResponseDto;
}

export class CycleAuctionStateResponseDto {
  @ApiProperty()
  cycleId!: string;

  @ApiProperty({ enum: AuctionStatus })
  auctionStatus!: AuctionStatus;

  @ApiProperty()
  selectedWinnerUserId!: string;

  @ApiProperty()
  finalPayoutUserId!: string;

  @ApiPropertyOptional({ nullable: true })
  winningBidAmount!: number | null;

  @ApiPropertyOptional({ nullable: true })
  winningBidUserId!: string | null;
}
