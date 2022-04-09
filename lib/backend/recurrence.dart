
class Break {
  Break(this.year, this.month, this.day, this.hour, this.minute);

  int year = 0;
  int month = 0;
  int day = 0;
  int hour = 0;
  int minute = 0;
}

class Recurrence {
  Recurrence(this.spacing);

  Break spacing;

  DateTime getNextRecurrence(DateTime now) {
    return DateTime(
      now.year+spacing.year, now.month+spacing.month, now.day+spacing.day,
      now.hour+spacing.hour, now.minute+spacing.minute,);
  }

  @override
  String toString() {
    final StringBuffer str = StringBuffer('Event recurs every ');
    if(spacing.year > 0) {
      str.write('${spacing.year} years, ');
    }
    if(spacing.month > 0) {
      str.write('${spacing.month} months, ');
    }
    if(spacing.day > 0) {
      str.write('${spacing.day} days, ');
    }
    if(spacing.hour > 0) {
      str.write('${spacing.hour} hours, ');
    }
    if(spacing.minute > 0) {
      str.write('${spacing.minute} minutes, ');
    }

    return '${str.toString().substring(0,str.length-2)}.';
  }
}