import 'package:Actividades/models/protocol.dart';
import 'package:Actividades/views/protocol-details-page.dart';
import 'package:Actividades/widgets/drawer.dart';
import 'package:Actividades/views/tasks-page.dart';
import 'package:flutter/material.dart';
import 'package:Actividades/database.dart';
import 'package:flutter/widgets.dart';

class ProtocolsPage extends StatefulWidget {
  @override
  ProtocolsPageState createState() => ProtocolsPageState();
}

class ProtocolsPageState extends State<ProtocolsPage> {
  var db = new DatabaseHelper();

  int currentIndex;
  int listlen;
  int l;
  bool flag = true;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<String> choices = ['Blue', 'Red', 'Green', 'Yellow', 'Dark'];
  Map<String, Color> choiceColorMap = {
    'Blue': Colors.blue,
    'Green': Colors.green,
    'Red': Colors.red,
    'Yellow': Colors.amber,
    'Dark': Colors.grey[600]
  };

  @override
  initState() {
    super.initState();
    currentIndex = -1;
    flag = true;
  }

  Future<Protocol> createAlertDialogForEditingList(context, Protocol item) {
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
                      'Editar protocolo',
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
                          return 'Nombre del protocolo';
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
                                Navigator.of(context).pop(Protocol(
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

  Future<Protocol> createAlertDialogForProtocol(context, List<Protocol> list) {
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
                      'Nombre del protocolo:',
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
                                Navigator.of(context).pop(Protocol(
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

  List<Protocol> globalList;

  // Handler called by ReorderableListView onReorder after a list child is
  // dropped into a new position.
  void _onReorder(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) {
      newIndex -= 1;

      globalList.forEach((element) {
        debugPrint(element.orderIndex.toString());
      });

      globalList[oldIndex].orderIndex = globalList[newIndex].orderIndex;
      await db.updateProcotol(globalList[1]);
      for (var i = 0; i < globalList.length; i++) {
        if (globalList[i].orderIndex < globalList[newIndex].orderIndex) {
          globalList[i].orderIndex--;
          await db.updateProcotol(globalList[i]);
        }
      }
      globalList[newIndex].orderIndex--;
      await db.updateProcotol(globalList[newIndex]);
    } else {
      globalList.forEach((element) {
        debugPrint(element.orderIndex.toString());
      });
      debugPrint("***********************");
      globalList[oldIndex].orderIndex = globalList[newIndex].orderIndex;
      await db.updateProcotol(globalList[oldIndex]);
      for (var i = 0; i < globalList.length; i++) {
        if (globalList[i].orderIndex > globalList[newIndex].orderIndex) {
          globalList[i].orderIndex++;
          await db.updateProcotol(globalList[i]);
        }
      }
      globalList[newIndex].orderIndex++;
      await db.updateProcotol(globalList[newIndex]);
    }

    debugPrint("***********************");
    globalList.forEach((element) {
      debugPrint(element.orderIndex.toString());
    });

    setState(() {});
  }

  Widget emptyPage(context, List<Protocol> protocols, Function setState) {
    return Scaffold(
        appBar: AppBar(title: Text('Sin listas')),
        body: Center(
          child: Text('Vacio'),
        ));
  }

  Widget viewMenu(
      context, List<Protocol> protocols, Function setState, Protocol listtodo) {
    List<Widget> list = List<Widget>();
    globalList = protocols;
    if (protocols.length > 0) {
      List<Widget> temp = List<Widget>.generate(protocols.length, (index) {
        Protocol job = protocols[index];
        return Card(
          key: UniqueKey(),
          child: ListTile(
            onTap: () async {
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ProtocolDetailsPage(protocol: protocols[index])))
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
                  createAlertDialogForEditingList(context, protocols[index])
                      .then((value) async {
                    if (value != null) {
                      protocols[index].name = value.name;
                      await db.updateProcotol(protocols[index]);
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
                  await db.deleteProtocol(protocols[index].id);
                  setState(() {
                    if (currentIndex == index) {
                      if (protocols.length == 1)
                        currentIndex = -1;
                      else if (index == protocols.length - 1) currentIndex--;
                    } else if (currentIndex == protocols.length - 1)
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
    return FutureBuilder<List<Protocol>>(
        future: db.getAllProtocols(),
        builder: (BuildContext context,
            AsyncSnapshot<List<Protocol>> protocolsprotocolsnapshopt) {
          if (protocolsprotocolsnapshopt.hasData) {
            if (flag) {
              l = protocolsprotocolsnapshopt.data.length;
              if (l == 0)
                currentIndex = -1;
              else
                currentIndex = 0;
              flag = false;
            }

            if (l == protocolsprotocolsnapshopt.data.length &&
                currentIndex < protocolsprotocolsnapshopt.data.length) {
              return Scaffold(
                key: _scaffoldKey,
                drawer: NavigationDrawer(),
                floatingActionButton: FloatingActionButton(
                    child: Icon(Icons.add),
                    backgroundColor: Colors.blue,
                    onPressed: () async {
                      await createAlertDialogForProtocol(
                              context, protocolsprotocolsnapshopt.data)
                          .then((value) async {
                        if (value != null) {
                          await db.newProtocol(value.name, "",
                              protocolsprotocolsnapshopt.data.length + 1);
                          l++;
                          if (currentIndex == -1)
                            currentIndex = 0;
                          else
                            currentIndex =
                                protocolsprotocolsnapshopt.data.length;
                          setState(() {});
                        }
                      });
                    }),
                appBar: AppBar(
                  title: Text('Protocolos ' +
                      '(' +
                      protocolsprotocolsnapshopt.data.length.toString() +
                      ')'),
                  backgroundColor: Colors.blue,
                  leading: IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () {
                      _scaffoldKey.currentState.openDrawer();
                    },
                  ),
                ),
                body: currentIndex == -1
                    ? Center(child: Text('Vacio'))
                    : viewMenu(
                        context,
                        protocolsprotocolsnapshopt.data,
                        setState,
                        protocolsprotocolsnapshopt.data[currentIndex]),
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
