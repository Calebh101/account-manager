import 'package:calebh101_account_page/main.dart';
import 'package:calebh101_account_page/verify_email.dart';
import 'package:calebh101_server/calebh101_server.dart';
import 'package:flutter/material.dart';
import 'package:localpkg_flutter/localpkg.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final api = DefaultApi(client);

  String? error;
  AccountDetailsPost200ResponseData? data;

  Future<void> fetch() async {
    onNeedsLogin = (e) {};

    final result = await request(() => api.accountDetailsPost());
    if (result == null) return;
    data = result.t?.data;
    error = result.f?.message ?? (result.t == null ? "No response received" : null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("This application is not finished yet.", softWrap: true),
              Text("To verify your email with Calebh101 Services, press the button below.", softWrap: true),
              TextButton(onPressed: () {
                SimpleNavigator.navigate(context: context, page: VerifyEmail(), mode: NavigatorMode.pushReplacement);
              }, child: Text("Verify Email")),
            ],
          ),
        ),
      ),
    );
  }
}