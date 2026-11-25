abstract interface class Clock {
  DateTime now();
}

final class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

final class FixedClock implements Clock {
  DateTime _currentTime;

  FixedClock(DateTime initialTime) : _currentTime = initialTime;

  @override
  DateTime now() => _currentTime;

  void setTime(DateTime time) {
    _currentTime = time;
  }

  void advance(Duration duration) {
    _currentTime = _currentTime.add(duration);
  }
}
