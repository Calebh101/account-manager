import 'package:calebh101_account_page/main.dart';
import 'package:calebh101_server/calebh101_server.dart';
import 'package:flutter/material.dart';
import 'package:localpkg_flutter/localpkg.dart';
import 'package:styled_logger/styled_logger.dart';
import 'package:validators/validators.dart';

class VerifyEmail extends StatefulWidget {
  String? email;
  String? sessionId;
  String? verificationCode;

  VerifyEmail({super.key, this.email, this.sessionId, this.verificationCode});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  late final String? defaultEmail;
  late final String? defaultSessionId;
  late final String? defaultVerificationCode;

  final key = GlobalKey<FormState>();
  FormState get state => key.currentState!;

  @override
  void initState() {
    defaultEmail = widget.email;
    defaultSessionId = widget.sessionId;
    defaultVerificationCode = widget.verificationCode;

    widget.email ??= "";
    widget.sessionId ??= "";
    widget.verificationCode ??= "";

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Verify Email for Calebh101 Services"),
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
                  TextFormField(
                    initialValue: widget.email,
                    decoration: InputDecoration(
                      labelText: ["Email", if (defaultSessionId != null) "(default: $defaultEmail)"].join(" "),
                    ),
                    onChanged: (value) {
                      widget.email = value;
                      setState(() {});
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Must not be empty.";
                      if (!isEmail(value)) return "Must be a valid email.";
                      return null;
                    },
                  ),
                  TextFormField(
                    initialValue: widget.sessionId,
                    decoration: InputDecoration(
                      labelText: ["Session ID", if (defaultSessionId != null) "(default: $defaultSessionId)"].join(" "),
                    ),
                    onChanged: (value) {
                      widget.sessionId = value;
                      setState(() {});
                    },
                    validator: (value) {
                      if (value?.length != 12) return "Must be 12 characters.";
                      return null;
                    },
                  ),
                  TextFormField(
                    initialValue: widget.verificationCode,
                    decoration: InputDecoration(
                      labelText: ["Verification Code", if (defaultVerificationCode != null) "(default: $defaultVerificationCode)"].join(" "),
                    ),
                    onChanged: (value) {
                      widget.verificationCode = value;
                      setState(() {});
                    },
                    validator: (value) {
                      if (value?.length != 6) return "Must be 6 characters.";
                      return null;
                    },
                  ),
                ],
              ),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () async {
                Logger.print("Requesting with email ${widget.email}");
                if (!state.validate()) return;
                SnackBarManager.show(context, "Loading...");

                final api = DefaultApi(client);
                final result = await request(() async => api.authVerifyUserPost(authVerifyUserPostRequest: AuthVerifyUserPostRequest(email: widget.email!, code: widget.verificationCode!, sessionId: widget.sessionId!)));

                if (result?.t != null) {
                  final t = result!.t!;
                  if (context.mounted) SnackBarManager.show(context, t.message ?? "Email verified.");
                } else if (result?.f != null) {
                  final f = result!.f!;
                  Logger.print("Request failed: $f");
                  if (context.mounted) SnackBarManager.show(context, f.message ?? "Email not verified. Unknown error: ${f.e}");
                } else {
                  Logger.print("Request failed");
                  if (context.mounted) SnackBarManager.show(context, "An unhandled error has occurred. We don't know if your email was verified or not.");
                }
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
              child: Text("Verify"),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}