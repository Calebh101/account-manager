import 'package:calebh101_account_page/dialogues.dart';
import 'package:calebh101_account_page/main.dart';
import 'package:calebh101_server_flutter/calebh101_server_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localpkg_flutter/localpkg.dart';
import 'package:ua_parser/ua_parser.dart';

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
                  Text("${data?.email}!").fontSize(24),
                  SizedBox(height: 20),
                  SelectableText("Account created: ${DateFormat("MMM d, y @ h:mm a").format(data!.created.toLocal())}"),
                  SelectableText("Account updated: ${DateFormat("MMM d, y @ h:mm a").format(data!.updated.toLocal())}"),
                  SelectableText("Current session ID: ${prefs.getString("authentication") ?? client.defaultHeaderMap["Authentication"] ?? "No ID"}"),
                  SizedBox(height: 20),
                  ElevatedButton(onPressed: () async {
                    await context.navigator.push(MaterialPageRoute(builder: (context) => SessionPage(sessions: sessions, currentSafeId: data!.currentSafeId)));
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
  final String currentSafeId;

  const SessionPage({super.key, required this.sessions, required this.currentSafeId});

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  @override
  Widget build(BuildContext context) {
    final sessions = widget.sessions.sorted((a, b) => b.used.compareTo(a.used));

    return Scaffold(
      appBar: AppBar(title: Text("${sessions.length} Sessions")),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            spacing: 24,
            children: sessions.map((x) => SessionWidget(session: x, currentSafeId: widget.currentSafeId)).toList(),
          ),
        ),
      ),
    );
  }
}

class SessionWidget extends StatefulWidget {
  final AccountDetailsPost200ResponseDataSessionsInner session;
  final String currentSafeId;

  const SessionWidget({super.key, required this.session, required this.currentSafeId});

  @override
  State<SessionWidget> createState() => _SessionWidgetState();
}

class _SessionWidgetState extends State<SessionWidget> {
  @override
  Widget build(BuildContext context) {
    final ua = tryCatch(() => UaParser.parse(widget.session.userAgent!));
    final session = widget.session;
    final location = session.location;

    void show() {
      final _context = context;

      showModalBottomSheet(
        context: context,
        builder: (context) => ListView(
          shrinkWrap: true,
          children: [
            ListTile(title: Text('View Info'), onTap: () {
              SimpleDialogue.show(context: context, title: "Session Info", content: SelectableText([
                "IP address: ${session.ip}",
                "User agent: ${session.userAgent}",
                "Safe ID: ${session.safeId}",
              ].join("\n")));
            }),
            ListTile(title: Text('Delete', style: TextStyle(color: Colors.redAccent)), onTap: () async {
              final confirm = await ConfirmationDialogue.show(context: context, title: "Are you sure?", description: "This device will be logged out immediately.");
              if (confirm != true) return;
              SnackBarManager.show(context, "Loading...");

              void pop({bool outer = true}) {
                if (context.mounted) Navigator.pop(context);
                if (outer && _context.mounted) Navigator.pop(_context);
              }

              final result = await request(() => DefaultApi(client).accountSessionDelete(accountSessionDeleteRequest: AccountSessionDeleteRequest(id: widget.session.safeId)));
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
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(onPressed: () {
          show();
        }, child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.currentSafeId == widget.session.safeId) SelectableText("This Session"),
              if (ua != null) ...[
                ...[
                  ?SelectableText([?ua.device.vendor, ?ua.device.model].nullIfEmpty?.join(" ") ?? "", style: TextStyle(fontSize: 20)).nullIfEmpty,
                  ?SelectableText([?ua.browser.major, ?ua.browser.name, ?ua.browser.version, ?ua.engine.name].nullIfEmpty?.join(" ") ?? "", style: TextStyle(fontSize: 16)).nullIfEmpty,
                  ?SelectableText([?ua.os.name, ?ua.os.version, ?ua.cpu.architecture].nullIfEmpty?.join(" ") ?? "", style: TextStyle(fontSize: 16)).nullIfEmpty,
                ].nullIfEmpty ?? [SelectableText("Unknown Device").fontSize(20)],
                SelectableText("IP address: ${widget.session.ip ?? "Unknown"}"),
              ] else ...[
                SelectableText("IP address: ${widget.session.ip ?? "Unknown"}", style: TextStyle(fontSize: 20))
              ],
              SizedBox(height: 10),
              SelectableText([?location.city, ?location.region, ?location.country].join(", ").nullIfEmpty ?? "No location found."),
              SizedBox(height: 10),
              SelectableText("Created: ${DateFormat("MMM d, y @ h:mm a").format(widget.session.created.toLocal())}"),
              SelectableText("Last used: ${DateFormat("MMM d, y @ h:mm a").format(widget.session.used.toLocal())}"),
              SelectableText("Expires: ${DateFormat("MMM d, y @ h:mm a").format(widget.session.expires.toLocal())}"),
            ],
          ),
        ), style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        )),
        SizedBox(width: 12),
        IconButton(onPressed: () {
          show();
        }, icon: Icon(Icons.more_vert), iconSize: 36),
      ],
    );
  }
}