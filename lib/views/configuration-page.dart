import 'dart:io';

import 'package:Actividades/database.dart';
import 'package:Actividades/widgets/drawer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:mime_type/mime_type.dart';
import 'package:share/share.dart';
import 'package:sqflite/sqflite.dart';

class ConfigurationPage extends StatefulWidget {
  ConfigurationPage({Key key, this.title}) : super(key: key);

  static const String routeName = '/ConfigurationPage';
  final String title;

  @override
  _ConfigurationPageState createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage> {
  static const String routeName = '/ConfigurationPage';
  var db = new DatabaseHelper();
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Configuración"),
      ),
      drawer: NavigationDrawer(),
      body: Center(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          RaisedButton(
              onPressed: () async {
                File file = await FilePicker.getFile();
                debugPrint("Archivo cargado path es:" + file.path);

                String path = await db.getUrl();
                File f = new File.fromUri(Uri.file(path));
                debugPrint("Archivo a borrar path es:" + f.path);
                f.delete();

                File newFile = await file.rename(path);
                debugPrint("Archivo a renombrado path es:" + newFile.path);

                await db.replaceDB(newFile.path);
              },
              child: const Text('Restaurar', style: TextStyle(fontSize: 20))),
          SizedBox(width: 24),
          RaisedButton(
              onPressed: () async {
                String path = await db.getUrl();
                Share.shareFiles([path], text: 'Great picture');
              },
              child: const Text('Respaldar', style: TextStyle(fontSize: 20)))
        ]),
      ),
    );
  }
}
