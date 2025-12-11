import 'package:googleapis/calendar/v3.dart';
import 'package:google_sign_in/google_sign_in.dart' show GoogleSignIn;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

class CalendarService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [CalendarApi.calendarEventsScope],
  );

  // Mengembalikan String (Pesan Sukses atau Pesan Error)
  Future<String> insertEvent({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      // 1. Login
      await _googleSignIn.signIn();

      // 2. Auth Client
      var httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient == null) {
        return "Gagal: User membatalkan login atau client null.";
      }

      var calendarApi = CalendarApi(httpClient);

      // 3. Buat Event
      Event event = Event()
        ..summary = title
        ..description = description
        ..start = EventDateTime(dateTime: startTime, timeZone: "Asia/Jakarta")
        ..end = EventDateTime(dateTime: endTime, timeZone: "Asia/Jakarta");

      // 4. Kirim ke Google
      final result = await calendarApi.events.insert(event, 'primary');

      if (result.htmlLink != null) {
        return "SUKSES! Jadwal masuk.";
      } else {
        return "Aneh: Berhasil tapi tidak ada link.";
      }
    } catch (e) {
      // Kembalikan pesan error aslinya
      return "ERROR GOOGLE: $e";
    }
  }
}
