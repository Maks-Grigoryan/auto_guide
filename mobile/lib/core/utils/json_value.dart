/// Converts a JSON number represented as either a JSON number or a decimal
/// string to an integer.
///
/// PostgreSQL `bigint` values are intentionally returned as strings by the
/// Node `pg` driver, so API consumers must accept both representations.
int jsonInt(Object? value, {String field = 'value'}) {
  if (value is int) return value;
  if (value is num && value.isFinite && value == value.truncate()) {
    return value.toInt();
  }
  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null) return parsed;
  }
  throw FormatException('Expected an integer for $field, got $value');
}

int? jsonNullableInt(Object? value, {String field = 'value'}) {
  if (value == null) return null;
  return jsonInt(value, field: field);
}

double jsonDouble(Object? value, {String field = 'value'}) {
  if (value is num) return value.toDouble();
  if (value is String) {
    final parsed = double.tryParse(value);
    if (parsed != null) return parsed;
  }
  throw FormatException('Expected a number for $field, got $value');
}

double? jsonNullableDouble(Object? value, {String field = 'value'}) {
  if (value == null) return null;
  return jsonDouble(value, field: field);
}
