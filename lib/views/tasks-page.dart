import 'dart:convert';

import 'package:Actividades/database.dart';
import 'package:Actividades/widgets/drawer.dart';
import 'package:Actividades/views/task-details-page.dart';
import 'package:circular_check_box/circular_check_box.dart';
import 'package:flutter/material.dart';
import 'package:Actividades/models/Item.dart';
import 'package:Actividades/models/todolist.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class TasksPage extends StatefulWidget {
  final int tasksIndex;
  final Todolist listtodo;
  TasksPage({Key key, this.tasksIndex, this.listtodo}) : super(key: key);

  @override
  TasksPageState createState() => TasksPageState();
}

class TasksPageState extends State<TasksPage> {
  int currentIndex = 1;
  int listlen;
  int l;
  bool flag = true;

  List<Widget> taskList;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<String> choices = ['Blue', 'Red', 'Green', 'Yellow', 'Dark'];
  Map<String, Color> choiceColorMap = {
    'Blue': Colors.blue,
    'Green': Colors.green,
    'Red': Colors.red,
    'Yellow': Colors.amber,
    'Dark': Colors.grey[600]
  };

  var db = new DatabaseHelper();

  @override
  initState() {
    super.initState();
    currentIndex = -1;
    flag = true;
  }

  Future<Item> createAlertDialogForEntering(context) {
    TextEditingController titleController = TextEditingController();
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
                                Navigator.of(context).pop(Item(
                                    id: 0,
                                    done: 0,
                                    title: titleController.text.toString(),
                                    description: ""));
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

  Future<Item> createAlertDialogForEditing(context, Item item) {
    TextEditingController titleController =
        TextEditingController(text: item.title);
    TextEditingController descriptionController =
        TextEditingController(text: item.description);
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
                      'Editar detalles de tarea',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: titleController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(labelText: "Nombre"),
                      validator: (input) {
                        if (input.isEmpty) {
                          return 'Nombre de la tarea o proyecto';
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
                            child: Text('Hecho'),
                            onPressed: () {
                              if (_formkey.currentState.validate()) {
                                Navigator.of(context).pop(Item(
                                    done: 0,
                                    title: titleController.text.toString(),
                                    description:
                                        descriptionController.text.toString()));
                              }
                            }),
                        MaterialButton(
                            // height: 20,
                            child: Text('Cancelar'),
                            onPressed: () {
                              Navigator.of(context).pop();
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

  Widget emptyPage(context, List<Todolist> lists, Function setState) {
    return Scaffold(
        appBar: AppBar(title: Text('Sin listas')),
        body: Center(
          child: Text('EMPTY!'),
        ));
  }

  List<Widget> contentListItem(
      List<Item> list, Todolist listtodo, BuildContext context) {
    final _listTiles = list
        .asMap()
        .map((index, item) => MapEntry(
            index,
            Dismissible(
                key: Key(item.title),
                // We also need to provide a function that tells our app what to do
                // after an item has been swiped away.
                onDismissed: (DismissDirection dir) async {
                  if (dir == DismissDirection.startToEnd) {
                    setState(() {});
                  } else {
                    list.removeAt(index);
                    await db.deleteItem(item.id);
                    setState(() {});
                  }

                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      action: SnackBarAction(
                        label: 'Deshacer',
                        onPressed: () async {
                          item.listId = widget.listtodo.id;
                          await db.newItem(item);
                          // ll++;
                          setState(() {});
                        },
                      ),
                      content: Text(dir == DismissDirection.startToEnd
                          ? '$item completado.'
                          : '$item eliminado.'),
                    ),
                  );
                },
                // Show a red background as the item is swiped away
                secondaryBackground: Container(
                  color: Colors.red,
                  child: Icon(Icons.delete),
                  alignment: Alignment.centerLeft,
                ),
                // Background when swipping from right to left
                background: Container(
                  color: Colors.lightBlue,
                  child: Icon(Icons.done),
                  alignment: Alignment.centerRight,
                ),
                child: Card(
                  key: UniqueKey(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        onTap: () async {
                          item.listId = widget.listtodo.id;
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          TaskDetailsPage(task: item)))
                              .then((value) {
                            setState(() {});
                          });
                        },
                        title: Text('${item.title}'),
                        isThreeLine: false,
                        hoverColor: Colors.white,
                        subtitle: new Container(
                          //padding: new EdgeInsets.only(right: 13.0),
                          child: Text(
                              "1 de 3 · 📅" +
                                  new DateFormat.yMMMEd('es_MX')
                                      .format(DateTime.now()) +
                                  " 🔁",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14)),
                        ),
                        leading: CircularCheckBox(
                            materialTapTargetSize: MaterialTapTargetSize.padded,
                            value: item.done > 0 ? true : false,
                            checkColor: Colors.white,
                            activeColor: Colors.green,
                            inactiveColor: Colors.black,
                            disabledColor: Colors.grey,
                            onChanged: (val) => this.setState(() {
                                  item.done = (val) ? 1 : 0;
                                  item.listId = widget.listtodo.id;
                                  db.updateItem(item);
                                })),
                      ),
                    ],
                  ),
                ))))
        .values
        .toList();
    return _listTiles;
  }

  Widget viewMenu(context, List<Todolist> lists, Function setState) {
    List<Widget> list = List<Widget>();

    if (lists.length > 0) {
      List<Widget> temp = List<Widget>.generate(lists.length, (index) {
        Todolist job = lists[index];
        return Card(
          child: ListTile(
            leading: Icon(
              Icons.view_list,
              color: currentIndex == -1
                  ? Colors.blue
                  : choiceColorMap[lists[index].color],
            ),
            title: Text(job.name),
            trailing: IconButton(
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
            onTap: () => setState(() {
              //currentIndex = index;
              //Navigator.pop(context);
            }),
          ),
        );
      });
      list.addAll(temp);
    }
    return ListView(
      children: list,
    );
  }

  String _reverseSort = "title";
  String ascdesc;

  // Handler called when the "sort" button on appbar is clicked.
  void _onSort() async {
    if (ascdesc == "DESC") {
      ascdesc = "ASC";
    } else {
      ascdesc = "DESC";
    }
    Todolist oldPositionList = widget.listtodo;
    oldPositionList.tasksSort = ascdesc;
    await db.updateList(oldPositionList);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    currentIndex = widget.tasksIndex;
    ascdesc = widget.listtodo.tasksSort;
    return Scaffold(
      key: _scaffoldKey,
      drawer: NavigationDrawer(),
      appBar: AppBar(
        title: currentIndex == -1
            ? Text('Sin listas')
            : Text(widget.listtodo.name),
        backgroundColor: currentIndex == -1
            ? Colors.blue
            : choiceColorMap[widget.listtodo.color],
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState.openDrawer();
          },
        ),
        actions: <Widget>[
          currentIndex == -1
              ? null
              : IconButton(
                  icon: Icon(Icons.sort_by_alpha),
                  tooltip: 'Sort',
                  onPressed: _onSort,
                ),
          IconButton(
            onPressed: () async {
              await db.deleteAll(widget.listtodo.name);
              setState(() {});
            },
            icon: Icon(Icons.clear_all),
          ),
          PopupMenuButton<String>(
            onSelected: (choice) async {
              widget.listtodo.color = choice;
              await db.updateList(widget.listtodo);
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
      body: currentIndex == -1
          ? Center(child: Text('Vacio'))
          : FutureBuilder<List<Item>>(
              future:
                  db.getListItems(widget.listtodo.id, _reverseSort, ascdesc),
              builder:
                  (BuildContext context, AsyncSnapshot<List<Item>> snapshot) {
                listlen = snapshot.data.length;
                if (snapshot.hasData) {
                  taskList =
                      contentListItem(snapshot.data, widget.listtodo, context);
                  return ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: taskList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return taskList[index];
                      });
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              }),
      floatingActionButton: currentIndex == -1
          ? null
          : FloatingActionButton(
              child: Icon(Icons.add),
              backgroundColor: choiceColorMap[widget.listtodo.color],
              onPressed: () {
                createAlertDialogForEntering(context).then((value) async {
                  if (value != null) {
                    int id = listlen + 1;
                    value.id = id;
                    value.done = 0;
                    value.listId = widget.listtodo.id;
                    await db.newItem(value);
                    setState(() {});
                  }
                });
              }),
      floatingActionButtonLocation:
          currentIndex == -1 ? null : FloatingActionButtonLocation.endFloat,
    );
  }
}
