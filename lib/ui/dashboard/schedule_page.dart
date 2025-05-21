import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  _SchedulePageState createState() => _SchedulePageState(); 
}

class _SchedulePageState extends State<SchedulePage> { 
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  final Map<DateTime, List<String>> _workoutSchedule = {
    DateTime.utc(2025, 5, 20): ['Push-ups', 'Running', 'Yoga'],
    DateTime.utc(2025, 5, 21): ['Pull-ups', 'Cycling'],
    DateTime.utc(2025, 5, 22): ['Squats', 'Swimming'],
  };

  List<String> _getWorkoutsForDay(DateTime day) {
    final normalizedDay = DateTime.utc(day.year, day.month, day.day);
    return _workoutSchedule[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: Text('Workout Schedule'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2020, 1, 1),
            lastDay: DateTime(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },

            /// 🔥 THIS enables dot indicators on workout days
            eventLoader: (day) {
              final normalizedDay = DateTime.utc(day.year, day.month, day.day);
              return _workoutSchedule[normalizedDay] ?? [];
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _getWorkoutsForDay(_selectedDay).isEmpty
                ? Center(
                    child: Text(
                      'No workouts scheduled for this day: \n$_selectedDay',
                      style: const TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: _getWorkoutsForDay(_selectedDay).length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.fitness_center),
                        title: Text(_getWorkoutsForDay(_selectedDay)[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}