import { Controller, Get, Header, Query } from '@nestjs/common';
import { CatalogService, CarMake, CarModel, CarGeneration, PartCategory, ServiceCategory } from './catalog.service';
import { GetModelsDto } from './dto/get-models.dto';
import { GetGenerationsDto } from './dto/get-generations.dto';

/**
 * The catalogue is stable but not frozen: seeding a make or a model has to
 * reach people who already have the app open.
 *
 * `max-age=86400` did not. A browser that had fetched a make's models before
 * the catalogue grew kept serving that stale — often empty — list for a full
 * day, so a newly added brand looked broken to anyone who had visited before
 * the seed. Five minutes of hard freshness keeps the list snappy while
 * `stale-while-revalidate` preserves the instant paint: the cached copy is
 * shown immediately and refreshed in the background.
 */
export const CATALOG_CACHE_CONTROL =
  'public, max-age=300, stale-while-revalidate=86400';

@Controller('catalog')
export class CatalogController {
  constructor(private readonly catalogService: CatalogService) {}

  // `lang` is a query parameter rather than an Accept-Language header so the
  // URL differs per language: caches then key on it by themselves, and the
  // long Cache-Control above cannot serve one locale's names to another.
  //
  // Unrecognised values are not rejected — the service treats anything it does
  // not know as Russian, which is the sensible answer to a client asking for a
  // language nobody has translated yet.
  @Get('part-categories')
  @Header('Cache-Control', CATALOG_CACHE_CONTROL)
  getPartCategories(@Query('lang') lang?: string): Promise<PartCategory[]> {
    return this.catalogService.getPartCategories(lang);
  }

  @Get('makes')
  @Header('Cache-Control', CATALOG_CACHE_CONTROL)
  getMakes(): Promise<CarMake[]> {
    return this.catalogService.getMakes();
  }

  @Get('models')
  @Header('Cache-Control', CATALOG_CACHE_CONTROL)
  getModels(@Query() dto: GetModelsDto): Promise<CarModel[]> {
    return this.catalogService.getModels(dto.makeId);
  }

  @Get('generations')
  @Header('Cache-Control', CATALOG_CACHE_CONTROL)
  getGenerations(
    @Query() dto: GetGenerationsDto,
    @Query('lang') lang?: string,
  ): Promise<CarGeneration[]> {
    return this.catalogService.getGenerations(dto.modelId, lang);
  }

  @Get('service-categories')
  @Header('Cache-Control', CATALOG_CACHE_CONTROL)
  getServiceCategories(
    @Query('lang') lang?: string,
  ): Promise<ServiceCategory[]> {
    return this.catalogService.getServiceCategories(lang);
  }
}
