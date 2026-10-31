import 'package:flutter/material.dart';

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
    home: const ParticipantsDashboard(),
  );
}

class ParticipantsDashboard extends StatefulWidget {
  const ParticipantsDashboard({super.key});

  @override
  State<ParticipantsDashboard> createState() => _ParticipantsDashboardState();
}

class _ParticipantsDashboardState extends State<ParticipantsDashboard> {
  final List<Participant> _participants = [];

  Future<void> _registerParticipant() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
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
                'Enter participant name to begin tracking trials and surveys.',
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
                  if (trimmed.isNotEmpty) {
                    Navigator.pop(context, trimmed);
                  }
                },
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
                        if (text.isNotEmpty) {
                          Navigator.pop(context, text);
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

    if (name != null && name.isNotEmpty && mounted) {
      setState(() {
        final id = 'P-${_participants.length + 1}';
        _participants.insert(
          0,
          Participant(
            id: id,
            name: name,
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
      title: const Text(
        'Participants',
        style: TextStyle(color: _ink, fontWeight: FontWeight.w700),
      ),
    ),
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
                      '${participant.events.length} event logs · ${participant.surveys.length} surveys',
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
