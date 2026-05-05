import 'package:calebh101_account_page/main.dart';
import 'package:calebh101_account_page/verify_email.dart';
import 'package:calebh101_server/calebh101_server.dart';
import 'package:calebh101_server_flutter/calebh101_server_flutter.dart';
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
    onNeedsLogin = (e) async {
      SimpleNavigator.navigate(context: context, page: LoginPage(client: client), mode: NavigatorMode.pushReplacement);
    };

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
          child: data != null ? (Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Received data: ${data.runtimeType}", softWrap: true),
            ],
          )) : (error != null ? Text("Error: $error") : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
              TextButton(onPressed: () {
                SimpleNavigator.navigate(context: context, page: VerifyEmail(), mode: NavigatorMode.push);
              }, child: Text("Verify Email")),
            ],
          )),
        ),
      ),
    );
  }
}