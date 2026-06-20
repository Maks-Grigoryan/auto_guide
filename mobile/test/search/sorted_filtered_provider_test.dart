import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:avto_app/core/models/vendor_result.dart';
import 'package:avto_app/features/search/providers/search_params.dart';
import 'package:avto_app/features/search/providers/parts_search_provider.dart';
import 'package:avto_app/features/search/providers/sorted_filtered_provider.dart';

// ---------------------------------------------------------------------------
// Fixture helpers
// ---------------------------------------------------------------------------

VendorResult _v({
  required String id,
  double distanceM = 500,
  double? minPrice,
  double? rating,
}) =>
    VendorResult(
      vendorId: id,
      name: 'Vendor $id',
      type: 'Магазин',
      lat: 40.18,
      lng: 44.51,
      distanceM: distanceM,
      itemCount: 1,
      minPrice: minPrice,
      rating: rating,
    );

/// Fixtures used across multiple tests:
/// A: dist=100m, price=500, rating=4.5
/// B: dist=200m, price=1000, rating=3.0
/// C: dist=300m, price=200,  rating=null
/// D: dist=400m, price=null, rating=5.0
/// E: dist=50m,  price=null, rating=null
final _fixtures = [
  _v(id: 'A', distanceM: 100, minPrice: 500, rating: 4.5),
  _v(id: 'B', distanceM: 200, minPrice: 1000, rating: 3.0),
  _v(id: 'C', distanceM: 300, minPrice: 200, rating: null),
  _v(id: 'D', distanceM: 400, minPrice: null, rating: 5.0),
  _v(id: 'E', distanceM: 50, minPrice: null, rating: null),
];

/// Build a ProviderContainer with [partsSearchProvider] overridden to return
/// [vendors] and [searchParamsProvider] initialized with [params].
ProviderContainer _container(
  List<VendorResult> vendors,
  PartsQuery params,
) {
  return ProviderContainer(
    overrides: [
      partsSearchProvider.overrideWith((_) => Future.value(vendors)),
      searchParamsProvider.overrideWithValue(params),
    ],
  );
}

