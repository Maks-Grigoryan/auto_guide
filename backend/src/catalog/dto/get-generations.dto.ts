import { IsNumber, IsPositive } from 'class-validator';
import { Type } from 'class-transformer';

export class GetGenerationsDto {
  @IsNumber()
  @IsPositive()
  @Type(() => Number)
  modelId!: number;
}
