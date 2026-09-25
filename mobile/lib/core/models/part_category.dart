import '../utils/json_value.dart';

/// Part category as returned by GET /catalog/part-categories.
///
/// Maps [{ id: int, name: string, parent_id: int|null }] from the backend.
class PartCategory {
  const PartCategory({
    required this.id,
    required this.name,
    this.parentId,
  });

  final int id;
  final String name;
  final int? parentId;

  factory PartCategory.fromJson(Map<String, dynamic> json) {
    return PartCategory(
      id: jsonInt(json['id'], field: 'partCategory.id'),
      name: json['name'] as String,
      parentId: jsonNullableInt(
        json['parent_id'],
        field: 'partCategory.parent_id',
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'parent_id': parentId,
      };

  @override
  String toString() =>
      'PartCategory(id: $id, name: $name, parentId: $parentId)';
}
