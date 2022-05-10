class Clip {
  final int surahNumber;
  final int start;
  final int end;
  final String reciter;

  Clip({
    required this.surahNumber,
    required this.start,
    required this.end,
    this.reciter = 'سعد الغامدي',
  });
}
