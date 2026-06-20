import { Controller, Get, Query } from '@nestjs/common';
import { SearchService, VendorSearchResult } from './search.service';
import { SearchPartsDto } from './dto/search-parts.dto';
import { SearchRepairDto } from './dto/search-repair.dto';

@Controller('search')
export class SearchController {
  constructor(private readonly searchService: SearchService) {}

  @Get('parts')
  searchParts(@Query() dto: SearchPartsDto): Promise<VendorSearchResult[]> {
    return this.searchService.searchParts(dto);
  }

  @Get('repair')
  searchRepair(@Query() dto: SearchRepairDto): Promise<VendorSearchResult[]> {
    return this.searchService.searchRepair(dto);
  }
}
