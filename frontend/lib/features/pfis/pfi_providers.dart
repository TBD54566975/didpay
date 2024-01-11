import 'package:flutter_starter/features/pfis/pfi.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final pfisProvider = Provider<List<Pfi>>(
  (ref) => [
    Pfi(
      id: 'prototype',
      name: 'Prototype',
      didUri: 'did:dht:74hg1efatndi8enx3e4z6c4u8ieh1xfkyay4ntg4dg1w6risu35y',
    ),
    Pfi(
      id: 'africa',
      name: 'Africa',
      didUri: 'coming soon...',
    ),
    Pfi(
      id: 'mexico',
      name: 'Mexico',
      didUri: 'coming soon...',
    ),
  ],
);
