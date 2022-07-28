import 'dart:io';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:GymBook/screens/screens.dart';
import 'package:GymBook/services/services.dart';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class PantallaCalendario extends StatefulWidget {
  const PantallaCalendario({Key? key}) : super(key: key);
  @override
  State<PantallaCalendario> createState() => _PantallaCalendarioState();
}

class _PantallaCalendarioState extends State<PantallaCalendario> {
  bool _isOscuro = false;

  Future<void> _initGetDetails() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final valor_isOscuro = await authService.readTheme();

    if (valor_isOscuro == 'OSCURO') {
      _isOscuro = true;
    } else {
      _isOscuro = false;
    }

  }

  @override
  void initState() {
    super.initState();
    _initGetDetails();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    CalendarFormat _calendarFormat = CalendarFormat.month;
    DateTime _focusedDay = DateTime.now();

    return FutureBuilder(
        future: authService.readTheme(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text('');
          }

          if (snapshot.data != '') {
            return SafeArea(
              child: Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                          splashRadius: 25,
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.leftToRight, child: AdministradorScreen(), duration: Duration(milliseconds: 250)));
                      }),
                  backgroundColor: Color.fromRGBO(71, 83, 97, 1),
                  elevation: 0,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: Text('CALENDARIO',
                            style: TextStyle(
                              color: Colors.white,
                            )),
                      ),
                    ],
                  ),
                ),
                body: Container(
                  color: (_isOscuro)
                    ? Color.fromRGBO(31, 31, 31, 1)
                    : Color.fromRGBO(255, 255, 255, 1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TableCalendar(
                        firstDay: DateTime.utc(2010, 10, 16),
                        lastDay: DateTime.utc(2030, 3, 14),
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        rowHeight: 60.0,
                        availableCalendarFormats: {
                          CalendarFormat.month: 'Mes',
                        },
                        headerVisible: true,
                        headerStyle: HeaderStyle(
                          titleCentered: true,
                          formatButtonVisible: false,
                          formatButtonShowsNext: false,
                          formatButtonDecoration: BoxDecoration(border: Border.fromBorderSide(BorderSide()), borderRadius: BorderRadius.all(Radius.circular(10.0))),
                          titleTextStyle: TextStyle(fontSize: 17, color: (_isOscuro) ? Colors.white : Color.fromRGBO(45, 45, 45, 1)),
                          decoration : BoxDecoration(color: (_isOscuro) ? Color.fromRGBO(31, 31, 31, 1) : Color.fromRGBO(255, 255, 255, 1)),
                          rightChevronIcon: Icon(Icons.chevron_right, color: (_isOscuro) ? Colors.white : Color.fromRGBO(45, 45, 45, 1),),
                          leftChevronIcon: Icon(Icons.chevron_left, color: (_isOscuro) ? Colors.white : Color.fromRGBO(45, 45, 45, 1),),
                        ),
                        daysOfWeekHeight: 26.0,
                        daysOfWeekStyle: DaysOfWeekStyle(
                          decoration: BoxDecoration(
                            color: (_isOscuro) ? Color.fromRGBO(31, 31, 31, 1) : Color.fromRGBO(255, 255, 255, 1),
                          ),
                          weekdayStyle: TextStyle(color: (!_isOscuro) ? Color.fromRGBO(31, 31, 31, 1) : Color.fromRGBO(255, 255, 255, 1)),
                          weekendStyle: TextStyle(color: (!_isOscuro) ? Color.fromRGBO(31, 31, 31, 1) : Color.fromRGBO(255, 255, 255, 1)),
                        ),
                        calendarStyle: CalendarStyle(
                          rowDecoration: BoxDecoration(
                            color: (_isOscuro) ? Color.fromRGBO(31, 31, 31, 1) : Color.fromRGBO(255, 255, 255, 1),
                          ),
                          isTodayHighlighted: true,
                          todayTextStyle: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold
                          ),
                          todayDecoration: BoxDecoration(
                            color: Color.fromRGBO(4, 199, 82, 1),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.all(Radius.circular(10.0))
                          ),
                          defaultTextStyle: TextStyle(
                            color: (!_isOscuro)
                                ? Color.fromRGBO(31, 31, 31, 1)
                                : Color.fromRGBO(255, 255, 255, 1),
                          ),
                          weekendTextStyle: TextStyle(
                            color: (!_isOscuro) ? Color.fromARGB(255, 248, 248, 248) : Color.fromRGBO(5, 31, 68, 1),
                          ),
                          weekendDecoration: BoxDecoration(
                            color: (!_isOscuro) ? Color.fromRGBO(31, 31, 31, 1) : Color.fromRGBO(255, 255, 255, 1),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.all(Radius.circular(10.0))
                          ),
                          outsideTextStyle: TextStyle(
                                color: Color.fromARGB(255, 146, 146, 146),
                          ),
                        ),
                        onFormatChanged: (format){
                          print(format);
                        }


                      ),
                    ],
                  ),
                ),
            ));
          } else {
            return Container(
              child: CircularProgressIndicator(),
            );
          }
        }
    );
  }
}
