import 'dart:convert';

import 'package:didpay/shared/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web5/web5.dart';

final didServiceProvider =
    Provider<DidStorageService>((ref) => throw UnimplementedError());

class DidStorageService {
  final FlutterSecureStorage storage;

  const DidStorageService(this.storage);

  Future<BearerDid> getOrCreateDid() async {
    final existingPortableDidJson =
        await storage.read(key: Constants.portableDidKey);

    if (existingPortableDidJson != null) {
      final portableDidJson = json.decode(existingPortableDidJson);
      final portableDid = PortableDid.fromMap(portableDidJson);
      return BearerDid.import(portableDid);
    }

    final did = await DidDht.create(publish: true);
    final portableDid = await did.export();
    final portableDidJson = jsonEncode(portableDid.map);

    await storage.write(
      key: Constants.portableDidKey,
      value: portableDidJson,
    );
    return did;
  }

  Future<BearerDid> regenerateDid() async {
    await storage.delete(key: Constants.portableDidKey);

    final newDid = await DidDht.create(publish: true);
    final portableDid = await newDid.export();
    final portableDidJson = jsonEncode(portableDid.map);

    await storage.write(
      key: Constants.portableDidKey,
      value: portableDidJson,
    );
    return newDid;
  }
}
