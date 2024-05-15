import 'dart:convert';

class Pfi {
  final String did;

  const Pfi({
    required this.did,
  });

  factory Pfi.fromJson(String json) {
    return Pfi.fromMap(jsonDecode(json));
  }

  factory Pfi.fromMap(Map<String, dynamic> map) {
    return Pfi(
      did: map['did'],
    );
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  Map<String, dynamic> toMap() {
    return {'did': did};
  }
}
