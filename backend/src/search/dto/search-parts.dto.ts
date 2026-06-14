import { IsNumber, IsOptional, IsPositive, IsString, Max, Min } from 'class-validator';
import { Type } from 'class-transformer';

export class SearchPartsDto {
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
  @Type(() => Number)
  radius: number = 10000;

  @IsOptional()
  @IsNumber()
  @IsPositive()
  @Type(() => Number)
  makeId?: number;

  @IsOptional()
  @IsNumber()
  @IsPositive()
  @Type(() => Number)
  modelId?: number;

  @IsOptional()
  @IsNumber()
  @IsPositive()
  @Type(() => Number)
  categoryId?: number;

  @IsOptional()
  @IsString()
  query?: string;
}
