class Serializer {
  const Serializer._();

  static List<Map<String, dynamic>> serializeList<T>(
    List<T> items,
    Map<String, dynamic> Function(T) toJson,
  ) {
    return items.map((item) => toJson(item)).toList();
  }

  static List<T> deserializeList<T>(
    List<dynamic> jsonList,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return jsonList
        .map((json) => fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }
}
