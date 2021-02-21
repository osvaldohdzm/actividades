import 'package:Actividades/models/proyect.dart';
import 'package:Actividades/views/proyect-kanban-page.dart';
import 'package:Actividades/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:Actividades/database.dart';
import 'package:flutter/widgets.dart';

class ProyectsPage extends StatefulWidget {
  @override
  ProyectsPageState createState() => ProyectsPageState();
}

class ProyectsPageState extends State<ProyectsPage> {
  var db = new DatabaseHelper();

  int currentIndex;
  int listlen;
  int l;
  bool flag = true;

  @override
  initState() {
    super.initState();
    currentIndex = -1;
    flag = true;
  }

  Future<Proyect> createAlertDialogForEditingList(context, Proyect item) {
    TextEditingController titleController =
        TextEditingController(text: item.name);
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
                      'Editar proyecto',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: titleController,
                      decoration: InputDecoration(labelText: "Nombre"),
                      validator: (input) {
                        if (input.isEmpty) {
                          return 'Nombre del proyecto';
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
                            // height: 20,
                            child: Text('Cancelar'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            }),
                        MaterialButton(
                            // height: 20,
                            child: Text('Hecho'),
                            onPressed: () {
                              if (_formkey.currentState.validate()) {
                                Navigator.of(context).pop(Proyect(
                                    name: titleController.text.toString()));
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

  Future<Proyect> createAlertDialogForProyect(context, List<Proyect> list) {
    TextEditingController nameController = TextEditingController();
    GlobalKey<FormState> _formkey = GlobalKey<FormState>();

    return showDialog(
        context: context,
        builder: (context) {
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
                      'Nombre del proyecto:',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: nameController,
                      decoration: InputDecoration(labelText: "Nombre"),
                      validator: (input) {
                        if (input.isEmpty) {
                          return 'This field should no be empty';
                        }

                        for (int i = 0; i < list.length; i++)
                          if (list[i].name.toLowerCase() ==
                              input.toLowerCase()) {
                            return 'Already Exists. Try a different name';
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
                            child: Text('Agregar'),
                            onPressed: () {
                              if (_formkey.currentState.validate()) {
                                Navigator.of(context).pop(Proyect(
                                  name: nameController.text.toString(),
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

  List<Proyect> globalList;

  // Handler called by ReorderableListView onReorder after a list child is
  // dropped into a new position.
  void _onReorder(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) {
      newIndex -= 1;

      globalList.forEach((element) {
        debugPrint(element.orderIndex.toString());
      });

      globalList[oldIndex].orderIndex = globalList[newIndex].orderIndex;
      await db.updateProyect(globalList[1]);
      for (var i = 0; i < globalList.length; i++) {
        if (globalList[i].orderIndex < globalList[newIndex].orderIndex) {
          globalList[i].orderIndex--;
          await db.updateProyect(globalList[i]);
        }
      }
      globalList[newIndex].orderIndex--;
      await db.updateProyect(globalList[newIndex]);
    } else {
      globalList.forEach((element) {
        debugPrint(element.orderIndex.toString());
      });
      debugPrint("***********************");
      globalList[oldIndex].orderIndex = globalList[newIndex].orderIndex;
      await db.updateProyect(globalList[oldIndex]);
      for (var i = 0; i < globalList.length; i++) {
        if (globalList[i].orderIndex > globalList[newIndex].orderIndex) {
          globalList[i].orderIndex++;
          await db.updateProyect(globalList[i]);
        }
      }
      globalList[newIndex].orderIndex++;
      await db.updateProyect(globalList[newIndex]);
    }

    debugPrint("***********************");
    globalList.forEach((element) {
      debugPrint(element.orderIndex.toString());
    });

    setState(() {});
  }

  Widget emptyPage(context, List<Proyect> proyects, Function setState) {
    return Scaffold(
        appBar: AppBar(title: Text('Sin listas')),
        body: Center(
          child: Text('Vacio'),
        ));
  }

  Widget viewMenu(
      context, List<Proyect> proyects, Function setState, Proyect listtodo) {
    List<Widget> list = List<Widget>();
    globalList = proyects;
    if (proyects.length > 0) {
      List<Widget> temp = List<Widget>.generate(proyects.length, (index) {
        Proyect job = proyects[index];
        return Card(
          key: UniqueKey(),
          child: ListTile(
            onTap: () async {
              Navigator.push(context,
                      MaterialPageRoute(builder: (context) => KanbanPage()))
                  .then((value) {
                setState(() {});
              });
            },
            title: Text(job.name),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: Colors.blue,
                ),
                onPressed: () {
                  createAlertDialogForEditingList(context, proyects[index])
                      .then((value) async {
                    if (value != null) {
                      proyects[index].name = value.name;
                      await db.updateProyect(proyects[index]);
                      setState(() {});
                    }
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.blue,
                ),
                onPressed: () async {
                  await db.deleteProyect(proyects[index].id);
                  setState(() {
                    if (currentIndex == index) {
                      if (proyects.length == 1)
                        currentIndex = -1;
                      else if (index == proyects.length - 1) currentIndex--;
                    } else if (currentIndex == proyects.length - 1)
                      currentIndex--;
                    l--;
                  });
                },
              ),
            ]),
          ),
        );
      });
      list.addAll(temp);
      return ReorderableListView(
        onReorder: _onReorder,
        padding: EdgeInsets.all(8.0),
        children: list,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Proyect>>(
        future: db.getAllProyects(),
        builder: (BuildContext context,
            AsyncSnapshot<List<Proyect>> proyectsSnapshot) {
          if (proyectsSnapshot.hasData) {
            if (flag) {
              l = proyectsSnapshot.data.length;
              if (l == 0)
                currentIndex = -1;
              else
                currentIndex = 0;
              flag = false;
            }

            if (l == proyectsSnapshot.data.length &&
                currentIndex < proyectsSnapshot.data.length) {
              return Scaffold(
                drawer: NavigationDrawer(),
                floatingActionButton: FloatingActionButton(
                    child: Icon(Icons.add),
                    backgroundColor: Colors.blue,
                    onPressed: () async {
                      await createAlertDialogForProyect(
                              context, proyectsSnapshot.data)
                          .then((value) async {
                        if (value != null) {
                          await db.newProyect(
                              value.name, "", proyectsSnapshot.data.length + 1);
                          l++;
                          if (currentIndex == -1)
                            currentIndex = 0;
                          else
                            currentIndex = proyectsSnapshot.data.length;
                          setState(() {});
                        }
                      });
                    }),
                appBar: AppBar(
                  title: Text('Proyectos ' +
                      '(' +
                      proyectsSnapshot.data.length.toString() +
                      ')'),
                  backgroundColor: Colors.blue,
                ),
                body: currentIndex == -1
                    ? Center(child: Text('Vacio'))
                    : viewMenu(context, proyectsSnapshot.data, setState,
                        proyectsSnapshot.data[currentIndex]),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}
