import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

enum _AppBarMenu { logout }

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Events Calendar',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _loadHomeScreen(),
      routes: {
        '/calendar': (context) => MyApp(),
      },
    );
  }

  Widget _loadHomeScreen() {
    return HomePage();
  }
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CalendarState();
  }
}

class CalendarState extends State<HomePage> {
  DateTime _dateTime;

  int _beginMonthPadding = 0;
  int currentPage = 15;
  PageController pageController;

  CalendarState() {
    _dateTime = DateTime.now();
    setMonthPadding();
  }

  @override
  void initState() {
    super.initState();
    pageController =
        new PageController(initialPage: currentPage, viewportFraction: 0.7);
  }

  void setMonthPadding() {
    _beginMonthPadding =
        new DateTime(_dateTime.year, _dateTime.month, 1).weekday;
    _beginMonthPadding == 7 ? (_beginMonthPadding = 0) : _beginMonthPadding;
  }

  void _previousMonthSelected() {
    setState(() {
      if (_dateTime.month == DateTime.january)
        _dateTime = new DateTime(_dateTime.year - 1, DateTime.december);
      else
        _dateTime = new DateTime(_dateTime.year, _dateTime.month - 1);

      setMonthPadding();
    });
  }

  void _nextMonthSelected() {
    setState(() {
      if (_dateTime.month == DateTime.december)
        _dateTime = new DateTime(_dateTime.year + 1, DateTime.january);
      else
        _dateTime = new DateTime(_dateTime.year, _dateTime.month + 1);

      setMonthPadding();
    });
  }

