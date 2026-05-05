import 'package:calebh101_account_page/home.dart';
import 'package:calebh101_account_page/verify_email.dart';
import 'package:calebh101_server_flutter/calebh101_server_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

late ApiClient client;
late SharedPreferences prefs;

void main() async {
  final path = kDebugMode ? Calebh101Client.localBasePath() : Calebh101Client.publicBasePath();
  Logger.print("main", "Using path: $path");
  WidgetsFlutterBinding.ensureInitialized();

  prefs = await SharedPreferences.getInstance();
  client = Calebh101Client.setup(path);

  await setAuth(client);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    late Widget widget;
    final uri = Uri.base;

    if (uri.queryParameters.containsKey("verifyEmail")) {
      widget = VerifyEmail(
        email: uri.queryParameters["email"],
        sessionId: uri.queryParameters["session"],
        verificationCode: uri.queryParameters["code"],
      );
    } else {
      widget = const Home();
    }

    return MaterialApp(
      title: 'Calebh101 Account',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: widget,
    );
  }
}

extension NullIfEmpty<T> on Iterable<T> {
  Iterable<T>? get nullIfEmpty => isEmpty ? null : this;
}