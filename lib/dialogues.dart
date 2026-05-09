import 'package:calebh101_account_page/main.dart';
import 'package:calebh101_server_flutter/calebh101_server_flutter.dart';
import 'package:flutter/material.dart';
import 'package:localpkg_flutter/dialogue.dart';
import 'package:localpkg_flutter/functions.dart';
import 'package:validators/validators.dart';

class EmailChangeDialogue extends StatefulWidget {
  const EmailChangeDialogue({super.key});

  @override
  State<EmailChangeDialogue> createState() => _EmailChangeDialogueState();
}

class _EmailChangeDialogueState extends State<EmailChangeDialogue> {
  final key = GlobalKey<FormState>();
  FormState get state => key.currentState!;

  TextEditingController newEmailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Change Email"),
      content: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
              key: key,
              child: TextFormField(
                controller: newEmailController,
                decoration: InputDecoration(
                  labelText: "New Email",
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return "Value cannot be empty.";
                  if (!isEmail(value)) return "Please provide a valid email.";
                  return null;
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                Logger.print("ChangeEmail", "Requesting...");
                if (!state.validate()) return;
                SnackBarManager.show(context, "Loading...");

                final api = DefaultApi(client);
                final result = await request(() async => api.accountEmailChangePost(accountEmailChangePostRequest: AccountEmailChangePostRequest(email: newEmailController.text)));

                if (result?.t != null) {
                  final t = result!.t!;
                  if (context.mounted) SnackBarManager.show(context, t.message);
                  if (context.mounted) context.navigator.pop();
                } else if (result?.f != null) {
                  final f = result!.f!;
                  Logger.print("ChangeEmail", "Request failed: $f");
                  if (context.mounted) SnackBarManager.show(context, f.message ?? "Email not verified. Unknown error: ${f.e}");
                } else {
                  Logger.print("ChangeEmail", "Request failed");
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
              child: Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}

class PasswordChangeDialogue extends StatefulWidget {
  const PasswordChangeDialogue({super.key});

  @override
  State<PasswordChangeDialogue> createState() => _PasswordChangeDialogueState();
}

class _PasswordChangeDialogueState extends State<PasswordChangeDialogue> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class DeleteAccountDialogue extends StatefulWidget {
  const DeleteAccountDialogue({super.key});

  @override
  State<DeleteAccountDialogue> createState() => _DeleteAccountDialogueState();
}

class _DeleteAccountDialogueState extends State<DeleteAccountDialogue> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}