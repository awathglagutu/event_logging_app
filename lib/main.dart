import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'participant.dart';
import 'participant_profile_page.dart';

const _ink = Color(0xFF17243A);
const _muted = Color(0xFF7A8798);
const _blue = Color(0xFF356AE6);
const _pale = Color(0xFFF4F7FC);

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Fieldwork',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: _pale,
      colorScheme: ColorScheme.fromSeed(seedColor: _blue, surface: _pale),
      fontFamily: 'Roboto',
    ),
    home: const SplashPage(),
  );
}

const _observers = <String, String>{'Izzuan Iskandar': '306660', 'Adam Haris': '307106', 'Muhammad Syauqi': '307142', 'Muhammad Khuzaimi': '307261'};

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() { super.initState(); _routeFromSession(); }
  Future<void> _routeFromSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final active = (prefs.getString('observer_name') ?? '').isNotEmpty;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => active ? const ParticipantsDashboard() : const LoginPage()));
  }
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 88, height: 88, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)), child: const Icon(Icons.fact_check_rounded, color: _blue, size: 46)),
    const SizedBox(height: 18), const Text('Fieldwork', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: _ink)),
    const SizedBox(height: 18), const CircularProgressIndicator(color: _blue),
  ])));
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? _observer;
  final _password = TextEditingController();
  String? _error;
  InputDecoration _decoration(String hint) => InputDecoration(hintText: hint, filled: true, fillColor: _pale, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14));
  Future<void> _login() async {
    if (_observer == null || _password.text != 'admin123') { setState(() => _error = 'Select an observer and enter the correct password.'); return; }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('observer_name', _observer!);
    await prefs.setString('observer_matric', _observers[_observer!]!);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const ParticipantsDashboard()));
  }
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: Card(color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    const Icon(Icons.fact_check_rounded, size: 54, color: _blue), const SizedBox(height: 12),
    const Text('Observer Login', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: _ink)), const SizedBox(height: 24),
    DropdownButtonFormField<String>(value: _observer, decoration: _decoration('Select observer'), items: _observers.keys.map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(), onChanged: (value) => setState(() => _observer = value)),
    const SizedBox(height: 14), TextField(controller: _password, obscureText: true, onSubmitted: (_) => _login(), decoration: _decoration('Password')),
    if (_error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!, style: const TextStyle(color: Colors.red))), const SizedBox(height: 20),
    FilledButton(onPressed: _login, style: FilledButton.styleFrom(backgroundColor: _blue, foregroundColor: Colors.white, minimumSize: const Size(0, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: const Text('Login')),
  ])))))));
}

class ParticipantsDashboard extends StatefulWidget {
  const ParticipantsDashboard({super.key});

  @override
  State<ParticipantsDashboard> createState() => _ParticipantsDashboardState();
}

class _ParticipantsDashboardState extends State<ParticipantsDashboard> {
  final List<Participant> _participants = [];
  String _observerName = '';
  String _observerMatric = '';
  bool _drawerOpen = false;
  @override
  void initState() { super.initState(); _loadObserver(); }
  Future<void> _loadObserver() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() { _observerName = prefs.getString('observer_name') ?? ''; _observerMatric = prefs.getString('observer_matric') ?? ''; });
  }
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance(); await prefs.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
  }

  Future<void> _registerParticipant() async {
    final controller = TextEditingController();
    final matricController = TextEditingController();
    final registration = await showDialog<(String, String)>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'New Participant',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Close',
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Enter participant details to begin tracking trials and surveys.',
                style: TextStyle(color: _muted),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Participant name',
                  hintStyle: const TextStyle(color: _muted),
                  filled: true,
                  fillColor: _pale,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onSubmitted: (val) {
                  final trimmed = val.trim();
                  final matric = matricController.text.trim();
                  if (trimmed.isNotEmpty && matric.isNotEmpty) {
                    Navigator.pop(context, (trimmed, matric));
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: matricController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: 'Matric Number', hintStyle: const TextStyle(color: _muted),
                  filled: true, fillColor: _pale,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        foregroundColor: _ink,
                        side: const BorderSide(color: Color(0xFFDCE3ED)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        final text = controller.text.trim();
                        final matric = matricController.text.trim();
                        if (text.isNotEmpty && matric.isNotEmpty) {
                          Navigator.pop(context, (text, matric));
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: _blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Register'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (registration != null && mounted) {
      setState(() {
        final id = 'P-${_participants.length + 1}';
        _participants.insert(
          0,
          Participant(
            id: id,
            name: registration.$1,
            matricNumber: registration.$2,
          ),
        );
      });
    }
  }

  Future<void> _openProfile(Participant participant) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ParticipantProfilePage(participant: participant),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: _pale,
      elevation: 0,
      title: AnimatedPadding(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(left: _drawerOpen ? 180 : 0),
        child: const Text('Participants', style: TextStyle(color: _ink, fontSize: 28, fontWeight: FontWeight.w800)),
      ),
      leading: Builder(builder: (context) => IconButton(
        tooltip: 'Observer profile',
        icon: const Icon(Icons.menu_rounded, color: _ink, size: 28),
        onPressed: () => Scaffold.of(context).openDrawer(),
      )),
    ),
    onDrawerChanged: (opened) => setState(() => _drawerOpen = opened),
    drawer: Drawer(backgroundColor: _pale, child: SafeArea(child: Column(children: [
      const SizedBox(height: 36),
      const CircleAvatar(radius: 44, backgroundColor: Colors.white, child: Icon(Icons.person, size: 54, color: _blue)),
      const SizedBox(height: 18),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text(_observerName, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _ink))),
      const SizedBox(height: 6), Text(_observerMatric, style: const TextStyle(color: _muted)),
      const Spacer(),
      ListTile(leading: const Icon(Icons.logout_rounded, color: _blue), title: const Text('Logout', style: TextStyle(color: _ink, fontWeight: FontWeight.w600)), onTap: _logout),
      const SizedBox(height: 12),
    ]))),
    body: _participants.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.people_alt_rounded,
                      color: _blue,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No participants yet',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Register a participant to begin logging event sheets and NASA-TLX surveys.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _muted, height: 1.5),
                  ),
                ],
              ),
            ),
          )
        : ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            children: [
              const Text(
                'REGISTERED PARTICIPANTS',
                style: TextStyle(
                  color: _muted,
                  fontSize: 12,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              for (final participant in _participants)
                Card(
                  color: Colors.white,
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 7,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFEAF0FF),
                      child: Text(
                        participant.name.trim().isEmpty
                            ? '?'
                            : participant.name.trim()[0].toUpperCase(),
                        style: const TextStyle(
                          color: _blue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    title: Text(
                      participant.name,
                      style: const TextStyle(
                        color: _ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${participant.matricNumber} · ${participant.events.length} event logs · ${participant.surveys.length} surveys',
                      style: const TextStyle(color: _muted),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: _muted,
                    ),
                    onTap: () => _openProfile(participant),
                  ),
                ),
            ],
          ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _registerParticipant,
      backgroundColor: _blue,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.person_add_rounded),
      label: const Text('New participant'),
    ),
  );
}



