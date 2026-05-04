import 'package:calebh101_account_page/home.dart';
import 'package:calebh101_account_page/verify_email.dart';
import 'package:calebh101_server/calebh101_server.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

late ApiClient client;

void main() {
  client = Calebh101Client.setup(kDebugMode ? Calebh101Client.localBasePath() : Calebh101Client.publicBasePath);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calebh101 Account',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        "/": (context) => Home(),
        "/verifyEmail": (context) {
          final email = Uri.base.queryParameters["email"];
          final code = Uri.base.queryParameters["code"];
          final session = Uri.base.queryParameters["session"];
          return VerifyEmail(email: email, sessionId: session, verificationCode: code);
        },
      },
    );
  }
}