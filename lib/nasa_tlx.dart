import 'package:flutter/material.dart';

const _ink = Color(0xFF17243A);
const _muted = Color(0xFF7A8798);
const _blue = Color(0xFF356AE6);
const _pale = Color(0xFFF4F7FC);

const _questions = <String>[
  'How mentally demanding was the task?',
  'How physically demanding was the task?',
  'How hurried or rushed was the pace of the task?',
  'How successful were you in accomplishing what you were asked to do?',
  'How hard did you have to work to accomplish your level of performance?',
  'How insecure, discouraged, irritated, stressed and annoyed were you?',
];

class SurveyRecord {
  SurveyRecord(this.name, this.values, {this.databaseId, this.application, this.route});
  int? databaseId;
  final String name;
  final List<int> values;
  final String? application;
  final String? route;
}

void showSurveyDetailDialog(BuildContext context, SurveyRecord record, {String matricNumber = ''}) =>
    showDialog<void>(
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
                    tooltip: 'Close',
                  ),
                ],
              ),
              const Text('Task load responses', style: TextStyle(color: _muted)),
              const SizedBox(height: 10),
              Text('Application  ${record.application ?? '—'}', style: const TextStyle(color: _ink)),
              const SizedBox(height: 4),
              Text('Route  ${record.route ?? '—'}', style: const TextStyle(color: _ink)),
              if (matricNumber.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Matric number  $matricNumber', style: const TextStyle(color: _muted)),
              ],
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (var i = 0; i < _questions.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  _questions[i],
                                  style: const TextStyle(
                                    color: _ink,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${record.values[i]}%',
                                style: const TextStyle(
                                  color: _blue,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
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

class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});
  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  // Records live for the lifetime of this app process.
  final List<SurveyRecord> _records = [];

  Future<void> _addRecord() async {
    final record = await Navigator.of(context).push<SurveyRecord>(
      MaterialPageRoute(
        builder: (_) => const SurveyPage(participantName: 'Participant'),
      ),
    );
    if (record != null && mounted) setState(() => _records.insert(0, record));
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
                      Icons.insights_rounded,
                      color: _blue,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Your task reflections',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add a response to see your NASA Task Load Index records here.',
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
                'YOUR RECORDS',
                style: TextStyle(
                  color: _muted,
                  fontSize: 12,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < _records.length; i++)
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
                        _records[i].name.trim().isEmpty
                            ? '?'
                            : _records[i].name.trim()[0].toUpperCase(),
                        style: const TextStyle(
                          color: _blue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    title: Text(
                      _records[i].name,
                      style: const TextStyle(
                        color: _ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      '6 responses · Task Load Index',
                      style: TextStyle(color: _muted),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: _muted,
                    ),
                    onTap: () => showSurveyDetailDialog(context, _records[i]),
                  ),
                ),
            ],
          ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _addRecord,
      backgroundColor: _blue,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Add record'),
    ),
  );
}

class SurveyPage extends StatefulWidget {
  const SurveyPage({super.key, required this.participantName, this.application, this.route});

  final String participantName;
  final String? application;
  final String? route;

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  // This map retains all answers while moving back and forth through the form.
  final Map<int, int> _answers = {
    for (var i = 0; i < _questions.length; i++) i: 0,
  };
  int _step = 0; // Starts directly on Question 1 (index 0)

  void _continue() {
    if (_step < _questions.length - 1) {
      setState(() => _step++);
    }
  }

  void _previous() {
    if (_step > 0) {
      setState(() => _step--);
    }
  }

  void _finish() => Navigator.of(context).pop(
    SurveyRecord(
      widget.participantName,
      List.generate(_questions.length, (i) => _answers[i] ?? 0),
      application: widget.application,
      route: widget.route,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final questionIndex = _step;
    final progress = (questionIndex + 1) / _questions.length;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _pale,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New assessment',
          style: TextStyle(color: _ink, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'QUESTION ${questionIndex + 1} OF ${_questions.length}',
                              style: const TextStyle(
                                color: _blue,
                                fontSize: 12,
                                letterSpacing: 1.3,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${(progress * 100).round()}%',
                              style: const TextStyle(
                                color: _muted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: const Color(0xFFE3E9F2),
                            color: _blue,
                          ),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          _questions[questionIndex],
                          style: const TextStyle(
                            fontSize: 30,
                            height: 1.2,
                            letterSpacing: -0.5,
                            fontWeight: FontWeight.w700,
                            color: _ink,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Rate your experience with this task.',
                          style: TextStyle(
                            color: _muted,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 34),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Selected Value:',
                                    style: TextStyle(
                                      color: _muted,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${_answers[questionIndex]}%',
                                    style: const TextStyle(
                                      color: _blue,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 22,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Slider(
                                value: (_answers[questionIndex] ?? 0).toDouble(),
                                min: 0,
                                max: 100,
                                divisions: 20,
                                activeColor: _blue,
                                onChanged: (value) => setState(
                                  () => _answers[questionIndex] = value.round(),
                                ),
                              ),
                              const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Very Low',
                                    style: TextStyle(
                                      color: _muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'Very High',
                                    style: TextStyle(
                                      color: _muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Row(
                    children: [
                      if (questionIndex > 0) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _previous,
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              size: 18,
                            ),
                            label: const Text('Previous'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 52),
                              foregroundColor: _ink,
                              side: const BorderSide(color: Color(0xFFDCE3ED)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: questionIndex == _questions.length - 1
                              ? _finish
                              : _continue,
                          icon: Icon(
                            questionIndex == _questions.length - 1
                                ? Icons.check_rounded
                                : Icons.arrow_forward_rounded,
                            size: 18,
                          ),
                          label: Text(
                            questionIndex == _questions.length - 1
                                ? 'Finish'
                                : 'Next',
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: _blue,
                            foregroundColor: Colors.white,
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
