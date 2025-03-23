import 'dart:async';

class CountdownService {
  Timer? _timer;
  final StreamController<Map<String, String>> _countdownController =
      StreamController<Map<String, String>>.broadcast();

  /// Expose the countdown stream
  Stream<Map<String, String>> get countdownStream =>
      _countdownController.stream;

  /// Start countdown based on start & end time
  void startCountdown(DateTime startTime, DateTime endTime) {
    _timer?.cancel(); // Cancel existing timer

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      DateTime now = DateTime.now();
      String status;
      String remainingTime;

      if (now.isBefore(startTime)) {
        // Before exam
        status = "Before";
        remainingTime = _formatTime(startTime.difference(now).inSeconds);
      } else if (now.isBefore(endTime)) {
        // During exam
        status = "Within";
        remainingTime = _formatTime(endTime.difference(now).inSeconds);
      } else {
        // Exam ended
        status = "End";
        remainingTime = "00:00:00";
        timer.cancel();
      }

      _countdownController.add({
        "status": status,
        "remainingTime": remainingTime,
      });
    });
  }

  /// Convert seconds to HH:MM:SS format
  String _formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    return "${_twoDigits(hours)}:${_twoDigits(minutes)}:${_twoDigits(seconds)}";
  }

  /// Ensure two-digit formatting
  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  /// Stop the countdown
  void stopCountdown() {
    _timer?.cancel();
  }

  /// Dispose resources
  void dispose() {
    _timer?.cancel();
    _countdownController.close();
  }
}
