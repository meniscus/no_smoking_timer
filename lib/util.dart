extension DurationFormatter on Duration {
  String toHMS() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(inHours)}:'
           '${twoDigits(inMinutes.remainder(60))}:'
           '${twoDigits(inSeconds.remainder(60))}';
  }
}