
class Break {
  Break({int year = 0, int month = 0, int day = 0, int hour = 0, int minute = 0}) {
    times = [year, month, day, hour, minute];
  }

  static final List<String> timeStrs = ['Year', 'Month', 'Day', 'Hour', 'Minute'];
  List<int> times = [0, 0, 0, 0, 0];
}

class Recurrence {
  Recurrence({Break? spacing}) {
    if(spacing != null) {
      this.spacing = spacing;
    }
  }

  Break spacing = Break();

  DateTime getNextRecurrence(DateTime now) {
    return DateTime(
      now.year+spacing.times[0], now.month+spacing.times[1], now.day+spacing.times[2],
      now.hour+spacing.times[3], now.minute+spacing.times[4],);
  }

  @override
  String toString() {
    final StringBuffer str = StringBuffer('Event recurs every ');
    for(int i = 0; i < spacing.times.length; i++) {
      if(spacing.times[i] > 0) {
        str.write('${spacing.times[i]} ${Break.timeStrs[i].toLowerCase()}s, ');
      }
    }

    return '${str.toString().substring(0,str.length-2)}.';
  }
}