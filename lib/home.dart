import 'package:calebh101_account_page/verify_email.dart';
import 'package:flutter/material.dart';
import 'package:localpkg_flutter/localpkg.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(onPressed: () {
          SimpleNavigator.navigate(context: context, page: VerifyEmail(), mode: NavigatorMode.pushReplacement);
        }, child: Text("Verify Email")),
      ),
    );
  }
}