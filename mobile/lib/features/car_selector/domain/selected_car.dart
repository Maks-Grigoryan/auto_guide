/// Immutable value object representing the user's confirmed car selection.
///
/// Persisted to Hive CE box 'selectedCar' via [toMap]/[fromMap] without a
/// TypeAdapter — Map<dynamic,dynamic> is sufficient for this flat structure
/// (Assumption A5 from RESEARCH.md).
class SelectedCar {
  const SelectedCar({
    required this.makeId,
    required this.makeName,
    required this.modelId,
    required this.modelName,
    this.generationId,
    this.generationLabel,
  });

  final int makeId;
  final String makeName;
  final int modelId;
  final String modelName;

  /// Nullable — generation is optional per SEL-03.
  final int? generationId;
  final String? generationLabel;

  /// Serialise to a Map for Hive storage.
  /// Persist minimal display fields only so the chip renders offline.
  Map<String, dynamic> toMap() => {
        'makeId': makeId,
        'makeName': makeName,
        'modelId': modelId,
        'modelName': modelName,
        'generationId': generationId,
        'generationLabel': generationLabel,
      };

  /// Deserialise from Hive's [Map<dynamic,dynamic>].
  factory SelectedCar.fromMap(Map<dynamic, dynamic> m) => SelectedCar(
        makeId: m['makeId'] as int,
        makeName: m['makeName'] as String,
        modelId: m['modelId'] as int,
        modelName: m['modelName'] as String,
        generationId: m['generationId'] as int?,
        generationLabel: m['generationLabel'] as String?,
      );

  @override
  String toString() => 'SelectedCar(makeId: $makeId, makeName: $makeName, '
      'modelId: $modelId, modelName: $modelName, '
      'generationId: $generationId, generationLabel: $generationLabel)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectedCar &&
          makeId == other.makeId &&
          makeName == other.makeName &&
          modelId == other.modelId &&
          modelName == other.modelName &&
          generationId == other.generationId &&
          generationLabel == other.generationLabel;

  @override
  int get hashCode => Object.hash(
        makeId,
        makeName,
        modelId,
        modelName,
        generationId,
        generationLabel,
      );
}
