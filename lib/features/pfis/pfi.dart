import 'package:equatable/equatable.dart';

class Pfi extends Equatable {
  final String did;

  const Pfi({required this.did});

  factory Pfi.fromJson(Map<String, dynamic> json) => Pfi(did: json['did']);

  Map<String, dynamic> toJson() => {'did': did};

  @override
  List<Object?> get props => [did];
}

const tbdPfiDid = 'did:web:pfi.tbd.engineering';
