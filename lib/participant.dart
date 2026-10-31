import 'event_sheet.dart';
import 'nasa_tlx.dart';

class Participant {
  Participant({
    required this.id,
    required this.name,
    required this.matricNumber,
    List<EventRecord>? events,
    List<SurveyRecord>? surveys,
  })  : events = events ?? [],
        surveys = surveys ?? [];

  final String id;
  final String name;
  final String matricNumber;
  final List<EventRecord> events;
  final List<SurveyRecord> surveys;
}
