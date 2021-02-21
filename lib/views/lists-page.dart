import 'package:Actividades/models/todolist.dart';
import 'package:Actividades/widgets/drawer.dart';
import 'package:after_layout/after_layout.dart';
import 'package:Actividades/views/introduction-page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Actividades/views/tasks-page.dart';
import 'package:flutter/material.dart';
import 'package:Actividades/database.dart';
import 'package:flutter/widgets.dart';

class ListsPage extends StatefulWidget {
  @override
  ListsPageState createState() => ListsPageState();
}

class ListsPageState extends State<ListsPage> with AfterLayoutMixin<ListsPage> {
  var db = new DatabaseHelper();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int currentIndex;
  int listlen;
  int l;
  bool flag = true;
  List<String> choices = ['Blue', 'Red', 'Green', 'Yellow', 'Dark'];
  Map<String, Color> choiceColorMap = {
    'Blue': Colors.blue,
    'Green': Colors.green,
    'Red': Colors.red,
    'Yellow': Colors.amber,
    'Dark': Colors.grey[600]
  };
  List<Todolist> globalList;

  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if (!(_seen)) {
      await prefs.setBool('seen', true);
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new OnBoardingPage()));
    }
  }

  @override
  void afterFirstLayout(BuildContext context) => checkFirstSeen();

  @override
  initState() {
    super.initState();
    currentIndex = -1;
    flag = true;
  }

  Future<Todolist> createAlertDialogForEditingList(context, Todolist item) {
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
                      'Editar lista',
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
                          return 'Nombre de la lista';
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
                                Navigator.of(context).pop(Todolist(
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

  Future<Todolist> createAlertDialogForEnteringList(
      context, List<Todolist> list) {
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
                      'Nombre de la lista:',
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
                                Navigator.of(context).pop(Todolist(
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

  // Handler called by ReorderableListView onReorder after a list child is
  // dropped into a new position.
  void _onReorder(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) {
      newIndex -= 1;

      globalList.forEach((element) {
        debugPrint(element.name.toString());
      });
      debugPrint("***********************");
      globalList[oldIndex].orderIndex = globalList[newIndex].orderIndex;
      await db.updateList(globalList[oldIndex]);
      for (var i = 0; i < globalList.length; i++) {
        if (globalList[i].orderIndex < globalList[newIndex].orderIndex) {
          globalList[i].orderIndex--;
          await db.updateList(globalList[i]);
        }
      }
      globalList[newIndex].orderIndex--;
      await db.updateList(globalList[newIndex]);
    } else {
      globalList.forEach((element) {
        debugPrint(element.orderIndex.toString());
      });
      debugPrint("***********************");
      globalList[oldIndex].orderIndex = globalList[newIndex].orderIndex;
      await db.updateList(globalList[oldIndex]);
      for (var i = 0; i < globalList.length; i++) {
        if (globalList[i].orderIndex > globalList[newIndex].orderIndex) {
          globalList[i].orderIndex++;
          await db.updateList(globalList[i]);
        }
      }
      globalList[newIndex].orderIndex++;
      await db.updateList(globalList[newIndex]);
    }

    debugPrint("***********************");
    globalList.forEach((element) {
      debugPrint(element.orderIndex.toString());
    });

    setState(() {});
  }

  Widget emptyPage(context, List<Todolist> lists, Function setState) {
    return Scaffold(
        appBar: AppBar(title: Text('Sin listas')),
        body: Center(
          child: Text('Vacio'),
        ));
  }

  Widget viewMenu(
      context, List<Todolist> lists, Function setState, Todolist listtodo) {
    List<Widget> list = List<Widget>();
    globalList = lists;
    debugPrint("viewMenu " + globalList.toString());
    if (lists.length > 0) {
      List<Widget> temp = List<Widget>.generate(lists.length, (index) {
        Todolist job = lists[index];
        return Card(
          key: UniqueKey(),
          child: ListTile(
            title: Text(job.name),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: currentIndex == -1
                      ? Colors.blue
                      : choiceColorMap[lists[index].color],
                ),
                onPressed: () {
                  createAlertDialogForEditingList(context, lists[index])
                      .then((value) async {
                    if (value != null) {
                      lists[index].name = value.name;
                      await db.updateList(lists[index]);
                      setState(() {});
                    }
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: currentIndex == -1
                      ? Colors.blue
                      : choiceColorMap[lists[index].color],
                ),
                onPressed: () async {
                  await db.deleteList(lists[index].id);
                  setState(() {
                    if (currentIndex == index) {
                      if (lists.length == 1)
                        currentIndex = -1;
                      else if (index == lists.length - 1) currentIndex--;
                    } else if (currentIndex == lists.length - 1) currentIndex--;
                    l--;
                  });
                },
              ),
            ]),
            onTap: () {
              this.setState(() {});
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TasksPage(
                          tasksIndex: lists[index].id,
                          listtodo: lists[index])));
            },
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
    final screenHeight = MediaQuery.of(context).size.height;

    return FutureBuilder<List<Todolist>>(
        future: db.getAllLists(),
        builder:
            (BuildContext context, AsyncSnapshot<List<Todolist>> listsnapshot) {
          debugPrint("FutureBuilder value:" + listsnapshot.data.toString());
          if (listsnapshot.hasData) {
            if (flag) {
              l = listsnapshot.data.length;
              if (l == 0)
                currentIndex = -1;
              else
                currentIndex = 0;
              flag = false;
            }
            if (l == listsnapshot.data.length &&
                currentIndex < listsnapshot.data.length) {
              return Scaffold(
                  key: _scaffoldKey,
                  drawer: NavigationDrawer(),
                  floatingActionButton: FloatingActionButton(
                      child: Icon(Icons.add),
                      backgroundColor: currentIndex == -1
                          ? null
                          : choiceColorMap[
                              listsnapshot.data[currentIndex].color],
                      onPressed: () async {
                        await createAlertDialogForEnteringList(
                                context, listsnapshot.data)
                            .then((value) async {
                          if (value != null) {
                            await db.createList(
                                value.name, listsnapshot.data.length + 1);
                            l++;
                            if (currentIndex == -1)
                              currentIndex = 0;
                            else
                              currentIndex = listsnapshot.data.length;
                            setState(() {});
                          }
                        });
                      }),
                  appBar: AppBar(
                    title: Text('Listas de tareas ' +
                        '(' +
                        listsnapshot.data.length.toString() +
                        ')'),
                    backgroundColor: currentIndex == -1
                        ? Colors.blue
                        : choiceColorMap[listsnapshot.data[currentIndex].color],
                    leading: IconButton(
                      icon: Icon(Icons.menu),
                      onPressed: () {
                        _scaffoldKey.currentState.openDrawer();
                      },
                    ),
                    actions: currentIndex == -1
                        ? null
                        : <Widget>[
                            PopupMenuButton<String>(
                              onSelected: (choice) async {
                                listsnapshot.data[currentIndex].color = choice;
                                await db.updateList(
                                    listsnapshot.data[currentIndex]);
                                setState(() {});
                              },
                              itemBuilder: (BuildContext context) {
                                return choices.map((String choice) {
                                  return PopupMenuItem<String>(
                                    height: 40,
                                    value: choice,
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.color_lens,
                                          color: choiceColorMap[choice],
                                        ),
                                        Text(choice),
                                      ],
                                    ),
                                  );
                                }).toList();
                              },
                            )
                          ],
                  ),
                  body: ListView(
                    padding: const EdgeInsets.all(8),
                    children: <Widget>[
                      Container(
                          color: Colors.amber[600],
                          child: Column(
                            children: [
                              Card(
                                child: Column(
                                  children: <Widget>[
                                    ListTile(
                                      title: Text("Mi día"),
                                      isThreeLine: false,
                                      hoverColor: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                              Card(
                                child: Column(
                                  children: <Widget>[
                                    ListTile(
                                      title: Text("Importante"),
                                      isThreeLine: false,
                                      hoverColor: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                              Card(
                                child: Column(
                                  children: <Widget>[
                                    ListTile(
                                      title: Text("Planeado"),
                                      isThreeLine: false,
                                      hoverColor: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                      Divider(color: Colors.black),
                      Container(
                        height: MediaQuery.of(context).size.width * 1.15,
                        color: Colors.amber[100],
                        child: currentIndex == -1
                            ? Center(child: Text('Vacio'))
                            : viewMenu(context, listsnapshot.data, setState,
                                listsnapshot.data[currentIndex]),
                      ),
                    ],
                  ));
            } else {
              return Center(child: CircularProgressIndicator());
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}
