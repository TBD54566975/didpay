import 'package:flutter_starter/features/pfis/pfi.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final pfisProvider = Provider<List<Pfi>>(
  (ref) => [
    Pfi(
      id: 'prototype',
      name: 'Prototype PFI',
      didUri: 'did:dht:3x1hbjobt577amnoeoxcenqrbjicym5mgsx6c6zszisf1igfj51y',
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
