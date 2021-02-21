import 'package:Actividades/models/routine.dart';
import 'package:Actividades/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class RoutineScreen extends StatefulWidget {
  RoutineScreen({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<RoutineScreen> {
  //Database Setup
  Future<Database> database;

  void initializeDB() async {
    database = openDatabase(
      join(await getDatabasesPath(), 'routinex.db'),
      onCreate: (db, version) {
        return db.execute(
            "CREATE TABLE ROUTINE(start_time TEXT PRIMARY KEY, end_time TEXT UNIQUE, title TEXT, status TEXT)");
      },
      version: 1,
    );
  }

  Future<Routine> createAlertDialogForEntering(context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController initController = TextEditingController();
    TextEditingController finalController = TextEditingController();
    GlobalKey<FormState> _formkey = GlobalKey<FormState>();

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              margin: EdgeInsets.only(left: 26.0, right: 26.0),
              child: Form(
                key: _formkey,
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Agregar tarea',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                    TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: titleController,
                      decoration: InputDecoration(labelText: "Título"),
                      validator: (input) {
                        if (input.isEmpty) {
                          return 'Introduce un título para la tarea';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: initController,
                      decoration: InputDecoration(labelText: "Inicio"),
                      validator: (input) {
                        if (input.isEmpty) {
                          return 'Hora de inicio';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: finalController,
                      decoration: InputDecoration(labelText: "Final"),
                      validator: (input) {
                        if (input.isEmpty) {
                          return 'Hora final';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        MaterialButton(
                            child: Text('Cancelar'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            }),
                        MaterialButton(
                            child: Text('Agregar tarea'),
                            onPressed: () {
                              if (_formkey.currentState.validate()) {
                                Navigator.of(context).pop(Routine(
                                  endTime: initController.text.toString(),
                                  startTime: finalController.text.toString(),
                                  title: titleController.text.toString(),
                                ));
                              }
                            }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<void> insert() async {
    Database db = await database;

    Batch batch = db.batch();

    for (int index = 0; index < routineList.length; index++) {
      batch.insert('ROUTINE', routineList[index].toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    batch.commit();
  }

  Future<void> newTaskRoutine(Routine routine) async {
    Database db = await database;

    db.insert(
      'ROUTINE',
      routine.toMap(),
    );
  }

  void insertData() async {
    await insert();
  }

  Future<List<Map<String, dynamic>>> retrieve() async {
    Database db = await database;
    List<Map<String, dynamic>> list = await db.query('ROUTINE');

    return list;
  }

  void retrieveList() async {
    List<Map<String, dynamic>> tempList = await retrieve();
    List<Routine> tempRoutineList = List();

    for (int index = 0; index < tempList.length; index++) {
      tempRoutineList.add(Routine(
          startTime: tempList[index]['start_time'],
          endTime: tempList[index]['end_time'],
          title: tempList[index]['title'],
          status: getStatus(tempList[index]['status'])));
    }
    setState(() {
      routineListDB = tempRoutineList;
    });
  }

  Future<void> update(Routine routine) async {
    Database db = await database;

    db.update(
      'ROUTINE',
      routine.toMap(),
      where: 'start_time = ?',
      whereArgs: [routine.startTime],
    );
  }

  void updateData(Routine routine) async {
    await update(routine);
  }

  bool getStatus(String value) {
    return value == 'true' ? true : false;
  }

  //Date time controllers
  DateTime time = DateTime.now();

  //Appbar height controller
  double appBarHeight = 270.0;

  //Routine List
  List<Routine> routineList;
  List<Routine> routineListDB = List();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    initializeDB();
    Future.delayed(Duration(seconds: 0)).then((value) {
      insertData();
    });
    Future.delayed(Duration(seconds: 0)).then((value) {
      retrieveList();
    });
  }

  @override
  Widget build(BuildContext context) {
    routineList = RoutineList().getList();
    print(time);
    return Scaffold(
      drawer: NavigationDrawer(),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Colors.green,
          onPressed: () {
            createAlertDialogForEntering(context).then((value) async {
              if (value != null) {
                newTaskRoutine(new Routine(
                    endTime: value.endTime,
                    startTime: value.startTime,
                    status: false,
                    title: value.title));
                setState(() {});
              }
            });
          }),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 160.0,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                appBarHeight = constraints.constrainHeight();
                return appBarHeight > 160
                    ? FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage('assets/header.jpg'),
                                    fit: BoxFit.cover),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                    Colors.greenAccent.withOpacity(.3),
                                    Colors.green.withOpacity(.6),
                                  ]),
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(50.0),
                                      bottomRight: Radius.circular(50.0))),
                            ),
                          ],
                        ),
                        centerTitle: true,
                        title: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 0.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        time.hour >= 4 && time.hour < 12
                                            ? 'Buenos días'
                                            : time.hour >= 12 && time.hour < 17
                                                ? 'Buenas tardes'
                                                : time.hour >= 17 &&
                                                        time.hour < 20
                                                    ? 'Buenas noches'
                                                    : time.hour >= 20
                                                        ? 'Buenos noches'
                                                        : 'Descansa',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 28.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 10.0),
                                height: 3.0,
                                width: 100.0,
                                color: Colors.white,
                              )
                            ],
                          ),
                        ),
                      )
                    : FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            Image(
                              image: AssetImage('assets/header.jpg'),
                              fit: BoxFit.cover,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                                  Colors.greenAccent.withOpacity(.3),
                                  Colors.green.withOpacity(.6),
                                ]),
                              ),
                            ),
                          ],
                        ),
                        centerTitle: true,
                      );
              },
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(
                height: 30.0,
              )
            ]),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              routineListDB
                  .map(
                    (routine) => RoutineCard(
                      key: UniqueKey(),
                      routine: routine,
                      updateData: updateData,
                    ),
                  )
                  .toList(),
            ),
          )
        ],
      ),
    );
  }
}

class RoutineCard extends StatefulWidget {
  Function updateData;
  Routine routine;
  Key key;
  RoutineCard({this.key, this.routine, this.updateData});

  @override
  State createState() {
    return RoutineCardState();
  }
}

class RoutineCardState extends State<RoutineCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      margin: EdgeInsets.fromLTRB(3.0, 3.0, 3.0, 3.0),
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 0.0),
        margin: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        child: CheckboxListTile(
          value: widget.routine.status,
          controlAffinity: ListTileControlAffinity.leading,
          title: Container(
            margin: EdgeInsets.symmetric(vertical: 5.0),
            child: Text(
              '${widget.routine.startTime} - ${widget.routine.endTime}',
              style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0),
            ),
          ),
          subtitle: Container(
            margin: EdgeInsets.symmetric(vertical: 5.0),
            child: Text(
              '${widget.routine.title}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.black.withOpacity(.7),
                  letterSpacing: 0.8),
            ),
          ),
          secondary: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.edit,
              ),
              onPressed: () async {
                dynamic result = await Navigator.pushNamed(
                    context, 'EditRoutineScreen',
                    arguments: {
                      'routine': widget.routine,
                    });
                if (result != null) {
                  setState(() {
                    widget.updateData(result['routine']);
                  });
                }
              },
            ),
          ]),
          onChanged: (newValue) {
            setState(() {
              widget.routine.status = newValue;
            });

            widget.updateData(widget.routine);
          },
        ),
      ),
    );
  }
}
