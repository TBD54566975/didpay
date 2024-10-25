import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web5/web5.dart';

final vcsServiceProvider = Provider((_) => VcsService());

class VcsService {
  List<String>? getRequiredCredentials(
    PresentationDefinition presentationDefinition,
    List<String> vcJwts,
  ) {
    final credentials = presentationDefinition.selectCredentials(vcJwts);

    return credentials.isEmpty ? null : credentials;
  }

  String parseCredential(String vcJwt) {
    try {
      final _ = Jwt.decode(vcJwt);
    } on Exception {
      rethrow;
    }

    return vcJwt;
  }
}
