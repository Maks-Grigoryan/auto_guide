/// Service category as returned by GET /catalog/service-categories.
///
/// Maps [{ id: int, name: string }] from the backend.
/// Simpler than PartCategory — no parentId field.
class ServiceCategory {
  const ServiceCategory({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  @override
  String toString() => 'ServiceCategory(id: $id, name: $name)';
}
