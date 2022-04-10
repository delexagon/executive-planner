import 'package:intl/intl.dart';

DateFormat userDateFormat = DateFormat('M/d/yy');

extension TitleCase on String {
  String toTitleCase() {
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime? other) {
    if(other == null) {
      return false;
    }
    return year == other.year && month == other.month
        && day == other.day;
  }

  bool isSameMoment(DateTime? other) {
    if(other == null) {
      return false;
    }
    return other.isAtSameMomentAs(other);
  }
}
