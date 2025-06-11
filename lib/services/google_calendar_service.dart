import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'google_http_client.dart';

class GoogleCalendarService {
  late final calendar.CalendarApi _calendarApi;
  late final GoogleHttpClient _client;

  // Initialize the calendar service with auth headers
  Future<void> init(Map<String, String> headers) async {
    _client = GoogleHttpClient(headers);
    _calendarApi = calendar.CalendarApi(_client);
  }

  // Insert a new event
  Future<void> insertEvent(String title, DateTime startTime) async {
    try {
      final event = calendar.Event(
        summary: title,
        start: calendar.EventDateTime(
          dateTime: startTime,
          timeZone: 'Asia/Jakarta',
        ),
        end: calendar.EventDateTime(
          dateTime: startTime.add(const Duration(hours: 1)),
          timeZone: 'Asia/Jakarta',
        ),
      );

      await _calendarApi.events.insert(event, 'primary');
    } catch (e) {
      throw 'Gagal menambahkan event: $e';
    }
  }

  // Get today's events
  Future<List<String>> getTodayEvents() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final events = await _calendarApi.events.list(
        'primary',
        timeMin: startOfDay.toUtc(),
        timeMax: endOfDay.toUtc(),
        orderBy: 'startTime',
        singleEvents: true,
      );

      final titles = <String>[];
      if (events.items != null) {
        for (var event in events.items!) {
          if (event.summary != null) {
            titles.add(event.summary!);
          }
        }
      }
      return titles;
    } catch (e) {
      throw 'Gagal mengambil events: $e';
    }
  }

  // Dispose the client
  void dispose() {
    _client.close();
  }
}

// Custom AuthClient to handle authentication
class AuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client;

  AuthClient(this._headers, this._client);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }

  @override
  void close() {
    _client.close();
  }
} 