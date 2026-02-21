import { Transform } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';
import {
  IsNotEmpty,
  IsString,
  Matches,
  MaxLength,
  MinLength,
} from 'class-validator';

import { normalizeNameWhitespace } from '../../../common/profile/profile.utils';

const ETHIOPIAN_NAME_REGEX =
  /^(?:[\p{Script=Latin}\p{Script=Ethiopic}]+(?: [\p{Script=Latin}\p{Script=Ethiopic}]+)*)$/u;

function normalizeNameInput(value: unknown): unknown {
  if (typeof value !== 'string') {
    return value;
  }

  return normalizeNameWhitespace(value);
}

export class UpdateProfileDto {
  @ApiProperty({ example: 'Abebe' })
  @Transform(({ value }) => normalizeNameInput(value))
  @IsString()
  @IsNotEmpty()
  @MinLength(2)
  @MaxLength(50)
  @Matches(ETHIOPIAN_NAME_REGEX, {
    message:
      'First Name must contain only letters and spaces (Latin or Ethiopic)',
  })
  firstName!: string;

  @ApiProperty({ example: 'Kebede' })
  @Transform(({ value }) => normalizeNameInput(value))
  @IsString()
  @IsNotEmpty()
  @MinLength(2)
  @MaxLength(50)
  @Matches(ETHIOPIAN_NAME_REGEX, {
    message:
      "Father's Name must contain only letters and spaces (Latin or Ethiopic)",
  })
  middleName!: string;

  @ApiProperty({ example: 'Bekele' })
  @Transform(({ value }) => normalizeNameInput(value))
  @IsString()
  @IsNotEmpty()
  @MinLength(2)
  @MaxLength(50)
  @Matches(ETHIOPIAN_NAME_REGEX, {
    message:
      "Grandfather's Name must contain only letters and spaces (Latin or Ethiopic)",
  })
  lastName!: string;
}
