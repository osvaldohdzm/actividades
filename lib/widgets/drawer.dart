import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Actividades/main.dart';

class NavigationDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          createDrawerHeader(),
          createDrawerBodyItem(
            icon: Icons.calendar_view_day,
            text: 'Rutinas',
            onTap: () => {
              Navigator.pushReplacementNamed(context, 'RoutineScreen'),
            },
          ),
          createDrawerBodyItem(
            icon: Icons.list,
            text: 'Protocolos',
            onTap: () => Navigator.pushReplacementNamed(context, 'protocols'),
          ),
          createDrawerBodyItem(
            icon: Icons.event_note,
            text: 'Proyectos',
            onTap: () =>
                {Navigator.pushReplacementNamed(context, 'KanbanPage')},
          ),
          createDrawerBodyItem(
            icon: Icons.playlist_add_check,
            text: 'Tareas',
            onTap: () => Navigator.pushReplacementNamed(context, 'listspage'),
          ),
          createDrawerBodyItem(
            icon: Icons.access_alarm,
            text: 'Alarmas',
            onTap: () =>
                Navigator.pushReplacementNamed(context, PageRoutes.event),
          ),
          createDrawerBodyItem(
            icon: Icons.calendar_today,
            text: 'Agenda',
            onTap: () => Navigator.pushReplacementNamed(context, 'calendar'),
          ),
          createDrawerBodyItem(
            icon: Icons.track_changes,
            text: 'Objetivos',
            onTap: () =>
                Navigator.pushReplacementNamed(context, PageRoutes.event),
          ),
          createDrawerBodyItem(
            icon: Icons.insert_chart,
            text: 'Estadísticas',
            onTap: () =>
                Navigator.pushReplacementNamed(context, PageRoutes.event),
          ),
          Divider(),
          createDrawerBodyItem(
            icon: Icons.settings,
            text: 'Configuración',
            onTap: () =>
                Navigator.pushReplacementNamed(context, 'ConfigurationPage'),
          ),
        ],
      ),
    );
  }
}

Widget createDrawerHeader() {
  return Container(
      height: 140.0,
      child: DrawerHeader(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(color: Colors.blue),
          child: Stack(children: <Widget>[
            Positioned(
                bottom: 12.0,
                left: 16.0,
                child: Text("Actividades",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500))),
          ])));
}

Widget createDrawerBodyItem(
    {IconData icon, String text, GestureTapCallback onTap}) {
  return ListTile(
    title: Row(
      children: <Widget>[
        Icon(icon),
        Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(text),
        )
      ],
    ),
    onTap: onTap,
  );
}
