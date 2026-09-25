import {
  IsIn,
  IsNumber,
  IsOptional,
  IsPositive,
  IsString,
  Length,
  Max,
  Min,
} from 'class-validator';
import { Type } from 'class-transformer';

/**
 * Body of `POST /ai/chat`.
 *
 * Location and car arrive here and go straight into the tool context — the
 * model never sees these fields and cannot pass its own. That is why they are
 * validated as strictly as on any other geo endpoint: they end up in a PostGIS
 * query, not in a prompt.
 */
export class AiChatDto {
  @IsString()
  @Length(1, 2000)
  message!: string;

  /** Continues an existing thread. Ownership is checked server-side. */
  @IsOptional()
  @IsNumber()
  @IsPositive()
  @Type(() => Number)
  conversationId?: number;

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

  /** Reply language. Comes from the app's locale, not from the user's words. */
  @IsIn(['ru', 'hy', 'en'])
  locale!: string;

  /** Human-readable car, e.g. «ВАЗ 2170 Приора», passed to the model as context. */
  @IsOptional()
  @IsString()
  @Length(1, 120)
  carLabel?: string;
}
