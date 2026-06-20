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
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      distanceM: (json['distance_m'] as num).toDouble(),
      // item_count arrives as a string from the DB (BIGINT aggregate).
      itemCount: int.parse(json['item_count'] as String),
      // min_price is NUMERIC — arrives as string or null.
      minPrice: json['min_price'] == null
          ? null
          : double.parse(json['min_price'] as String),
      // rating is NUMERIC — arrives as string or null (migration 006).
      rating: json['rating'] == null
          ? null
          : double.parse(json['rating'] as String),
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
