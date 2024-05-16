class Pfi {
  final String did;
  final Uri tbdexServiceEndpoint;
  final Uri idvServiceEndpoint;

  const Pfi({
    required this.did,
    required this.tbdexServiceEndpoint,
    required this.idvServiceEndpoint,
  });

  factory Pfi.fromJson(Map<String, dynamic> json) {
    return Pfi(
      did: json['did'],
      tbdexServiceEndpoint: Uri.parse(json['tbdexServiceEndpoint']),
      idvServiceEndpoint: Uri.parse(json['idvServiceEndpoint']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'did': did,
      'tbdexServiceEndpoint': tbdexServiceEndpoint.toString(),
      'idvServiceEndpoint': idvServiceEndpoint.toString(),
    };
  }
}
