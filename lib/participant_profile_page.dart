import 'package:flutter/material.dart';

import 'event_sheet.dart';
import 'nasa_tlx.dart';
import 'participant.dart';

const _ink = Color(0xFF17243A);
const _muted = Color(0xFF7A8798);
const _blue = Color(0xFF356AE6);
const _pale = Color(0xFFF4F7FC);

class ParticipantProfilePage extends StatefulWidget {
  const ParticipantProfilePage({super.key, required this.participant});

  final Participant participant;

  @override
  State<ParticipantProfilePage> createState() => _ParticipantProfilePageState();
}

class _ParticipantProfilePageState extends State<ParticipantProfilePage> {
  Future<void> _addEventLog() async {
    final record = await Navigator.of(context).push<EventRecord>(
      MaterialPageRoute(
        builder: (_) => EventEntryPage(participantName: widget.participant.name),
      ),
    );
    if (record != null && mounted) {
      setState(() {
        widget.participant.events.insert(0, record);
      });
    }
  }

  Future<void> _addNasaTlx() async {
    final survey = await Navigator.of(context).push<SurveyRecord>(
      MaterialPageRoute(
        builder: (_) => SurveyPage(participantName: widget.participant.name),
      ),
    );
    if (survey != null && mounted) {
      setState(() {
        widget.participant.surveys.insert(0, survey);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final participant = widget.participant;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: _pale,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: _ink),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            participant.name,
            style: const TextStyle(color: _ink, fontWeight: FontWeight.w700),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(20, 6, 20, 14),
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
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: const Color(0xFFEAF0FF),
                          child: Text(
                            participant.name.trim().isEmpty
                                ? '?'
                                : participant.name.trim()[0].toUpperCase(),
                            style: const TextStyle(
                              color: _blue,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                participant.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: _ink,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${participant.events.length} event logs · ${participant.surveys.length} surveys',
                                style: const TextStyle(
                                  color: _muted,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _addEventLog,
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Add Event Log'),
                            style: FilledButton.styleFrom(
                              backgroundColor: _blue,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _addNasaTlx,
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Add NASA-TLX Survey'),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFEAF0FF),
                              foregroundColor: _blue,
                              minimumSize: const Size(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAEFF8),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: TabBar(
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0D000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: _ink,
                    unselectedLabelColor: _muted,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    tabs: [
                      Tab(text: 'Event Logs (${participant.events.length})'),
                      Tab(text: 'NASA-TLX (${participant.surveys.length})'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildEventsTab(context),
                    _buildSurveysTab(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventsTab(BuildContext context) {
    final events = widget.participant.events;
    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.route_rounded,
                  color: _blue,
                  size: 34,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No event logs yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap "Add Event Log" to record a navigation trial for this participant.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _muted, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final record = events[index];
        final trialNum = events.length - index;
        return Card(
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
                '#$trialNum',
                style: const TextStyle(
                  color: _blue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            title: Text(
              'Trial $trialNum · ${clockString(record.elapsed)}',
              style: const TextStyle(
                color: _ink,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${record.success ? 'Successful' : 'Over time'} · ${record.wrongTurns} wrong turns · ${record.mapChecks} map checks',
              style: const TextStyle(color: _muted),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: _muted,
            ),
            onTap: () => showEventDetailDialog(context, record),
          ),
        );
      },
    );
  }

  Widget _buildSurveysTab(BuildContext context) {
    final surveys = widget.participant.surveys;
    if (surveys.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  color: _blue,
                  size: 34,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No NASA-TLX surveys yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap "Add NASA-TLX Survey" to record task workload assessments.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _muted, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: surveys.length,
      itemBuilder: (context, index) {
        final survey = surveys[index];
        final surveyNum = surveys.length - index;
        return Card(
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
                '#$surveyNum',
                style: const TextStyle(
                  color: _blue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            title: Text(
              'Survey $surveyNum · ${survey.name}',
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
            onTap: () => showSurveyDetailDialog(context, survey),
          ),
        );
      },
    );
  }
}
