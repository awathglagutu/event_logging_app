import 'dart:async';

import 'package:flutter/material.dart';

const _ink = Color(0xFF17243A);
const _muted = Color(0xFF7A8798);
const _blue = Color(0xFF356AE6);
const _pale = Color(0xFFF4F7FC);
const _qualLabels = <String>[
  'Location clarity / Map readability',
  'Orientation / Directional confusion',
  'Route choice difficulty',
  'Arrival point recognition',
];

class EventRecord {
  EventRecord({
    this.databaseId,
    required this.name,
    required this.elapsed,
    required this.wrongTurns,
    required this.mapChecks,
    required this.interventions,
    required this.disruptions,
    required this.issues,
    required this.success,
    required this.checked,
    required this.explanation,
  });
  int? databaseId;
  final String name;
  final Duration elapsed;
  final int wrongTurns;
  final int mapChecks;
  final String interventions;
  final String disruptions;
  final String issues;
  final bool success;
  final List<bool> checked;
  final String explanation;
}

String clockString(Duration duration) {
  final minutes = duration.inMinutes.toString().padLeft(2, '0');
  final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

String _clock(Duration duration) => clockString(duration);

void showEventDetailDialog(BuildContext context, EventRecord record, {String matricNumber = ''}) =>
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      record.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const Text(
                'Event observation record',
                style: TextStyle(color: _muted),
              ),
              if (matricNumber.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Matric number  $matricNumber', style: const TextStyle(color: _muted)),
              ],
              const SizedBox(height: 14),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _detailGroup('Timer & outcome', [
                        'Completion time  ${_clock(record.elapsed)}',
                        'Success  ${record.success ? '✓' : '✕'}',
                      ]),
                      _detailGroup('Navigation Errors & Behaviors', [
                        'Wrong Turns  ${record.wrongTurns}',
                        'Hesitation & safe Map Checking  ${record.mapChecks}',
                      ]),
                      _detailGroup('Safety Stops & Environmental Disruptions', [
                        'Safety Interventions  ${_value(record.interventions)}',
                        'Disruptions  ${_value(record.disruptions)}',
                        'Application Issues  ${_value(record.issues)}',
                      ]),
                      _detailGroup('Visible frustrations', [
                        for (var i = 0; i < _qualLabels.length; i++)
                          '${record.checked[i] ? '✓' : '□'}  ${_qualLabels[i]}',
                        'Brief Explanation  ${_value(record.explanation)}',
                      ]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: _blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

class EventSheetPage extends StatefulWidget {
  const EventSheetPage({super.key});
  @override
  State<EventSheetPage> createState() => _EventSheetPageState();
}

class _EventSheetPageState extends State<EventSheetPage> {
  final List<EventRecord> _records = [];
  Future<void> _add() async {
    final result = await Navigator.of(context).push<EventRecord>(
      MaterialPageRoute(
        builder: (_) => const EventEntryPage(participantName: 'Participant'),
      ),
    );
    if (result != null && mounted) setState(() => _records.insert(0, result));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: _records.isEmpty
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
                      Icons.route_rounded,
                      color: _blue,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Your event observations',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add an event sheet to start recording a task.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _muted, height: 1.5),
                  ),
                ],
              ),
            ),
          )
        : ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            children: [
              const Text(
                'YOUR RECORDS',
                style: TextStyle(
                  color: _muted,
                  fontSize: 12,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              for (final record in _records)
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
                        record.name.isEmpty
                            ? '?'
                            : record.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: _blue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    title: Text(
                      record.name,
                      style: const TextStyle(
                        color: _ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Completion ${_clock(record.elapsed)} · ${record.success ? 'Successful' : 'Over time'}',
                      style: const TextStyle(color: _muted),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: _muted,
                    ),
                    onTap: () => showEventDetailDialog(context, record),
                  ),
                ),
            ],
          ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _add,
      backgroundColor: _blue,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Add record'),
    ),
  );
}

String _value(String value) => value.trim().isEmpty ? '—' : value;
Widget _detailGroup(String title, List<String> lines) => Padding(
  padding: const EdgeInsets.only(bottom: 15),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(color: _blue, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 7),
      for (final line in lines)
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text(line, style: const TextStyle(color: _ink, height: 1.35)),
        ),
    ],
  ),
);

class EventEntryPage extends StatefulWidget {
  const EventEntryPage({super.key, required this.participantName});

  final String participantName;

  @override
  State<EventEntryPage> createState() => _EventEntryPageState();
}

