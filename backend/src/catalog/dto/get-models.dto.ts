import { IsNumber, IsPositive } from 'class-validator';
import { Type } from 'class-transformer';

export class GetModelsDto {
  @IsNumber()
  @IsPositive()
  @Type(() => Number)
  makeId!: number;
}
