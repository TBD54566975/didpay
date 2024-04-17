import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:web5/web5.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockBearerDid extends Mock implements BearerDid {}
