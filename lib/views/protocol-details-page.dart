import 'package:Actividades/models/protocol.dart';
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

class ProtocolDetailsPage extends StatefulWidget {
  final Protocol protocol;
  const ProtocolDetailsPage({Key key, this.protocol}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProtocolDetailsPageState();
}

// Adapted from the text form demo in official gallery app:
// https://github.com/flutter/flutter/blob/master/examples/flutter_gallery/lib/demo/material/text_form_field_demo.dart
class _ProtocolDetailsPageState extends State<ProtocolDetailsPage>
    with SingleTickerProviderStateMixin {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings androidInitializationSettings;
  IOSInitializationSettings iosInitializationSettings;
  InitializationSettings initializationSettings;

  var db = new DatabaseHelper();

  TextEditingController _textEditingController;
  TabController _tabController;
  String text;
  DateTime _date = DateTime.now();
  List<String> _colors = <String>['', 'red', 'green', 'blue', 'orange'];
  String _color = '';
  int _count = 1;

  @override
  void initState() {
    super.initState();
    _textEditingController = widget.protocol.description == null
        ? new TextEditingController(text: "")
        : new TextEditingController(text: widget.protocol.description);
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _tabSection(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            child: TabBar(controller: _tabController, tabs: [
              Tab(
                  child: Text("Previsualizar",
                      style: TextStyle(color: Colors.black))),
              Tab(child: Text("Editar", style: TextStyle(color: Colors.black))),
            ]),
          ),
          Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.grey)),

            //Add this to give height
            height: MediaQuery.of(context).size.height - 240,
            child: TabBarView(controller: _tabController, children: [
              Container(
                margin: EdgeInsets.all(8),
                child: SingleChildScrollView(
                    child: MarkdownBody(
                        onTapLink: (url) => launch(url),
                        data: _textEditingController.text,
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
                      style: TextStyle(fontSize: 16),
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (String text) {
                        setState(() {
                          this.text = text;
                        });
                      },
                      controller: _textEditingController,
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: "Descripción"))),
            ]),
          ),
        ],
      ),
    );
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
            body: FutureBuilder<Protocol>(
                future: db.getProtocol(widget.protocol.id),
                builder: (context, AsyncSnapshot<Protocol> snapshot) {
                  if (snapshot.hasData) {
                    return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              SizedBox(height: 12.0),
                              _tabSection(context),
                              SizedBox(height: 12.0),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    RaisedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Cancelar',
                                            style: TextStyle(fontSize: 20))),
                                    SizedBox(width: 24),
                                    RaisedButton(
                                        onPressed: () {
                                          widget.protocol.description =
                                              _textEditingController.text;

                                          debugPrint("Descripcion nueva es: " +
                                              widget.protocol.description);

                                          db
                                              .updateProcotol(widget.protocol)
                                              .then((erg) => setState(() {
                                                    Scaffold.of(context)
                                                        .showSnackBar(SnackBar(
                                                      content: Text(
                                                          "Cambios guardados"),
                                                    ));
                                                    _tabController.animateTo(0);
                                                  }));
                                        },
                                        child: const Text('Guardar',
                                            style: TextStyle(fontSize: 20)))
                                  ]),
                              SizedBox(height: 16.0),
                            ]));
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                })));
  }
}