class _EventEntryPageState extends State<EventEntryPage> {
  final _interventions = TextEditingController();
  final _disruptions = TextEditingController();
  final _issues = TextEditingController();
  final _explanation = TextEditingController();
  final _watch = Stopwatch();
  Timer? _ticker;
  Duration _elapsed = Duration.zero;
  bool _running = false;
  bool _paused = false;
  bool _hasRun = false;
  bool _stopped = false;
  int _wrongTurns = 0;
  int _mapChecks = 0;
  final List<bool> _checked = List.filled(4, false);

  @override
  void dispose() {
    _ticker?.cancel();
    _interventions.dispose();
    _disruptions.dispose();
    _issues.dispose();
    _explanation.dispose();
    super.dispose();
  }

  void _start() {
    if (_stopped) return;
    if (_running) {
      _watch.stop();
      _ticker?.cancel();
      setState(() {
        _running = false;
        _paused = false;
        _stopped = true;
        _elapsed = _watch.elapsed;
      });
      return;
    }
    _watch.start();
    setState(() {
      _running = true;
      _paused = false;
      _hasRun = true;
    });
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (mounted) setState(() => _elapsed = _watch.elapsed);
    });
  }

  void _pause() {
    if (_running) {
      _watch.stop();
      _ticker?.cancel();
      setState(() {
        _running = false;
        _paused = true;
        _elapsed = _watch.elapsed;
      });
    } else if (_paused && !_stopped) {
      _watch.start();
      setState(() {
        _running = true;
        _paused = false;
      });
      _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) {
        if (mounted) setState(() => _elapsed = _watch.elapsed);
      });
    }
  }

  void _save() {
    if (!_stopped) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stop the timer before saving.')),
      );
      return;
    }
    Navigator.pop(
      context,
      EventRecord(
        name: widget.participantName,
        elapsed: _elapsed,
        wrongTurns: _wrongTurns,
        mapChecks: _mapChecks,
        interventions: _interventions.text,
        disruptions: _disruptions.text,
        issues: _issues.text,
        success: _elapsed < const Duration(minutes: 15),
        checked: List.of(_checked),
        explanation: _explanation.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeColor = _elapsed >= const Duration(minutes: 15)
        ? const Color(0xFFD94B4B)
        : _ink;
    final canObserve = _stopped && _hasRun;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _pale,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New event sheet',
          style: TextStyle(color: _ink, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _panel(
                          child: Column(
                            children: [
                              Text(
                                _clock(_elapsed),
                                style: TextStyle(
                                  color: timeColor,
                                  fontSize: 52,
                                  fontWeight: FontWeight.w700,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FilledButton.icon(
                                    onPressed: _stopped ? null : _start,
                                    icon: Icon(
                                      _running
                                          ? Icons.stop_rounded
                                          : Icons.play_arrow_rounded,
                                    ),
                                    label: Text(_running ? 'Stop' : 'Start'),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: _running
                                          ? const Color(0xFFD94B4B)
                                          : _blue,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: const Color(
                                        0xFFD5DCE7,
                                      ),
                                      minimumSize: const Size(126, 48),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton.filledTonal(
                                    onPressed: !_hasRun || _stopped
                                        ? null
                                        : _pause,
                                    tooltip: _paused
                                        ? 'Resume timer'
                                        : 'Pause timer',
                                    icon: Icon(
                                      _paused
                                          ? Icons.play_arrow_rounded
                                          : Icons.pause_rounded,
                                    ),
                                    style: IconButton.styleFrom(
                                      foregroundColor: _blue,
                                      backgroundColor: const Color(0xFFEAF0FF),
                                      disabledBackgroundColor: const Color(
                                        0xFFEDF0F4,
                                      ),
                                      disabledForegroundColor: const Color(
                                        0xFFB5BDC8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                !_hasRun
                                    ? 'Ready when you are'
                                    : _running
                                    ? 'Running...'
                                    : _stopped
                                    ? 'Stopped at ${_clock(_elapsed)}'
                                    : 'Paused at ${_clock(_elapsed)}',
                                style: const TextStyle(
                                  color: _muted,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _panel(
                          child: Opacity(
                            opacity: _hasRun ? 1 : 0.45,
                            child: IgnorePointer(
                              ignoring: !_hasRun,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _SectionTitle('Navigation Errors & Behaviors'),
                                  const SizedBox(height: 10),
                                  _CounterRow(label: 'Wrong Turns', value: _wrongTurns, onChanged: (v) => setState(() => _wrongTurns = v)),
                                  _CounterRow(label: 'Hesitation & safe Map Checking', value: _mapChecks, onChanged: (v) => setState(() => _mapChecks = v)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _panel(
                          child: Opacity(
                            opacity: _hasRun ? 1 : 0.45,
                            child: IgnorePointer(
                              ignoring: !_hasRun,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _SectionTitle('Safety Stops & Environmental Disruptions'),
                                  const SizedBox(height: 14),
                                  _textArea('Safety Interventions', _interventions),
                                  _textArea('Disruptions', _disruptions),
                                  _textArea('Application Issues', _issues),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _panel(
                          child: Opacity(
                            opacity: _hasRun ? 1 : 0.45,
                            child: IgnorePointer(
                              ignoring: !_hasRun,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              const _SectionTitle('Final Task Outcome'),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Success',
                                      style: TextStyle(color: _ink),
                                    ),
                                  ),
                                  Container(
                                    width: 48,
                                    height: 40,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      !_stopped
                                          ? '—'
                                          : _elapsed <
                                                const Duration(minutes: 15)
                                          ? '✓'
                                          : '✕',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            _elapsed >=
                                                    const Duration(
                                                      minutes: 15,
                                                    ) &&
                                                _stopped
                                            ? const Color(0xFFD94B4B)
                                            : _blue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Completion Time',
                                      style: TextStyle(color: _ink),
                                    ),
                                  ),
                                  Text(
                                    !_hasRun
                                        ? 'Not Started'
                                        : _running
                                        ? 'Running...'
                                        : _paused
                                        ? 'Paused · ${_clock(_elapsed)}'
                                        : _clock(_elapsed),
                                    style: const TextStyle(
                                      color: _blue,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _panel(
                          child: Opacity(
                            opacity: canObserve ? 1 : 0.48,
                            child: IgnorePointer(
                              ignoring: !canObserve,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _SectionTitle(
                                    'Qualitative Observation Notes',
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Visible frustrations',
                                    style: TextStyle(
                                      color: _ink,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  for (var i = 0; i < _qualLabels.length; i++)
                                    CheckboxListTile(
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      activeColor: _blue,
                                      value: _checked[i],
                                      title: Text(
                                        _qualLabels[i],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: _ink,
                                        ),
                                      ),
                                      onChanged: (v) => setState(
                                        () => _checked[i] = v ?? false,
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Brief Explanation',
                                    style: TextStyle(
                                      color: _ink,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _explanation,
                                    minLines: 2,
                                    maxLines: 4,
                                    decoration: _decoration(
                                      'Any comments, leave blank if none...',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: _buttonStyle(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: canObserve ? _save : null,
                          icon: const Icon(Icons.check_rounded, size: 18),
                          label: const Text('Confirm & Save'),
                          style: FilledButton.styleFrom(
                            backgroundColor: _blue,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFFD5DCE7),
                            disabledForegroundColor: Colors.white,
                            minimumSize: const Size(0, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(
      color: _ink,
      fontSize: 16,
      fontWeight: FontWeight.w700,
    ),
  );
}

class _CounterRow extends StatelessWidget {
  const _CounterRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: _ink)),
        ),
        IconButton(
          onPressed: value == 0 ? null : () => onChanged(value - 1),
          icon: const Icon(Icons.remove_rounded),
          style: IconButton.styleFrom(
            backgroundColor: value == 0
                ? const Color(0xFFF0F2F6)
                : const Color(0xFFEAF0FF),
            foregroundColor: value == 0 ? const Color(0xFFB7C0CC) : _blue,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '$value',
            style: const TextStyle(
              color: _ink,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          onPressed: () => onChanged(value + 1),
          icon: const Icon(Icons.add_rounded),
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFFEAF0FF),
            foregroundColor: _blue,
          ),
        ),
      ],
    ),
  );
}

Widget _panel({required Widget child}) => Container(
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
  ),
  child: child,
);

InputDecoration _decoration(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(color: _muted),
  filled: true,
  fillColor: _pale,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide.none,
  ),
  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
);

Widget _textArea(String label, TextEditingController controller) => Padding(
  padding: const EdgeInsets.only(bottom: 14),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(color: _ink, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 7),
      TextField(
        controller: controller,
        minLines: 2,
        maxLines: 4,
        decoration: _decoration('Add details...'),
      ),
    ],
  ),
);

ButtonStyle _buttonStyle() => OutlinedButton.styleFrom(
  minimumSize: const Size(0, 52),
  foregroundColor: _ink,
  side: const BorderSide(color: Color(0xFFDCE3ED)),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
);
