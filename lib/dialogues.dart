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
  final key = GlobalKey<FormState>();
  FormState get state => key.currentState!;

  TextEditingController oldPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Change Password"),
      content: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
              key: key,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: oldPassword,
                    decoration: InputDecoration(
                      labelText: "Old Password",
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return "Value cannot be empty.";
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: newPassword,
                    decoration: InputDecoration(
                      labelText: "New Password",
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return "Value cannot be empty.";
                      if (value.length < 8) return "Password must be at least 8 characters long.";
                      return null;
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                Logger.print("ChangePassword", "Requesting...");
                if (!state.validate()) return;
                SnackBarManager.show(context, "Loading...");

                final api = DefaultApi(client);
                final result = await request(() async => api.accountPasswordPut(accountPasswordPutRequest: AccountPasswordPutRequest(old: oldPassword.text, new_: newPassword.text)));

                if (result?.t != null) {
                  final t = result!.t!;
                  if (context.mounted) SnackBarManager.show(context, t.message);
                  if (context.mounted) context.navigator.pop();
                } else if (result?.f != null) {
                  final f = result!.f!;
                  Logger.print("ChangePassword", "Request failed: $f");
                  if (context.mounted) SnackBarManager.show(context, f.message ?? "Password not changed. Unknown error: ${f.e}");
                } else {
                  Logger.print("ChangePassword", "Request failed");
                  if (context.mounted) SnackBarManager.show(context, "An unhandled error has occurred. We don't know if your password was changed or not.");
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

class DeleteAccountDialogue extends StatefulWidget {
  const DeleteAccountDialogue({super.key});

  @override
  State<DeleteAccountDialogue> createState() => _DeleteAccountDialogueState();
}

class _DeleteAccountDialogueState extends State<DeleteAccountDialogue> {
  final key = GlobalKey<FormState>();
  FormState get state => key.currentState!;

  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Delete Account"),
      content: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Note: This is a destructive action that cannot be undone."),
            SizedBox(height: 10),
            Form(
              key: key,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: password,
                    decoration: InputDecoration(
                      labelText: "Password",
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return "Value cannot be empty.";
                      return null;
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                Logger.print("Delete", "Requesting...");
                if (!state.validate()) return;
                SnackBarManager.show(context, "Loading...");

                final api = DefaultApi(client);
                final result = await request(() async => api.accountDelete(accountDeleteRequest: AccountDeleteRequest(password: password.text)));

                if (result?.t != null) {
                  final t = result!.t!;
                  if (context.mounted) SnackBarManager.show(context, t.message);
                  if (context.mounted) context.navigator.pop();
                } else if (result?.f != null) {
                  final f = result!.f!;
                  Logger.print("Delete", "Request failed: $f");
                  if (context.mounted) SnackBarManager.show(context, f.message ?? "Email not sent. Unknown error: ${f.e}");
                } else {
                  Logger.print("Delete", "Request failed");
                  if (context.mounted) SnackBarManager.show(context, "An unhandled error has occurred. We don't know if an email was sent or not.");
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