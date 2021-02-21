import 'package:Actividades/models/routine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';

class EditingRoutineScreen extends StatefulWidget {
  @override
  State createState() {
    return EditingRoutineScreenState();
  }
}

class EditingRoutineScreenState extends State<EditingRoutineScreen> {
  //Text Editing Controller
  TextEditingController textEditingController;
  Map data = {};
  Routine routine;

  Future<Database> database;

  Future<void> deleteTaskRoutine(String start_time) async {
    Database db = await database;

    debugPrint("Deleting: " + start_time);

    await db
        .delete("ROUTINE", where: "start_time = ?", whereArgs: [start_time]);
  }

  @override
  Widget build(BuildContext context) {
    data = ModalRoute.of(context).settings.arguments;
    routine = data['routine'];
    textEditingController = TextEditingController(text: routine.title);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${routine.startTime} - ${routine.endTime}',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: TextField(
              autofocus: true,
              controller: textEditingController,
              maxLines: 5,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
          ),
          Row(children: [
            FlatButton(
                child: Text('Eliminar'),
                color: Colors.blue,
                textColor: Colors.white,
                onPressed: () {
                  debugPrint("Pushed delete on:" + routine.title);
                  deleteTaskRoutine(routine.startTime);
                  Navigator.pop(context);
                }),
            SizedBox(width: 16.0),
            FlatButton(
                child: Text('Guardar'),
                color: Colors.blue,
                textColor: Colors.white,
                onPressed: () {
                  routine.title = textEditingController.text;
                  Navigator.pop(context, {
                    'routine': routine,
                  });
                }),
          ])
        ],
      ),
    );
  }
}
