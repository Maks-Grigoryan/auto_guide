import { Controller, Get, Param } from '@nestjs/common';
import { GetVendorDto } from './dto/get-vendor.dto';
import { VendorDetail, VendorsService } from './vendors.service';

@Controller('vendors')
export class VendorsController {
  constructor(private readonly vendorsService: VendorsService) {}

  @Get(':id')
  getById(@Param() dto: GetVendorDto): Promise<VendorDetail> {
    return this.vendorsService.getById(dto.id);
  }
}
