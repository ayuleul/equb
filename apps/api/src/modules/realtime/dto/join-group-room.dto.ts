import { IsString, IsUUID } from 'class-validator';

export class JoinGroupRoomDto {
  @IsString()
  @IsUUID()
  groupId!: string;
}
