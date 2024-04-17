class IdvRequest {
  final String url;

  IdvRequest({
    required this.url,
  });

  Map<String, dynamic> toJson() {
    return {
      'url': url,
    };
  }

  factory IdvRequest.fromJson(Map<String, dynamic> json) {
    return IdvRequest(
      url: json['url'],
    );
  }
}
