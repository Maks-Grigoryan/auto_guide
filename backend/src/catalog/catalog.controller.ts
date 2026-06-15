import { Controller, Get, Header, Query } from '@nestjs/common';
import { CatalogService, CarMake, CarModel, CarGeneration } from './catalog.service';
import { GetModelsDto } from './dto/get-models.dto';
import { GetGenerationsDto } from './dto/get-generations.dto';

@Controller('catalog')
export class CatalogController {
  constructor(private readonly catalogService: CatalogService) {}

  @Get('makes')
  @Header('Cache-Control', 'public, max-age=86400')
  getMakes(): Promise<CarMake[]> {
    return this.catalogService.getMakes();
  }

  @Get('models')
  @Header('Cache-Control', 'public, max-age=86400')
  getModels(@Query() dto: GetModelsDto): Promise<CarModel[]> {
    return this.catalogService.getModels(dto.makeId);
  }

  @Get('generations')
  @Header('Cache-Control', 'public, max-age=86400')
  getGenerations(@Query() dto: GetGenerationsDto): Promise<CarGeneration[]> {
    return this.catalogService.getGenerations(dto.modelId);
  }
}
