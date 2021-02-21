import 'package:Actividades/views/alarm-page.dart';
import 'package:Actividades/views/calendar-page.dart';
import 'package:Actividades/views/configuration-page.dart';
import 'package:Actividades/views/editing-routine-page.dart';
import 'package:Actividades/views/proyects-page.dart';
import 'package:Actividades/views/routine-page.dart';
import 'package:Actividades/views/task-details-page.dart';
import 'package:flutter/material.dart';
import 'package:Actividades/widgets/drawer.dart';
import 'package:Actividades/views/protocols-page.dart';
import 'package:Actividades/views/test-page.dart';
import 'package:Actividades/views/lists-page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

void main() {
  runApp(Phoenix(
      child: MaterialApp(
    title: 'Actividades',
    localizationsDelegates: [
      // ... app-specific localization delegate[s] here
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: ProtocolsPage(),
    routes: {
      PageRoutes.home: (context) => HomePage(),
      'ConfigurationPage': (context) => ConfigurationPage(),
      PageRoutes.event: (context) => AlarmPage(),
      'RoutineScreen': (context) => RoutineScreen(),
      'EditRoutineScreen': (context) => EditingRoutineScreen(),
      PageRoutes.profile: (context) => ProfilePage(),
      'protocols': (context) => ProtocolsPage(),
      PageRoutes.test: (context) => TestPage(title: 'Pruebas'),
      'listspage': (context) => ListsPage(),
      'calendar': (context) => CalendarWidget(),
      'KanbanPage': (context) => ProyectsPage(),
      'tasks': (context) => TaskPage(),
      'TaskDetailsPage': (context) => TaskDetailsPage(),
    },
  )));
}

class PageRoutes {
  static const String home = HomePage.routeName;
  static const String event = EventPage.routeName;
  static const String profile = ProfilePage.routeName;
  static const String notification = NotificationPage.routeName;
  static const String task = TaskPage.routeName;
  static const String test = TestPage.routeName;
}

class HomePage extends StatelessWidget {
  static const String routeName = '/HomePage';

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      drawer: NavigationDrawer(),
      body: Center(child: Text("This is home page")),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Increment',
        child: Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }
}

class EventPage extends StatelessWidget {
  static const String routeName = '/EventPage';

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: Text("Events"),
        ),
        drawer: NavigationDrawer(),
        body: Center(child: Text("Hey! this is events list page")));
  }
}

class NotificationPage extends StatelessWidget {
  static const String routeName = '/NotificationPage';

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: Text("Notifications"),
        ),
        drawer: NavigationDrawer(),
        body: Center(child: Text("This is notification page")));
  }
}

class ProfilePage extends StatelessWidget {
  static const String routeName = '/ProfilePage';

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: Text("My Profile"),
        ),
        drawer: NavigationDrawer(),
        body: Center(child: Text("This is profile page")));
  }
}

class TaskPage extends StatefulWidget {
  TaskPage({Key key, this.title}) : super(key: key);

  static const String routeName = '/TaskPage';
  final String title;

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: NavigationDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
