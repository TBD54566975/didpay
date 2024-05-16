class Pfi {
  final String did;

  const Pfi({required this.did});

  factory Pfi.fromJson(Map<String, dynamic> json) => Pfi(did: json['did']);

  Map<String, dynamic> toJson() => {'did': did};
}
