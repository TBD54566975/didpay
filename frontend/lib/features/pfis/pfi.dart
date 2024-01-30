class Pfi {
  final String id;
  final String name;
  final String didUri;

  Pfi({
    required this.id,
    required this.name,
    required this.didUri,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'didUri': didUri,
    };
  }

  factory Pfi.fromJson(Map<String, dynamic> json) {
    return Pfi(
      id: json['id'],
      name: json['name'],
      didUri: json['didUri'],
    );
  }
}
