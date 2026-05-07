import 'dart:async';

import 'package:calebh101_account_page/main.dart';
import 'package:calebh101_server_flutter/calebh101_server_flutter.dart';
import 'package:flutter/material.dart';
import 'package:localpkg_flutter/localpkg.dart';

class VerifyPageDetails<T> {
  final String prettyName;
  final String? queryName;

  final T Function(String input)? parse;
  final String? Function(String? input)? validator;

  const VerifyPageDetails({required this.prettyName, this.queryName, this.parse, this.validator});

  T? tryParse(String input) {
    try {
      if (parse != null) return parse!(input);
      return input as T;
    } catch (e) {
      Logger.warn("VerifyPageDetails<$T>($queryName)", input);
      return null;
    }
  }

  String? validate(String? input) {
    if (validator != null) return validator!(input);
    return null;
  }
}

class VerifyPage extends StatefulWidget {
  final String what;
  final String button;
  final Map<String, VerifyPageDetails> parameters;
  final Map<String, String> query;
  final FutureOr<void> Function(BuildContext context, DefaultApi api, Map<String, ({VerifyPageDetails details, String value})> parameters) request;

  VerifyPage(this.what, this.parameters, {super.key, this.query = const {}, this.button = "Verify", required this.request});

  @override
  State<VerifyPage> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyPage> {
  final key = GlobalKey<FormState>();
  FormState get state => key.currentState!;

  Map<String, TextEditingController> controllers = {};
  TextEditingController getController(String key) => controllers[key]!;

  @override
  void initState() {
    for (final param in widget.parameters.entries) {
      controllers[param.key] = TextEditingController(text: widget.query[param.value.queryName ?? param.key]);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.what),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
              key: key,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...widget.parameters.entries.map((entry) {
                    final key = entry.key;
                    final details = entry.value;

                    return TextFormField(
                      controller: getController(key),
                      decoration: InputDecoration(
                        labelText: details.prettyName,
                      ),
                      validator: (value) => details.validate(value),
                    );
                  }),
                ],
              ),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () async {
                Logger.print("Verify", "Requesting...");
                if (!state.validate()) return;
                SnackBarManager.show(context, "Loading...");

                final api = DefaultApi(client);
                await widget.request.call(context, api, widget.parameters.map((k, v) => MapEntry(k, (value: getController(k).text, details: v))));
                /*final result = await request(() async => api.authVerifyUserPost(authVerifyUserPostRequest: AuthVerifyUserPostRequest(email: widget.email!, code: widget.verificationCode!, sessionId: widget.sessionId!)));

                if (result?.t != null) {
                  final t = result!.t!;
                  if (context.mounted) SnackBarManager.show(context, t.message);
                } else if (result?.f != null) {
                  final f = result!.f!;
                  Logger.print("Verify", "Request failed: $f");
                  if (context.mounted) SnackBarManager.show(context, f.message ?? "Email not verified. Unknown error: ${f.e}");
                } else {
                  Logger.print("Verify", "Request failed");
                  if (context.mounted) SnackBarManager.show(context, "An unhandled error has occurred. We don't know if your email was verified or not.");
                }*/
              },
              style: ElevatedButton.styleFrom(
                fixedSize: Size(150, 70),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: TextStyle(
                  fontSize: 20,
                ),
              ),
              child: Text(widget.button),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}