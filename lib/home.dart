import 'package:calebh101_account_page/dialogues.dart';
import 'package:calebh101_account_page/main.dart';
import 'package:calebh101_server_flutter/calebh101_server_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
      await context.navigator.push(MaterialPageRoute(builder: (context) => LoginPage(client: client)));
      fetch();
    };

    final result = await request(() => api.accountDetailsPost());
    Logger.print("Home", "Response: ${result.runtimeType}");
    if (result == null) return;
    data = result.t?.data;
    error = result.f?.message ?? (result.t == null ? "No response received" : null);
    setState(() {});
  }

  void reload() async {
    data = null;
    error = null;

    setState(() {});
    fetch();
  }

  @override
  void initState() {
    fetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: () {
            reload();
          }, icon: Icon(Icons.refresh)),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: data != null ? Builder(
            builder: (context) {
              final sessions = data!.sessions..sorted((a, b) => b.used.compareTo(a.used));

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Hey there,").fontSize(36),
                  Text("${data!.email}!").fontSize(24),
                  SizedBox(height: 20),
                  SelectableText("Account created: ${DateFormat("MMM d, y @ h:mm a").format(data!.created)}"),
                  SelectableText("Account updated: ${DateFormat("MMM d, y @ h:mm a").format(data!.updated)}"),
                  SelectableText("Current session ID: ${prefs.getString("authentication") ?? client.defaultHeaderMap["Authentication"] ?? "No ID"}"),
                  SizedBox(height: 20),
                  ElevatedButton(onPressed: () async {
                    await context.navigator.push(MaterialPageRoute(builder: (context) => SessionPage(sessions: sessions)));
                    reload();
                  }, child: Text("${sessions.length} Active ${Word.fromCount(sessions.length, singular: Word("Session"))}")),
                  SizedBox(height: 20),
                  TextButton(onPressed: () async {
                    await signOut(client);
                    reload();
                  }, child: Text("Sign Out")),
                  TextButton(onPressed: () async {
                    await showDialog(context: context, builder: (context) => EmailChangeDialogue());
                    reload();
                  }, child: Text("Change Email")),
                  TextButton(onPressed: () async {
                    await showDialog(context: context, builder: (context) => PasswordChangeDialogue());
                    reload();
                  }, child: Text("Change Password")),
                  TextButton(onPressed: () async {
                    await showDialog(context: context, builder: (context) => DeleteAccountDialogue());
                    reload();
                  }, child: Text("Delete Account", style: TextStyle(color: Colors.redAccent))),
                ],
              );
            }
          ) : (error != null ? Text("Error: $error") : CircularProgressIndicator()),
        ),
      ),
    );
  }
}

class SessionPage extends StatefulWidget {
  final List<AccountDetailsPost200ResponseDataSessionsInner> sessions;
  const SessionPage({super.key, required this.sessions});

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  @override
  Widget build(BuildContext context) {
    final sessions = widget.sessions;

    return Scaffold(
      appBar: AppBar(title: Text("${sessions.length} Sessions")),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            spacing: 24,
            children: sessions.map((x) => SessionWidget(session: x)).toList(),
          ),
        ),
      ),
    );
  }
}

class SessionWidget extends StatefulWidget {
  final AccountDetailsPost200ResponseDataSessionsInner session;
  const SessionWidget({super.key, required this.session});

  @override
  State<SessionWidget> createState() => _SessionWidgetState();
}

class _SessionWidgetState extends State<SessionWidget> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () {
      final _context = context;

      showModalBottomSheet(
        context: context,
        builder: (context) => ListView(
          shrinkWrap: true,
          children: [
            ListTile(title: Text('View ID'), onTap: () async {
              await SimpleDialogue.show(context: context, title: "ID", content: SelectableText(widget.session.id), copy: true);
            }),
            ListTile(title: Text('Delete', style: TextStyle(color: Colors.redAccent)), onTap: () async {
              final confirm = await ConfirmationDialogue.show(context: context, title: "Are you sure?", description: "This device will be logged out immediately.");
              if (confirm != true) return;
              SnackBarManager.show(context, "Loading...");

              void pop({bool outer = true}) {
                if (context.mounted) Navigator.pop(context);
                if (outer && _context.mounted) Navigator.pop(_context);
              }

              final result = await request(() => DefaultApi(client).accountSessionDelete(accountSessionDeleteRequest: AccountSessionDeleteRequest(id: widget.session.id)));
              if (result == null) return pop(outer: false);

              if (result.f != null) {
                SnackBarManager.show(context, "Unable to delete session: ${result.f!.message}");
                return;
              }

              if (result.t != null) {
                SnackBarManager.show(context, "Session deleted.");
                pop();
                return;
              }
            }),
            ListTile(title: Text('Cancel'), onTap: () => Navigator.pop(context)),
          ],
        ),
      );
    }, child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          SelectableText([?widget.session.ip, ?widget.session.userAgent].nullIfEmpty?.join(" ") ?? "No details", style: TextStyle(fontSize: 20)),
          SelectableText("Created: ${DateFormat("MMM d, y @ h:mm a").format(widget.session.created)}"),
          SelectableText("Last used: ${DateFormat("MMM d, y @ h:mm a").format(widget.session.used)}"),
          SelectableText("Expires: ${DateFormat("MMM d, y @ h:mm a").format(widget.session.expires)}"),
          if (widget.session.id == prefs.getString("authentication")) Text("This Session", style: TextStyle(color: Colors.amberAccent)),
          SelectableText(widget.session.id, style: TextStyle(fontSize: 8, color: Colors.grey)),
        ],
      ),
    ), style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ));
  }
}