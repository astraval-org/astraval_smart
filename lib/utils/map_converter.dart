Map<String, dynamic> convertToMapStringDynamic(Object? data) {
  if (data == null) {
    return {};
  }

  if (data is Map) {
    return data.map((key, value) {
      final stringKey = key?.toString() ?? '';
      if (value is Map) {
        // Recursively convert nested maps
        return MapEntry(stringKey, convertToMapStringDynamic(value));
      } else if (value is List) {
        // Handle lists by mapping each element
        return MapEntry(stringKey, value.map((e) => convertToMapStringDynamic(e)).toList());
      } else {
        // Handle scalar values (String, int, bool, etc.)
        return MapEntry(stringKey, value);
      }
    });
  }

  return {};
}