// Automatic FlutterFlow imports
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// DO NOT REMOVE OR MODIFY THE CODE ABOVE!90

import 'package:intl/intl.dart';

class HorizontalDatePicker extends StatefulWidget {
  const HorizontalDatePicker({
    Key? key,
    this.width,
    this.height,
    required this.pageName, // 'start' or 'end'
  }) : super(key: key);

  final double? width;
  final double? height;
  final String pageName;

  @override
  _HorizontalDatePickerState createState() => _HorizontalDatePickerState();
}

class _HorizontalDatePickerState extends State<HorizontalDatePicker> {
  late DateTime selectedDate;
  late DateTime currentMonth;
  late ScrollController scrollController;
  late List<DateTime> monthDates;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    _initializeDate();
    _generateMonthDates();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  void _initializeDate() {
    final storedDate = _getAppStateDate();
    final tomorrow = DateTime.now().add(Duration(days: 1));

    // For end page, check if we should use start date as reference
    if (widget.pageName == 'end') {
      final startDate = FFAppState().ChoosedStartEventDate;
      if (startDate != null && startDate.isAfter(DateTime.now())) {
        // If stored end date exists and is valid, use it
        if (storedDate != null &&
            storedDate.isAfter(DateTime.now()) &&
            !storedDate.isBefore(startDate)) {
          selectedDate = storedDate;
        } else {
          // Otherwise, use start date as default
          selectedDate = startDate;
          _updateAppStateDate(selectedDate);
        }
        currentMonth = DateTime(selectedDate.year, selectedDate.month, 1);
        return;
      }
    }

    // Default behavior for start page or when no valid start date
    selectedDate = (storedDate != null && !storedDate.isBefore(tomorrow))
        ? storedDate
        : tomorrow;

    _updateAppStateDate(selectedDate);

    currentMonth = DateTime(selectedDate.year, selectedDate.month, 1);
  }

  DateTime? _getAppStateDate() {
    if (widget.pageName == 'start') {
      return FFAppState().ChoosedStartEventDate;
    } else if (widget.pageName == 'end') {
      return FFAppState().ChoosedEndEventDate;
    }
    return null;
  }

  void _updateAppStateDate(DateTime date) {
    FFAppState().update(() {
      if (widget.pageName == 'start') {
        FFAppState().ChoosedStartEventDate = date;
      } else if (widget.pageName == 'end') {
        FFAppState().ChoosedEndEventDate = date;
      }
    });
  }

  void _generateMonthDates() {
    monthDates = [];
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDay = DateTime(currentMonth.year, currentMonth.month + 1, 0);

    for (int i = 0; i < lastDay.day; i++) {
      monthDates.add(firstDay.add(Duration(days: i)));
    }
  }

  void _scrollToSelectedDate() {
    final storedDate = _getAppStateDate();
    if (monthDates.isNotEmpty && storedDate != null) {
      final selectedIndex = monthDates.indexWhere((date) =>
          date.day == storedDate.day &&
          date.month == storedDate.month &&
          date.year == storedDate.year);

      if (selectedIndex != -1) {
        final itemWidth = 60.0;
        final screenWidth = MediaQuery.of(context).size.width;
        final targetOffset =
            (selectedIndex * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

        scrollController.animateTo(
          targetOffset.clamp(0.0, scrollController.position.maxScrollExtent),
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _changeMonth(int direction) {
    final newMonth =
        DateTime(currentMonth.year, currentMonth.month + direction, 1);
    final today = DateTime.now();
    final currentMonthYear = DateTime(today.year, today.month, 1);

    if (direction == -1 && newMonth.isBefore(currentMonthYear)) return;

    setState(() {
      currentMonth = newMonth;
      _generateMonthDates();
    });

    final storedDate = _getAppStateDate();
    final tomorrow = DateTime(today.year, today.month, today.day + 1);

    if (storedDate != null &&
        storedDate.month == currentMonth.month &&
        storedDate.year == currentMonth.year &&
        !storedDate.isBefore(tomorrow)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedDate();
      });
    }
  }

  bool _isDateDisabled(DateTime date) {
    final today = DateTime.now();
    final tomorrow = DateTime(today.year, today.month, today.day + 1);

    // For start page: disable dates before tomorrow (allow tomorrow and future)
    if (widget.pageName == 'start') {
      return date.isBefore(tomorrow);
    }

    // For end page: disable dates before start date
    if (widget.pageName == 'end') {
      final startDate = FFAppState().ChoosedStartEventDate;
      if (startDate != null) {
        // Date must be >= start date (no comparison with today needed)
        // Only allow dates from start date onwards
        return date.isBefore(startDate);
      }
      // If no start date is selected, disable all dates
      // This forces user to select start date first
      return true;
    }

    return false;
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height ?? 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date',
            style: TextStyle(
              color: Color(0xFF0C0C0C),
              fontFamily: 'Manrope',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.3,
              letterSpacing: 0.07,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 20,
                height: 20,
                child: IconButton(
                  icon: Icon(Icons.chevron_left, size: 20),
                  onPressed: () => _changeMonth(-1),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 20, minHeight: 20),
                ),
              ),
              SizedBox(width: 32),
              Text(
                DateFormat('MMMM yyyy').format(currentMonth),
                style: TextStyle(
                  color: Color(0xFF264AFF),
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  letterSpacing: 0.07,
                ),
              ),
              SizedBox(width: 32),
              Container(
                width: 20,
                height: 20,
                child: IconButton(
                  icon: Icon(Icons.chevron_right, size: 20),
                  onPressed: () => _changeMonth(1),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 20, minHeight: 20),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: monthDates.length,
              itemBuilder: (context, index) {
                final date = monthDates[index];
                final storedDate = _getAppStateDate();
                final isDisabled = _isDateDisabled(date);

                final isSelected = storedDate != null &&
                    date.day == storedDate.day &&
                    date.month == storedDate.month &&
                    date.year == storedDate.year &&
                    !isDisabled;

                return GestureDetector(
                  onTap: () {
                    if (isDisabled) return;

                    setState(() {
                      selectedDate = date;
                    });

                    _updateAppStateDate(date);
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    padding: EdgeInsets.all(4),
                    margin: EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? Color(0xFF516EFF) : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color:
                            isSelected ? Colors.transparent : Color(0xFFE9EDFF),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('d').format(date),
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : isDisabled
                                    ? Colors.grey.shade400
                                    : Color(0xFF676767),
                            fontFamily: 'Manrope',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                            letterSpacing: 0.07,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          DateFormat('E').format(date),
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : isDisabled
                                    ? Colors.grey.shade400
                                    : Color(0xFF676767),
                            fontFamily: 'Manrope',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                            letterSpacing: 0.07,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
