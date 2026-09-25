import 'package:avto_app/core/models/part_category.dart';
import 'package:avto_app/core/models/service_category.dart';
import 'package:avto_app/core/models/vendor_result.dart';
import 'package:avto_app/core/utils/json_value.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JSON number conversion', () {
    test('accepts PostgreSQL bigint strings and JSON numbers', () {
      expect(jsonInt('17'), 17);
      expect(jsonInt(17), 17);
      expect(jsonNullableInt(null), isNull);
      expect(jsonDouble('12.5'), 12.5);
      expect(jsonDouble(12.5), 12.5);
    });

    test('rejects non-numeric values with a useful field name', () {
      expect(
        () => jsonInt('Audi', field: 'make.id'),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('make.id'),
          ),
        ),
      );
    });
  });

  test('catalog models accept bigint strings returned by pg', () {
    final part = PartCategory.fromJson({
      'id': '10',
      'name': 'Engine',
      'parent_id': '2',
    });
    final service = ServiceCategory.fromJson({'id': '7', 'name': 'Repair'});

    expect(part.id, 10);
    expect(part.parentId, 2);
    expect(service.id, 7);
  });

  test('vendor result accepts both string and numeric API values', () {
    final vendor = VendorResult.fromJson({
      'vendor_id': 'vendor-1',
      'name': 'Shop',
      'type': 'parts_shop',
      'lat': '40.18',
      'lng': 44.51,
      'distance_m': '1250.5',
      'item_count': 3,
      'min_price': '15000',
      'rating': 4.8,
    });

    expect(vendor.itemCount, 3);
    expect(vendor.distanceM, 1250.5);
    expect(vendor.minPrice, 15000);
    expect(vendor.rating, 4.8);
  });
}
