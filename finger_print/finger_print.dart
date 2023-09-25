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



class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                bool auth = await FingerPrintAuthentication.authentication();
                log("Authntication $auth");

              },
              icon: Icon(Icons.fingerprint),
              label: Text("Finger Print"),
            )
          ],
        ),
      ),
    );
  }
}
