import 'dart:async';
import 'dart:ui';

class Debouncer {
  Debouncer({this.duration = const Duration(milliseconds: 500)});
  final Duration duration;

  Timer? _debounceTimer;

  void call(VoidCallback callback) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(duration, callback);
  }

  dispose() {
    _debounceTimer?.cancel();
  }
}
