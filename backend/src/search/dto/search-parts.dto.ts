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
  @Max(100000)
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
  generationId?: number;

  @IsOptional()
  @IsNumber()
  @IsPositive()
  @Type(() => Number)
  categoryId?: number;

  @IsOptional()
  @IsString()
  query?: string;

  /// Year of manufacture. Narrows the search to parts whose fitment covers it.
  ///
  /// Bounded rather than merely positive: a year is not an id, and 70000 is a
  /// typo every time. The lower bound predates any car this catalogue will
  /// carry; the upper leaves room for model years sold ahead of the calendar.
  @IsOptional()
  @IsNumber()
  @Min(1900)
  @Max(2100)
  @Type(() => Number)
  year?: number;
}
