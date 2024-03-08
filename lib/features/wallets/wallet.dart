class Wallet {
  final String name;
  final String url;

  Wallet({required this.name, required this.url});

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
    };
  }
}