  void _onDayTapped(int day) {
    int currentMonth = _dateTime.month;
    int currentDay = day;
    String currentDate;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          currentDate = "$currentMonth" + '월' + "$currentDay" + '일';

          return PageView.builder(
              controller: pageController,
              onPageChanged: (value) {
                setState(() {
                  if (value < currentPage) {
                    if (currentDay == 1) {
                      currentMonth--;
                      currentDay = getNumberOfDaysInMonth(currentMonth) -
                          _beginMonthPadding;
                    } else {
                      currentDay--;
                    }
                  } else if (value > currentPage) {
                    if (currentDay ==
                        getNumberOfDaysInMonth(currentMonth) -
                            _beginMonthPadding) {
                      currentMonth++;
                      currentDay = 1;
                    } else {
                      currentDay++;
                    }
                  }
                  print('value:' + "$value" + "$currentDay");
                  currentDate = "$currentMonth" + '월' + "$currentDay" + '일';
                  currentPage = value;
                });
              },
              itemBuilder: (context, day) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  contentPadding: EdgeInsets.only(top: 10),
                  content: Container(
                    width: 1000,
                    height: 500,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  currentDate,
                                  style: TextStyle(fontSize: 22.0),
                                ),
                              ),
                              Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: Icon(Icons.close),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ))
                            ]),
                        SizedBox(
                          height: 5.0,
                        ),
                        Divider(
                          color: Colors.grey,
                          height: 4.0,
                        ),
                        ListView(
                          shrinkWrap: true, //just set this property
                          children: <Widget>[
                            ListTile(
                              title: Text('Hello'),
                            ),
                            ListTile(
                              title: Text('Bonjour'),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    final int numWeekDays = 7;
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    /*28 is for weekday labels of the row*/
    // 55 is for iPhoneX clipping issue.
   /* final double itemHeight = (size.height -
            kToolbarHeight -
            kBottomNavigationBarHeight -
            24 -
            28 -
            55) /
        6;*/
    final double itemHeight = 100;
    final double itemWidth = 95/2;

    return new Scaffold(
        backgroundColor: Colors.white,
        body: new FutureBuilder(

            // future: _getCalendarData(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
            case ConnectionState.waiting:
              return new LinearProgressIndicator();
            case ConnectionState.none:
              int currentMonth = _dateTime.month;
              return new Container(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Row(children: <Widget>[
                    new IconButton(
                        icon: Icon(
                          Icons.chevron_left,
                          color: Colors.grey,
                        ),
                        onPressed: _previousMonthSelected),
                    Text(
                      "$currentMonth" + '월',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline,
                    ),
                    Text(
                      getMonthName(_dateTime.month),
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headline
                          .apply(color: Colors.grey),
                    ),
                    IconButton(
                        icon: Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                        ),
                        onPressed: _nextMonthSelected),
                  ]),
                  new Row(
                    children: <Widget>[
                      new Expanded(
                          child: new Text('일',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline
                                  .apply(color: Colors.red))),
                      new Expanded(
                          child: new Text('월',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headline)),
                      new Expanded(
                          child: new Text('화',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headline)),
                      new Expanded(
                          child: new Text('수',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headline)),
                      new Expanded(
                          child: new Text('목',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headline)),
                      new Expanded(
                          child: new Text('금',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headline)),
                      new Expanded(
                          child: new Text('토',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline
                                  .apply(color: Colors.blue))),
                    ],
                    mainAxisSize: MainAxisSize.min,
                  ),
                  new Stack(children: <Widget>[
                    GridView.count(
                      crossAxisCount: numWeekDays,
                      childAspectRatio: (itemWidth / itemHeight),
                      shrinkWrap: true,
                      //scrollDirection: Axis.vertical,
                      children: List.generate(
                          getNumberOfDaysInMonth(_dateTime.month), (index) {
                        int dayNumber = index + 1;
                        return new GestureDetector(
                            // Used for handling tap on each day view
                            onTap: () =>
                                _onDayTapped(dayNumber - _beginMonthPadding),
                            child: new Container(
                                //margin: const EdgeInsets.all(2.0),
                                padding: const EdgeInsets.all(1.0),
                                decoration: new BoxDecoration(
                                    border: new Border.all(color: Colors.grey)),
                                child: new Column(
                                  children: <Widget>[
                                    buildDayNumberWidget(dayNumber),
                                    buildDayEventInfoWidget(dayNumber),
                                  ],
                                )));
                      }),
                    ),

                  ])
                ],
              ));
              break;
            default:
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              else
                return new Text('Result: ${snapshot.data}');
          }
        }));
  }

  Align buildDayNumberWidget(int dayNumber) {
    //print('buildDayNumberWidget, dayNumber: $dayNumber');
    if ((dayNumber - _beginMonthPadding) == DateTime.now().day &&
        _dateTime.month == DateTime.now().month &&
        _dateTime.year == DateTime.now().year) {
      // Add a circle around the current day
      return Align(
        alignment: Alignment.center,
        child: Container(
          width: 30.0,
          // Should probably calculate these values
          height: 30.0,
          child: new Column(
            children: <Widget>[
              new Text(
                (dayNumber - _beginMonthPadding).toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.title,
              ),
              new Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // No circle around the current day
      return Align(
        alignment: Alignment.center,
        child: Container(
          width: 30.0,
          // Should probably calculate these values
          height: 30.0,
          child: new Column(
            children: <Widget>[
              new Text(
                dayNumber <= _beginMonthPadding
                    ? ' '
                    : (dayNumber - _beginMonthPadding).toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.title,
              ),
              new Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget buildDayEventInfoWidget(int dayNumber) {
    int eventCount = 2;
    DateTime eventDate;

    if (dayNumber == 20) {
      return new Column(children: <Widget>[
        FittedBox(
          alignment: Alignment.topCenter,
          fit: BoxFit.contain,
          child: new Text(
            "Events:$eventCount",
            maxLines: 1,
            style: new TextStyle(fontWeight: FontWeight.normal,
                background: Paint()..color = Colors.orange),
          ),
        ),
        FittedBox(
          alignment: Alignment.topCenter,
          fit: BoxFit.contain,
          child: new Text(
            "Events:$eventCount",
            maxLines: 1,
            style: new TextStyle(fontWeight: FontWeight.normal,
                background: Paint()..color = Colors.redAccent),
          ),
        ),

        Container(
          alignment: Alignment.topCenter,
          width: 35.0,
          height: 35.0,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: new Border.all(color: Colors.grey)),
          child: new Icon(Icons.check, color: Colors.grey),
        ),
        new Text(
          "+$eventCount",
          maxLines: 1,
          style:
              new TextStyle(fontWeight: FontWeight.normal, color: Colors.grey),
        ),
      ]);
    } else {
      return new Container();
    }
  }

  int getNumberOfDaysInMonth(final int month) {
    int numDays = 28;

    // Months are 1, ..., 12
    switch (month) {
      case 1:
        numDays = 31;
        break;
      case 2:
        numDays = 28;
        break;
      case 3:
        numDays = 31;
        break;
      case 4:
        numDays = 30;
        break;
      case 5:
        numDays = 31;
        break;
      case 6:
        numDays = 30;
        break;
      case 7:
        numDays = 31;
        break;
      case 8:
        numDays = 31;
        break;
      case 9:
        numDays = 30;
        break;
      case 10:
        numDays = 31;
        break;
      case 11:
        numDays = 30;
        break;
      case 12:
        numDays = 31;
        break;
      default:
        numDays = 28;
    }
    return numDays + _beginMonthPadding;
  }

  String getMonthName(final int month) {
    // Months are 1, ..., 12
    switch (month) {
      case 1:
        return "January";
      case 2:
        return "February";
      case 3:
        return "March";
      case 4:
        return "April";
      case 5:
        return "May";
      case 6:
        return "June";
      case 7:
        return "July";
      case 8:
        return "August";
      case 9:
        return "September";
      case 10:
        return "October";
      case 11:
        return "November";
      case 12:
        return "December";
      default:
        return "Unknown";
    }
  }

  Future _handleAppbarMenu(BuildContext context, _AppBarMenu value) async {
    switch (value) {
      case _AppBarMenu.logout:
        // await _auth.signOut();
        //Navigator.of(context).pushNamedAndRemoveUntil(Constants.splashRoute, (Route<dynamic> route) => false);
        break;
    }
  }

  Future _onBottomBarItemTapped(int index) async {
    switch (index) {
      case 0:
        break;
      case 1:
        // Navigator.pushNamed(context, Constants.calContactsRoute);
        break;
    }
  }
}
