import 'package:flutter/material.dart';

class     Time

{
  int year;
  int month;
  int day;
  int hour;
  int minute;
  int second;

  Time({required this.year, required this.month, required this.day, required this.hour, required this.minute, required this.second});

  @override String toString() { return 'Year: $year, Month: $month, Day: $day, Hour: $hour, Minute: $minute, Second: $second'; }
}