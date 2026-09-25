import '../utils/json_value.dart';

class VendorDetail {
  const VendorDetail({
    required this.id,
    required this.name,
    required this.type,
    this.phone,
    this.address,
    required this.lat,
    required this.lng,
    this.rating,
    required this.isVerified,
    this.hours,
  });

  final String id;
  final String name;
  final String type;
  final String? phone;
  final String? address;
  final double lat;
  final double lng;
  final double? rating;
  final bool isVerified;
  final Map<String, String>? hours;

  factory VendorDetail.fromJson(Map<String, dynamic> json) {
    final rawHours = json['hours'];
    return VendorDetail(
      id: json['id'].toString(),
      name: json['name'] as String,
      type: json['type'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      lat: jsonDouble(json['lat'], field: 'vendor.lat'),
      lng: jsonDouble(json['lng'], field: 'vendor.lng'),
      rating: jsonNullableDouble(json['rating'], field: 'vendor.rating'),
      isVerified: json['is_verified'] as bool? ?? false,
      hours: rawHours is Map
          ? rawHours.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            )
          : null,
    );
  }
}
