
class Break {
  Break({int year = 0, int month = 0, int week = 0, int day = 0, int hour = 0, int minute = 0}) {
    times = [year, month, week, day, hour, minute];
  }

  static final List<String> timeStrs = ['Year', 'Month', 'Week', 'Day', 'Hour', 'Minute'];
  List<int> times = [0, 0, 0, 0, 0, 0];

  DateTime add(DateTime date) {
    return DateTime(
      date.year+times[0], date.month+times[1], date.day+times[2]*7+times[3],
      date.hour+times[4], date.minute+times[5],);
  }
}

class Recurrence {
  Recurrence({Break? spacing}) {
    if(spacing != null) {
      this.spacing = spacing;
    }
  }

  Break spacing = Break();

  DateTime getNextRecurrence(DateTime now) {
    return spacing.add(now);
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