/// Helper to submit params and get sorted/filtered results.
Future<List<VendorResult>> _sorted(
  List<VendorResult> vendors,
  PartsQuery params,
) async {
  final container = _container(vendors, params);
  addTearDown(container.dispose);
  return container.read(sortedFilteredResultsProvider.future);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('sortedFilteredResultsProvider', () {
    // ----- Sort by distance (default) -----

    test('default sort=distance returns ascending distanceM order', () async {
      final results = await _sorted(
        _fixtures,
        const PartsQuery(lat: 40.18, lng: 44.51),
      );

      final ids = results.map((v) => v.vendorId).toList();
      expect(ids, equals(['E', 'A', 'B', 'C', 'D']));
    });

    // ----- Sort by price -----

    test('sort=price returns ascending minPrice order, nulls last', () async {
      final results = await _sorted(
        _fixtures,
        const PartsQuery(lat: 40.18, lng: 44.51, sort: ResultSort.price),
      );

      final ids = results.map((v) => v.vendorId).toList();
      // C=200, A=500, B=1000 then D=null, E=null (both null — stable, order among nulls unconstrained)
      expect(ids.take(3).toList(), equals(['C', 'A', 'B']));
      expect(ids.skip(3).toSet(), equals({'D', 'E'})); // both null — order unspecified
    });

    // ----- Sort by rating -----

    test('sort=rating returns DESCENDING rating, nulls last', () async {
      final results = await _sorted(
        _fixtures,
        const PartsQuery(lat: 40.18, lng: 44.51, sort: ResultSort.rating),
      );

      final ids = results.map((v) => v.vendorId).toList();
      // D=5.0, A=4.5, B=3.0 then C=null, E=null
      expect(ids.take(3).toList(), equals(['D', 'A', 'B']));
      expect(ids.skip(3).toSet(), equals({'C', 'E'}));
    });

    test('sort=rating: highest rated vendor is first', () async {
      final results = await _sorted(
        _fixtures,
        const PartsQuery(lat: 40.18, lng: 44.51, sort: ResultSort.rating),
      );

      expect(results.first.vendorId, equals('D')); // rating=5.0
    });

    // ----- availabilityOnly filter -----

    test('availabilityOnly=true drops vendors with null minPrice', () async {
      final results = await _sorted(
        _fixtures,
        const PartsQuery(
          lat: 40.18,
          lng: 44.51,
          availabilityOnly: true,
        ),
      );

      // D and E have null minPrice — should be excluded
      final ids = results.map((v) => v.vendorId).toSet();
      expect(ids.contains('D'), isFalse);
      expect(ids.contains('E'), isFalse);
      expect(ids, equals({'A', 'B', 'C'}));
    });

    // ----- minPrice filter -----

    test('minPrice=X keeps only vendors with minPrice >= X', () async {
      final results = await _sorted(
        _fixtures,
        const PartsQuery(
          lat: 40.18,
          lng: 44.51,
          minPrice: 500.0,
        ),
      );

      final ids = results.map((v) => v.vendorId).toSet();
      // A=500 (included), B=1000 (included), C=200 (excluded), D=null (excluded), E=null (excluded)
      expect(ids, equals({'A', 'B'}));
    });

    // ----- maxPrice filter -----

    test('maxPrice=Y keeps only vendors with minPrice <= Y', () async {
      final results = await _sorted(
        _fixtures,
        const PartsQuery(
          lat: 40.18,
          lng: 44.51,
          maxPrice: 500.0,
        ),
      );

      final ids = results.map((v) => v.vendorId).toSet();
      // A=500 (included), B=1000 (excluded), C=200 (included), D=null (excluded), E=null (excluded)
      expect(ids, equals({'A', 'C'}));
    });

    // ----- Combined min+max price filter -----

    test('minPrice + maxPrice together form a price range', () async {
      final results = await _sorted(
        _fixtures,
        const PartsQuery(
          lat: 40.18,
          lng: 44.51,
          minPrice: 300.0,
          maxPrice: 600.0,
        ),
      );

      final ids = results.map((v) => v.vendorId).toSet();
      // Only A=500 is in [300,600]; C=200 excluded, B=1000 excluded
      expect(ids, equals({'A'}));
    });

    // ----- VendorResult.fromJson rating parsing -----

    test('VendorResult.fromJson parses rating string to double', () {
      final json = {
        'vendor_id': 'v1',
        'name': 'Test',
        'type': 'Магазин',
        'phone': null,
        'address': null,
        'lat': 40.18,
        'lng': 44.51,
        'distance_m': 500.0,
        'item_count': '3',
        'min_price': null,
        'rating': '4.5',
      };

      final result = VendorResult.fromJson(json);
      expect(result.rating, closeTo(4.5, 0.001));
    });

    test('VendorResult.fromJson handles null rating without throwing', () {
      final json = {
        'vendor_id': 'v1',
        'name': 'Test',
        'type': 'Магазин',
        'phone': null,
        'address': null,
        'lat': 40.18,
        'lng': 44.51,
        'distance_m': 500.0,
        'item_count': '3',
        'min_price': null,
        'rating': null,
      };

      final result = VendorResult.fromJson(json);
      expect(result.rating, isNull);
    });

    test('VendorResult.fromJson handles absent rating key without throwing', () {
      final json = {
        'vendor_id': 'v1',
        'name': 'Test',
        'type': 'Магазин',
        'phone': null,
        'address': null,
        'lat': 40.18,
        'lng': 44.51,
        'distance_m': 500.0,
        'item_count': '3',
        'min_price': null,
        // 'rating' key absent
      };

      final result = VendorResult.fromJson(json);
      expect(result.rating, isNull);
    });

    // ----- Empty list passthrough -----

    test('returns empty list when no results', () async {
      final results = await _sorted(
        [],
        const PartsQuery(lat: 40.18, lng: 44.51),
      );

      expect(results, isEmpty);
    });

    // ----- No filter applied when params are default -----

    test('default params returns all vendors sorted by distance', () async {
      final results = await _sorted(
        _fixtures,
        const PartsQuery(lat: 40.18, lng: 44.51),
      );

      expect(results.length, equals(_fixtures.length));
      // Verify ascending distance order
      for (var i = 0; i < results.length - 1; i++) {
        expect(
          results[i].distanceM,
          lessThanOrEqualTo(results[i + 1].distanceM),
        );
      }
    });
  });
}
