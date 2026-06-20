import { IsNumber, IsOptional, IsPositive, Max, Min } from 'class-validator';
import { Type } from 'class-transformer';

export class SearchRepairDto {
  @IsNumber()
  @Min(-90)
  @Max(90)
  @Type(() => Number)
  lat!: number;

  @IsNumber()
  @Min(-180)
  @Max(180)
  @Type(() => Number)
  lng!: number;

  @IsOptional()
  @IsNumber()
  @IsPositive()
  @Max(100000)
  @Type(() => Number)
  radius: number = 10000;

  @IsOptional()
  @IsNumber()
  @IsPositive()
  @Type(() => Number)
  serviceCategoryId?: number;
}
