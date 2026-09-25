import '../utils/json_value.dart';

/// Vendor search result matching the VendorSearchResult interface in
/// backend/src/search/search.service.ts.
///
/// Backend SQL: search_parts($1..$8) returns rows with these exact column names.
/// item_count and min_price come from the DB as strings (NUMERIC / BIGINT).
/// rating is NUMERIC — arrives as string or null (added in migration 006).
class VendorResult {
  const VendorResult({
    required this.vendorId,
    required this.name,
    required this.type,
    this.phone,
    this.address,
    required this.lat,
    required this.lng,
    required this.distanceM,
    required this.itemCount,
    this.minPrice,
    this.rating,
  });

  final String vendorId;
  final String name;
  final String type;
  final String? phone;
  final String? address;
  final double lat;
  final double lng;

  /// Distance in metres from the search origin.
  final double distanceM;

  /// Total number of matching items at this vendor.
  final int itemCount;

  /// Minimum price in the local currency (AMD). Nullable when vendor has no
  /// priced listings for the searched category.
  final double? minPrice;

  /// Average vendor rating (0–5). Nullable when no ratings exist yet.
  /// Postgres NUMERIC arrives as string; absent/null in JSON → null.
  final double? rating;

  factory VendorResult.fromJson(Map<String, dynamic> json) {
    return VendorResult(
      vendorId: json['vendor_id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      lat: jsonDouble(json['lat'], field: 'vendorResult.lat'),
      lng: jsonDouble(json['lng'], field: 'vendorResult.lng'),
      distanceM: jsonDouble(
        json['distance_m'],
        field: 'vendorResult.distance_m',
      ),
      // item_count arrives as a string from the DB (BIGINT aggregate).
      itemCount: jsonInt(json['item_count'], field: 'vendorResult.item_count'),
      // min_price is NUMERIC — arrives as string or null.
      minPrice: jsonNullableDouble(
        json['min_price'],
        field: 'vendorResult.min_price',
      ),
      // rating is NUMERIC — arrives as string or null (migration 006).
      rating: jsonNullableDouble(
        json['rating'],
        field: 'vendorResult.rating',
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'vendor_id': vendorId,
        'name': name,
        'type': type,
        'phone': phone,
        'address': address,
        'lat': lat,
        'lng': lng,
        'distance_m': distanceM,
        'item_count': itemCount.toString(),
        'min_price': minPrice?.toString(),
        'rating': rating?.toString(),
      };

  @override
  String toString() =>
      'VendorResult(vendorId: $vendorId, name: $name, distanceM: $distanceM m)';
}
