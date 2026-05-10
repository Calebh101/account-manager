import 'package:calebh101_account_page/home.dart';
import 'package:calebh101_account_page/verify.dart';
import 'package:calebh101_server_flutter/calebh101_server_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:localpkg_flutter/localpkg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validators/validators.dart';

late ApiClient client;
late SharedPreferences prefs;
String? inputtedQueryPath;

void main() async {
  final path = kDebugMode ? Calebh101Client.localBasePath() : Calebh101Client.publicBasePath();
  Logger.print("main", "Using path: $path");
  WidgetsFlutterBinding.ensureInitialized();

  prefs = await SharedPreferences.getInstance();
  client = Calebh101Client.setup(path);

  await setAuth(client);
  runApp(kDebugMode ? DebugApp() : MyApp());
}

extension on String {
  String? get nullIfEmpty => isEmpty ? null : this;
}

class DebugApp extends StatefulWidget {
  const DebugApp({super.key});

  @override
  State<DebugApp> createState() => _DebugAppState();
}

class _DebugAppState extends State<DebugApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Selector',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Spacer(),
              Spacer(),
              Text(inputtedQueryPath ?? "Path not set"),
              Spacer(),
              ...["verifyEmail", "changeEmail1", "changeEmail2", "deleteAccount"].map((key) {
                return TextButton(onPressed: () {
                  inputtedQueryPath = key;
                  setState(() {});
                }, child: Text(key));
              }),
              Spacer(),
              TextButton(onPressed: () {
                inputtedQueryPath = null;
                setState(() {});
              }, child: Text("Reset")),
              TextButton(onPressed: () {
                runApp(MyApp());
              }, child: Text("Go")),
              Spacer(),
              Spacer(),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Widget? widget;
    final uri = Uri.base;
    final path = inputtedQueryPath ?? uri.queryParameters["p"]?.nullIfEmpty;
    Logger.print("App", "Found path: $path");

    if (path != null) {
      switch (path) {
        case "verifyEmail":
          widget = VerifyPage(
            "Verify Your Email", {
              "email": VerifyPageDetails(prettyName: "Email", validator: (input) {
                if (input == null || input.trim().isEmpty) return "Input cannot be empty.";
                if (!isEmail(input)) return "Please provide a valid email.";
                return null;
              }),
              "code": VerifyPageDetails(prettyName: "Verification Code", validator: (input) {
                if (input == null || input.trim().isEmpty) return "Input cannot be empty.";
                if (input.length != 6) return "Code must be 6 characters.";
                return null;
              }),
              "sessionId": VerifyPageDetails(prettyName: "Session ID", queryName: "session", validator: (input) {
                if (input == null || input.trim().isEmpty) return "Input cannot be empty.";
                if (input.length != 16) return "Code must be 16 characters.";
                return null;
              }),
            },
            query: uri.queryParameters,
            request: (context, api, parameters) async {
              SnackBarManager.show(context, "Loading...");
              final result = await request(() async => api.authVerifyUserPost(authVerifyUserPostRequest: AuthVerifyUserPostRequest(email: parameters["email"]!.value, code: parameters["code"]!.value, sessionId: parameters["sessionId"]!.value)));

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
              }
            },
          );

          break;
        case "changeEmail1":
          widget = VerifyPage(
            "Change Your Email", {
              "code": VerifyPageDetails(prettyName: "Verification Code", validator: (input) {
                if (input == null || input.trim().isEmpty) return "Input cannot be empty.";
                if (input.length != 6) return "Code must be 6 characters.";
                return null;
              }),
              "sessionId": VerifyPageDetails(prettyName: "Session ID", queryName: "session", validator: (input) {
                if (input == null || input.trim().isEmpty) return "Input cannot be empty.";
                if (input.length != 16) return "Code must be 16 characters.";
                return null;
              }),
            },
            query: uri.queryParameters,
            request: (context, api, parameters) async {
              SnackBarManager.show(context, "Loading...");
              final result = await request(() async => api.accountEmailChangeVerifyOldPost(accountEmailChangeVerifyOldPostRequest: AccountEmailChangeVerifyOldPostRequest(code: parameters["code"]!.value, session: parameters["sessionId"]!.value)));

              if (result?.t != null) {
                final t = result!.t!;
                if (context.mounted) SnackBarManager.show(context, t.message);
              } else if (result?.f != null) {
                final f = result!.f!;
                Logger.print("Verify", "Request failed: $f");
                if (context.mounted) SnackBarManager.show(context, f.message ?? "Email change not verified. Unknown error: ${f.e}");
              } else {
                Logger.print("Verify", "Request failed");
                if (context.mounted) SnackBarManager.show(context, "An unhandled error has occurred. We don't know if your request was verified or not.");
              }
            },
          );

          break;
        case "changeEmail2":
          widget = VerifyPage(
            "Change Your Email", {
              "code": VerifyPageDetails(prettyName: "Verification Code", validator: (input) {
                if (input == null || input.trim().isEmpty) return "Input cannot be empty.";
                if (input.length != 6) return "Code must be 6 characters.";
                return null;
              }),
              "sessionId": VerifyPageDetails(prettyName: "Session ID", queryName: "session", validator: (input) {
                if (input == null || input.trim().isEmpty) return "Input cannot be empty.";
                if (input.length != 16) return "Code must be 16 characters.";
                return null;
              }),
            },
            query: uri.queryParameters,
            request: (context, api, parameters) async {
              SnackBarManager.show(context, "Loading...");
              final result = await request(() async => api.accountEmailChangeVerifyNewPost(accountEmailChangeVerifyOldPostRequest: AccountEmailChangeVerifyOldPostRequest(code: parameters["code"]!.value, session: parameters["sessionId"]!.value)));

              if (result?.t != null) {
                final t = result!.t!;
                if (context.mounted) SnackBarManager.show(context, t.message);
              } else if (result?.f != null) {
                final f = result!.f!;
                Logger.print("Verify", "Request failed: $f");
                if (context.mounted) SnackBarManager.show(context, f.message ?? "Email change not verified. Unknown error: ${f.e}");
              } else {
                Logger.print("Verify", "Request failed");
                if (context.mounted) SnackBarManager.show(context, "An unhandled error has occurred. We don't know if your request was verified or not.");
              }
            },
          );

          break;
        case "deleteAccount":
          widget = VerifyPage(
            "Delete Your Account", {
              "code": VerifyPageDetails(prettyName: "Verification Code", validator: (input) {
                if (input == null || input.trim().isEmpty) return "Input cannot be empty.";
                if (input.length != 6) return "Code must be 6 characters.";
                return null;
              }),
              "sessionId": VerifyPageDetails(prettyName: "Session ID", queryName: "session", validator: (input) {
                if (input == null || input.trim().isEmpty) return "Input cannot be empty.";
                if (input.length != 16) return "Input must be 16 characters.";
                return null;
              }),
              "password": VerifyPageDetails(prettyName: "Password", queryName: "", validator: (input) {
                if (input == null || input.trim().isEmpty) return "Input cannot be empty.";
                return null;
              }),
            },
            button: "Delete",
            query: uri.queryParameters,
            request: (context, api, parameters) async {
              final confirm = await ConfirmationDialogue.show(context: context, title: "Are you sure?", description: "This is immediate, destructive, and cannot be undone.\n\nIf you click yes, your account will immediately be deleted.");
              if (confirm != true) return;
              SnackBarManager.show(context, "Loading...");

              final result = await request(() async => api.accountVerifyDelete(accountVerifyDeleteRequest: AccountVerifyDeleteRequest(code: parameters["code"]!.value, session: parameters["sessionId"]!.value, password: parameters["password"]!.value, iAmCompletelySureThatIWantToDoThisAndIKnowIWillHaveNoRegretsWhatsoeverAndIfIDoIKnowIAmCompletelyLiableForThisAndIAcknowledgeThatAllMyDataAndEverythingWillAlsoBeDeletedAndIWillDefinitelyNotRegretThisAndIfIDoIKnowIAmCompletelyLiableForThis: true)));

              if (result?.t != null) {
                final t = result!.t!;
                if (context.mounted) SnackBarManager.show(context, t.message);
              } else if (result?.f != null) {
                final f = result!.f!;
                Logger.print("Verify", "Request failed: $f");
                if (context.mounted) SnackBarManager.show(context, f.message ?? "Account not deleted. Unknown error: ${f.e}");
              } else {
                Logger.print("Verify", "Request failed");
                if (context.mounted) SnackBarManager.show(context, "An unhandled error has occurred. We don't know if your account was deleted or not.");
              }
            },
          );

          break;
      }
    }

    widget ??= const Home();

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