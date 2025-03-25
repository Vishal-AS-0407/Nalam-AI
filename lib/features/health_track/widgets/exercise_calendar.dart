import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ExerciseCalendar extends StatefulWidget {
  const ExerciseCalendar({super.key});

  @override
  _ExerciseCalendarState createState() => _ExerciseCalendarState();
}

class _ExerciseCalendarState extends State<ExerciseCalendar> {
  late ValueNotifier<List<DateTime>> _selectedDays;
  final CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDays = ValueNotifier([DateTime.now()]);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TableCalendar(
          firstDay: DateTime.utc(2020, 01, 01),
          lastDay: DateTime.utc(2024, 12, 31),
          focusedDay: DateTime.now().isAfter(DateTime.utc(2024, 12, 31))
              ? DateTime.utc(
                  2024, 12, 31) // Use lastDay if today is beyond lastDay
              : DateTime.now(),
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) {
            return _selectedDays.value.contains(day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              if (_selectedDays.value.contains(selectedDay)) {
                _selectedDays.value.remove(selectedDay);
              } else {
                _selectedDays.value.add(selectedDay);
              }
            });
          },
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006D77),
            ),
            leftChevronIcon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/icons/back.png', // Replace with your "previous" icon path
                width: 16,
                height: 16,
              ),
            ),
            rightChevronIcon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/icons/next.png', // Replace with your "next" icon path
                width: 16,
                height: 16,
              ),
            ),
          ),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Color(0xFF94D2BD),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Color(0xFF005F73),
              shape: BoxShape.circle,
            ),
            outsideDaysVisible: false,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _selectedDays.dispose();
    super.dispose();
  }
}
