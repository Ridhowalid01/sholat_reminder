abstract class ClockEvent {}

class Tick extends ClockEvent {
  final DateTime currentTime;
  Tick(this.currentTime);
}
