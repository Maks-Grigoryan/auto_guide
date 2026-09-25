import '../../../core/utils/json_value.dart';

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
    this.year,
  });

  final int makeId;
  final String makeName;
  final int modelId;
  final String modelName;

  /// Nullable — generation is optional per SEL-03.
  final int? generationId;
  final String? generationLabel;

  /// Year of manufacture. Nullable, and skipping it stays a first-class choice.
  ///
  /// Kept beside the generation rather than derived from it: most makes in this
  /// catalogue have no generation rows at all, and for those the year is the
  /// only thing that narrows a model down.
  final int? year;

  /// Serialise to a Map for Hive storage.
  /// Persist minimal display fields only so the chip renders offline.
  Map<String, dynamic> toMap() => {
        'makeId': makeId,
        'makeName': makeName,
        'modelId': modelId,
        'modelName': modelName,
        'generationId': generationId,
        'generationLabel': generationLabel,
        'year': year,
      };

  /// Deserialise from Hive's [Map<dynamic,dynamic>].
  factory SelectedCar.fromMap(Map<dynamic, dynamic> m) => SelectedCar(
        makeId: jsonInt(m['makeId'], field: 'selectedCar.makeId'),
        makeName: m['makeName'] as String,
        modelId: jsonInt(m['modelId'], field: 'selectedCar.modelId'),
        modelName: m['modelName'] as String,
        generationId: jsonNullableInt(
          m['generationId'],
          field: 'selectedCar.generationId',
        ),
        generationLabel: m['generationLabel'] as String?,
        // Absent for cars confirmed before the year picker existed; those
        // entries are read back as "year not specified" rather than rejected.
        year: jsonNullableInt(m['year'], field: 'selectedCar.year'),
      );

  @override
  String toString() => 'SelectedCar(makeId: $makeId, makeName: $makeName, '
      'modelId: $modelId, modelName: $modelName, '
      'generationId: $generationId, generationLabel: $generationLabel, '
      'year: $year)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectedCar &&
          makeId == other.makeId &&
          makeName == other.makeName &&
          modelId == other.modelId &&
          modelName == other.modelName &&
          generationId == other.generationId &&
          generationLabel == other.generationLabel &&
          year == other.year;

  @override
  int get hashCode => Object.hash(
        makeId,
        makeName,
        modelId,
        modelName,
        generationId,
        generationLabel,
        year,
      );
}
