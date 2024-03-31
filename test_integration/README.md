# Ably Realtime integration tests

Integration tests allow for tests to execute on Android and iOS. This allows us to ensure
platform specific behaviour (native ably-flutter code and dependencies, ably-cocoa and ably-java)
are behaving as expected.

## Test Structure 

### Test Target

This project has only one integration test target, `main.dart`. 
To run all tests: 
 - run `flutter drive --target lib/main.dart`, or 
 - run `flutter drive` which runs them all (one and only, `main.dart`).
 - Android Studio / VS Code: Run the `Integration Test` run configuration. It is a compound run configuration which runs both `Integration Test Driver` and `Integration Test App`.

### Test Module

Test modules include `basicTests` and `realtime` (For the full list, `TestModules` in [tests_config.dart](./test_driver/tests_config.dart)). To run one module (a collection of test groups), either:
- In Android Studio: 
  - Modify the `Integration Test Driver` run/debug configuration by adding `-m module_name_1,module_name_2` in `Program Arguments`.
    - Note: No spaces between module_names. Alternatively, specify the modules separately: `-m module_name_1 -m module_name_2` 
- Launch each application manually:
  - Launch the integration test app manually
  - Launch the driver and pass the modules with the `-m` option: `dart test_integration/test_driver/runner.dart -m rest,realtime`

### Test Group

To run a specific test group:
- In [tests_config.dart](test_driver/tests_config.dart), comment out the **test group** key: value pairs which you don't want to run.
- Launch both integration test app and driver:
  - Launch `Integration Test` compound run configuration in Android, or
  - Launch `Integration Test App` and `Integration Test Driver` run configurations, or
  - Launch each application manually:
    - Launch the integration test app manually
    - Launch the driver: `dart test_integration/test_driver/runner.dart`

## Execute the Flutter Driver Tests

### Run all Driver Tests
Run the bash script in the project root directory

``` shell
cd test_integration
./run_integration_tests.sh
```

### Run a single Driver Test file

```shell
cd test_integration
flutter driver test_driver/app.dart
```

## `flutter drive` execution

When 

``` shell
flutter drive test_driver/*
```

is executed, `flutter drive` searches of pairs of files in the
directory `test_driver/` with the names `xxx.dart` and `xxx_test.dart`  
where `xxx.dart` is the app to be run on the device or emulator and  
`xxx_test.dart` the unit-test like test that controls the app by
sending commands and receiving responses that are then evaluated with
`expect(...)` and similar to unit tests.

`flutter drive` then executes *the app* in the found *devices* (or a
device or emulator specified in additional parameters) and  
*the test* on the *host platform* where `flutter drive` is executed.

Because it is often convenient to execute the test application like a
normal application (without `flutter drive`), the app implementation
is put into `lib/` instead of `test_driver`.

To satisfy `flutter drive` the `xxx.dart` file has to exist, but all
it does is to import and calls the `main()` function of the app in
`lib/main.dart`.

It is possible to have multiple applications in `lib/` and different
`test_driver/xxx.dart` files can call different main functions from
`lib/`.

## Controlling the app from the test

`flutter drive` provides a set of functions to simulate user input
like touch, but here we discuss only non-UI drive tests.

### Connecting from the test to the app

The test needs to establish a connection with the application by
executing `driver = await FlutterDriver.connect();`.

### Sending a message from the test to the app

Tests send a message to the app using

``` dart
final result = await driver.requestData(message.toJson());
```

Only `String` values are supported as message content, therefore we
use JSON serialized strings.

### Listening to messages from the test in the app

``` dart
enableFlutterDriverExtension(handler: dataHandler);
```
This code needs to be executed before `runApp()`.

### Helper classes

`DriverDataHandler` is a helper class that deserializes received
messages and serializes responses.

`TestControlMessage` is another helper class that ensures the message
conforms to some minimal structure. For example that a test name is
passed.  
It additionally supports a `Map<String, dynamic>` as `payload` that
allows any JSON-serializable value.

`TestDispatcher` is a minimal application widget that invokes tests
depending on the name in the received message.

A mapping from test name to a test widget factory needs to be passed
to `lib.main(...)`.

Example:

``` dart
final testFactory = <String, TestFactory>{
  TestName.platformAndAblyVersion: (d) => PlatformAndAblyVersionTest(d),
  TestName.appKeyProvisioning: (d) => AppKeyProvisionTest(d),
};

void main() => app.main(testFactory);
```

### Sending responses from the app to the test

When test code in the app is done, it needs to call `completeTest()`
with the response data to notify the test about the result.  
The response data again needs to be a JSON-serializable `Map<String,
dynamic>`.

Exceptions need to be handled by the test code in the app and
communicated to the test using the `completeTest()` method.

## Limitations
### Dependencies between tests
If an app contains multiple tests, they will have some dependency
between them, because the app is not restarted for each test which
results for example in the plugin to keep the state from the previous
test.

To have truly independent tests, each test needs to have its own
`xxx.dart` and `xxx_test.dart` file pair in the `test_driver/`
directory.
They can all call the same `lib/main.dart` though, because
for each `xxx_test.dart` file the app will be closed and restarted.

### One message and response per test
Currently sending a message from the driver test to the app starts a
new test and completing a test sends a response.

It would be possible to support multiple messages per test in both
directions, but it is not yet clear if this is actually required.

## Widget per test

This is an attempt to have a clean structure in apps with multiple
tests. Time should tell if this is a good approach.

## Improved development and debugging

See
https://medium.com/flutter-community/hot-reload-for-flutter-integration-tests-e0478b63bd54
for how to improve development performance by utilizing Hot
Reload/Restart for Driver tests
