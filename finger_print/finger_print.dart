import 'dart:developer';

import 'package:local_auth/local_auth.dart';

class FingerPrintAuthentication {
  static final LocalAuthentication auth = LocalAuthentication();
  static Future<bool> canAuthenticate() async =>
      await auth.canCheckBiometrics || await auth.isDeviceSupported();

  static Future<bool> authentication() async {
    try {
      if (!await canAuthenticate()) return false;
      return await auth.authenticate(
          localizedReason: "For FInger Print Checking",
          options: AuthenticationOptions(
            stickyAuth: true,
            // biometricOnly: true,
          ));
    } catch (e) {
      log("Error $e");
      return false;
    }
  }
}
