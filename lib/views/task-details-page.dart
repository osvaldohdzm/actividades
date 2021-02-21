import 'package:Actividades/models/subtaks.dart';
import 'package:circular_check_box/circular_check_box.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:Actividades/models/Item.dart';
import 'package:Actividades/database.dart';
import 'package:Actividades/widgets/notifications.dart';
import 'package:Actividades/views/date-picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Actividades/stopwatch.dart';

class TaskDetailsPage extends StatefulWidget {
  final Item task;
  const TaskDetailsPage({Key key, this.task}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TaskDetailsPageState();
}

// Adapted from the text form demo in official gallery app:
// https://github.com/flutter/flutter/blob/master/examples/flutter_gallery/lib/demo/material/text_form_field_demo.dart
class _TaskDetailsPageState extends State<TaskDetailsPage>
    with SingleTickerProviderStateMixin {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings androidInitializationSettings;
  IOSInitializationSettings iosInitializationSettings;
  InitializationSettings initializationSettings;

  var db = new DatabaseHelper();

  TextEditingController _txtTitleController;
  TextEditingController _txtDescriptionController;
  String text;
  DateTime _date = DateTime.now();
  List<String> _colors = <String>['', 'red', 'green', 'blue', 'orange'];
  String _color = '';
  int _index = 1;
  List<Widget> _subtaskFIeld = List<Widget>();
  List<Subtask> _subtaskList = List<Subtask>();
  TextEditingController txt;
  Map<String, String> _formdata = {};
  bool selected = true;
  List<bool> inputs = new List<bool>();

  void ItemChange(bool val, int index) {
    setState(() {
      //inputs[index] = val;
      selected = !selected;
      _subtaskFIeld.asMap().forEach((index, value) {
        debugPrint(index.toString() + " " + value.toString());
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _txtDescriptionController =
        new TextEditingController(text: widget.task.description);
    _txtTitleController = new TextEditingController(text: widget.task.title);

    //_subtaskList.add(new Subtask(id: 1, done: 1, title: "Ejemplo"));
    // _subtaskList.add(new Subtask(id: 1, done: 1, title: "Ejemplo"));
    /*
    txt = TextEditingController();
    txt.text = "My Stringt";
    txt.selection = TextSelection.fromPosition(
      TextPosition(offset: txt.text.length),
    );*/
    initializing();
  }

  void initializing() async {
    androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    iosInitializationSettings = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    initializationSettings = InitializationSettings(
        androidInitializationSettings, iosInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  void _showNotifications() async {
    await notification();
  }

  Future _showNotificationWithDefaultSound() async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        new AndroidNotificationDetails(
            'your channel id', 'your channel name', 'your channel description',
            importance: Importance.Max, priority: Priority.High);
    IOSNotificationDetails iOSPlatformChannelSpecifics =
        new IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'New Post',
      'How to Show Notification in Flutter',
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }

  Future<void> notification() async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            'Channel ID', 'Channel title', 'channel body',
            priority: Priority.High,
            importance: Importance.Max,
            ticker: 'test');
    IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();

    NotificationDetails notificationDetails =
        NotificationDetails(androidNotificationDetails, iosNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        0, 'Hello there', 'please subscribe my channel', notificationDetails);
  }

  Future onSelectNotification(String payLoad) {
    if (payLoad != null) {
      print(payLoad);
    }
    // we can set navigator to navigate another screen
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    return AlertDialog(
      title: Text(title),
      content: Text(body),
    );
  }

  Widget _tabSection(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            child: TabBar(tabs: [
              Tab(
                  child: Text("Previsualizar",
                      style: TextStyle(color: Colors.black))),
              Tab(child: Text("Editar", style: TextStyle(color: Colors.black))),
            ]),
          ),
          Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.grey)),

            //Add this to give height
            height: MediaQuery.of(context).size.height / 3,
            child: TabBarView(children: [
              Container(
                margin: EdgeInsets.all(8),
                child: SingleChildScrollView(
                    child: MarkdownBody(
                        onTapLink: (url) => launch(url),
                        data: _txtDescriptionController.text,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet(
                            h1: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                            h2: TextStyle(
                              fontSize: 22,
                            ),
                            h3: TextStyle(
                              fontSize: 18,
                            ),
                            p: TextStyle(fontSize: 16)))),
              ),
              Container(
                  margin: EdgeInsets.all(8),
                  child: TextField(
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      style: TextStyle(fontSize: 18),
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (String text) {
                        setState(() {
                          this.text = text;
                        });
                      },
                      controller: _txtDescriptionController,
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: "Descripción"))),
            ]),
          ),
        ],
      ),
    );
  }

  void _addNewSubTask() {
    int checkIndex;
    int keyValue = _index;

    _subtaskFIeld = List.from(_subtaskFIeld)
      ..add(CheckboxListTile(
        key: Key("${keyValue}"),
        title: new TextField(
            //controller: txt,
            //ohnchange tiene tierror
            // onChanged: (val) => _formdata['${keyValue - 1}'] = val,
            textCapitalization: TextCapitalization.sentences,
            maxLines: null,
            style: TextStyle(fontSize: 18),
            decoration: InputDecoration(
                hintText: "Key ${keyValue} index ${_index}",
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _subtaskFIeld.asMap().forEach((index, value) {
                        if (Key("${keyValue}") == value.key) {
                          _subtaskFIeld = List.of(_subtaskFIeld)
                            ..removeAt(index);
                        }
                      });
                    });
                  },
                  icon: Icon(Icons.clear),
                ),
                contentPadding: EdgeInsets.all(10))),

        value: selected,
        onChanged: (bool val) {
          ItemChange(val, checkIndex);
        },
        controlAffinity: ListTileControlAffinity.leading,
        //  <-- leading Checkbox
      ));
    if (_formdata.isNotEmpty) {
      debugPrint("El valor es: " + _formdata[_index]);
    }
    setState(() => ++_index);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          print(
              'Backbutton pressed (device or appbar button), do whatever you want.');

          //trigger leaving and use own data
          Navigator.pop(context, false);

          setState(() {});

          //we need to return a future
          return Future.value(false);
        },
        child: Scaffold(
            appBar: AppBar(
              title: const Text("Detalles"),
            ),
            body: FutureBuilder<Item>(
                future: db.getItem(widget.task.id),
                builder: (context, AsyncSnapshot<Item> snapshot) {
                  if (snapshot.hasData) {
                    return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              SizedBox(height: 6.0),
                              Row(
                                children: [
                                  CircularCheckBox(
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.padded,
                                      value:
                                          widget.task.done > 0 ? true : false,
                                      checkColor: Colors.white,
                                      activeColor: Colors.green,
                                      inactiveColor: Colors.black,
                                      disabledColor: Colors.grey,
                                      onChanged: (val) => this.setState(() {
                                            widget.task.done = (val) ? 1 : 0;
                                          })),
                                  new Flexible(
                                    child: new TextField(
                                        controller: _txtTitleController,
                                        keyboardType: TextInputType.multiline,
                                        maxLines: null,
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                        style: TextStyle(fontSize: 21),
                                        decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.all(10))),
                                  ),
                                ],
                              ),
                              new Container(
                                child: new ListView(
                                  shrinkWrap: true,
                                  children: _subtaskFIeld,
                                  scrollDirection: Axis.vertical,
                                ),
                              ),
                              SizedBox(height: 6.0),
                              Ink(
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: InkWell(
                                  onTap: _addNewSubTask,
                                  //This keeps the splash effect within the circle
                                  borderRadius: BorderRadius.circular(
                                      36.0), //Something large to ensure a circle
                                  child: Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Icon(
                                      Icons.add,
                                      size: 32.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(color: Colors.black),
                              FormField(
                                builder: (FormFieldState state) {
                                  return InputDecorator(
                                    decoration: InputDecoration(
                                      icon: const Icon(Icons.notifications),
                                      labelText: 'Recordatorio',
                                    ),
                                    isEmpty: _color == '',
                                    child: new DropdownButtonHideUnderline(
                                      child: new DropdownButton(
                                        value: _color,
                                        isDense: true,
                                        onChanged: (String newValue) {
                                          setState(() {
                                            _color = newValue;
                                            state.didChange(newValue);
                                          });
                                        },
                                        items: _colors.map((String value) {
                                          return new DropdownMenuItem(
                                            value: value,
                                            child: new Text(value),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 2.0),
                              FormField(
                                builder: (FormFieldState state) {
                                  return InputDecorator(
                                    decoration: InputDecoration(
                                      icon: const Icon(Icons.repeat),
                                      labelText: 'Repetir',
                                    ),
                                    isEmpty: _color == '',
                                    child: new DropdownButtonHideUnderline(
                                      child: new DropdownButton(
                                        value: _color,
                                        isDense: true,
                                        onChanged: (String newValue) {
                                          setState(() {
                                            _color = newValue;
                                            state.didChange(newValue);
                                          });
                                        },
                                        items: _colors.map((String value) {
                                          return new DropdownMenuItem(
                                            value: value,
                                            child: new Text(value),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 16.0),
                              Text(
                                'Fecha de vencimiento',
                                style: DefaultTextStyle.of(context)
                                    .style
                                    .apply(fontSizeFactor: 1.2),
                              ),
                              DatePicker(
                                  selectedDate: _date,
                                  onChanged: ((DateTime date) {
                                    setState(() {
                                      _date = date;
                                    });
                                  })),
                              SizedBox(height: 2.0),
                              _tabSection(context),
                              SizedBox(height: 12.0),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    RaisedButton(
                                        onPressed: _showNotifications,
                                        child: const Text('Cancelar',
                                            style: TextStyle(fontSize: 20))),
                                    SizedBox(width: 24),
                                    RaisedButton(
                                        onPressed: () {
                                          /*      _subtaskFIeld.forEach((element) {
                                            debugPrint(element.key.   .toString());
                                          });*/

                                          widget.task.title =
                                              _txtTitleController.text;
                                          widget.task.description =
                                              _txtDescriptionController.text;
                                          db
                                              .updateItem(widget.task)
                                              .then((erg) => setState(() {
                                                    Navigator.pop(
                                                        context, false);
                                                  }));
                                        },
                                        child: const Text('Guardar',
                                            style: TextStyle(fontSize: 20)))
                                  ]),
                              SizedBox(height: 2.0),
                              new StopWatch(),
                              SizedBox(height: 16.0),
                            ]));
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                })));
  }
}
