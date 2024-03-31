import 'package:ably_flutter/ably_flutter.dart';
import 'package:meta/meta.dart';

/// Contains the device identity token and secret of a device.
///
/// `LocalDevice` extends [DeviceDetails].
@immutable
class LocalDevice extends DeviceDetails {
  /// A unique device secret generated by the Ably SDK.
  final String? deviceSecret;

  /// A unique device identity token used to communicate with APNS or FCM.
  final String? deviceIdentityToken;

  /// @nodoc
  /// Initializes an instance without any defaults
  LocalDevice({
    required DeviceDetails deviceDetails,
    this.deviceIdentityToken,
    this.deviceSecret,
  }) : super(
          clientId: deviceDetails.clientId,
          formFactor: deviceDetails.formFactor,
          id: deviceDetails.id,
          metadata: deviceDetails.metadata,
          platform: deviceDetails.platform,
          push: deviceDetails.push,
        );
}