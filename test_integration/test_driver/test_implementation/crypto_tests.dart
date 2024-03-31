import 'package:ably_flutter_integration_test/driver_data_handler.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void testCryptoGenerateRandomKey(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.cryptoGenerateRandomKey);
  late TestControlResponseMessage response;
  late List<dynamic> keyWithDefaultLength;
  late List<dynamic> keyWith128BitLength;
  late List<dynamic> keyWith256BitLength;

  setUpAll(() async {
    response = await requestDataForTest(getDriver(), message);
    keyWithDefaultLength =
        response.payload['keyWithDefaultLength'] as List<dynamic>;
    keyWith128BitLength =
        response.payload['keyWith128BitLength'] as List<dynamic>;
    keyWith256BitLength =
        response.payload['keyWith256BitLength'] as List<dynamic>;
  });

  group('crypto#generateRandomKey', () {
    test('generates key with default length if length is not specified', () {
      // Default key length is 256bit, but we need the same value in bytes
      const defaultKeyLength = 256 / 8;
      expect(keyWithDefaultLength.length, defaultKeyLength);
    });

    test('generates keys with specified length', () {
      const keyLength128Bit = 128 / 8;
      const keyLength256Bit = 256 / 8;
      expect(keyWith128BitLength.length, equals(keyLength128Bit));
      expect(keyWith256BitLength.length, equals(keyLength256Bit));
    });
  });
}

void testCryptoEnsureSupportedKeyLength(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.cryptoEnsureSupportedKeyLength);
  late TestControlResponseMessage response;
  Map<String, dynamic>? keyWithDefaultLengthException;
  Map<String, dynamic>? keyWith128BitLengthException;
  Map<String, dynamic>? keyWith256BitLengthException;
  Map<String, dynamic>? keyWith127BitLengthException;

  setUpAll(() async {
    response = await requestDataForTest(getDriver(), message);
    keyWithDefaultLengthException = response
        .payload['keyWithDefaultLengthException'] as Map<String, dynamic>?;
    keyWith128BitLengthException = response
        .payload['keyWith128BitLengthException'] as Map<String, dynamic>?;
    keyWith256BitLengthException = response
        .payload['keyWith256BitLengthException'] as Map<String, dynamic>?;
    keyWith127BitLengthException = response
        .payload['keyWith127BitLengthException'] as Map<String, dynamic>?;
  });

  group('crypto#ensureSupportedKeyLength', () {
    test('does not fail for key with default length', () {
      expect(keyWithDefaultLengthException, isNull);
    });

    test('does not fail for key with 128bit length', () {
      expect(keyWith128BitLengthException, isNull);
    });

    test('does not fail for key with 256bit length', () {
      expect(keyWith256BitLengthException, isNull);
    });

    test('fails for key with unsupported length', () {
      expect(keyWith127BitLengthException, isNotNull);
    });
  });
}

void testCryptoGetDefaultParams(FlutterDriver Function() getDriver) {
  const message = TestControlMessage(TestName.cryptoGetDefaultParams);
  late TestControlResponseMessage response;
  Map<String, dynamic>? keyWith127BitLengthException;

  // Can't use [CipherParams] as a type here because import from
  // ably_flutter package in this file breaks integration test suite
  // So we can only pass a value to determine if params were fetched
  late bool? didFetchDefaultParams;

  setUpAll(() async {
    response = await requestDataForTest(getDriver(), message);
    keyWith127BitLengthException = response
        .payload['keyWith127BitLengthException'] as Map<String, dynamic>?;
    didFetchDefaultParams = response.payload['didFetchDefaultParams'] as bool?;
  });

  group('crypto#getDefaultParams', () {
    test('fails for key with unsupported length', () {
      expect(keyWith127BitLengthException, isNotNull);
    });

    test('returns default params from platform', () {
      expect(didFetchDefaultParams, isTrue);
    });
  });
}
