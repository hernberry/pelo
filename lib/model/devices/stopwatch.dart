import 'dart:core' as core;
import 'dart:async';

class Stopwatch {
  final core.Stopwatch stopwatch = core.Stopwatch();
  Timer _timer;

  final core.Function onUpdate;

  Stopwatch(this.onUpdate);

  void _onTick(Timer timer) {
    onUpdate(stopwatch.elapsed);
  }

  void start() {
    stopwatch.start();
    _timer = Timer.periodic(core.Duration(milliseconds: 100), _onTick);
  }

  void stop() {
    stopwatch.stop();
    _timer.cancel();
    _timer = null;
  }
}