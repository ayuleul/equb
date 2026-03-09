import { IsString, IsUUID } from 'class-validator';

export class JoinTurnRoomDto {
  @IsString()
  @IsUUID()
  turnId!: string;
}
