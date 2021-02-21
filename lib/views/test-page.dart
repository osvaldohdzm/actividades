import 'package:circular_check_box/circular_check_box.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Actividades/widgets/drawer.dart';

class TestPage extends StatefulWidget {
  TestPage({Key key, this.title}) : super(key: key);

  static const String routeName = '/TestPage';

  final String title;

  @override
  TestPageState createState() => TestPageState();
}

class TestPageState extends State<TestPage> {
  final List<String> names = <String>[
    'Aby',
    'Aish',
    'Ayan',
    'Ben',
    'Bob',
    'Charlie',
    'Cook',
    'Carline'
  ];
  final List<int> msgCount = <int>[2, 0, 10, 6, 52, 4, 0, 2];

  TextEditingController nameController = TextEditingController();
  bool selected = true;
  void addItemToList() {
    setState(() {
      names.insert(0, nameController.text);
      msgCount.insert(0, 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue,
        appBar: AppBar(
          title: Text('Flutter Tutorial - googleflutter.com'),
        ),
        drawer: NavigationDrawer(),
        body: Column(children: <Widget>[
          Padding(
            padding: EdgeInsets.all(20),
            child: TextField(
              controller: nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Contact Name',
              ),
            ),
          ),
          RaisedButton(
            child: Text('Add'),
            onPressed: () {
              addItemToList();
            },
          ),
          Expanded(
              child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: names.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      height: 50,
                      margin: EdgeInsets.all(2),
                      color: msgCount[index] >= 10
                          ? Colors.blue[400]
                          : msgCount[index] > 3
                              ? Colors.blue[100]
                              : Colors.grey,
                      child: Center(
                          child: Text(
                        '${names[index]} (${msgCount[index]})',
                        style: TextStyle(fontSize: 18),
                      )),
                    );
                  })),
          ListTile(
            leading: CircularCheckBox(
                materialTapTargetSize: MaterialTapTargetSize.padded,
                value: this.selected,
                checkColor: Colors.white,
                activeColor: Colors.green,
                inactiveColor: Colors.redAccent,
                disabledColor: Colors.grey,
                onChanged: (val) => this.setState(() {
                      this.selected = !this.selected;
                    })),
            title: Text("Click me"),
            onTap: () => this.setState(() {
              this.selected = !this.selected;
            }),
          ),
        ]));
  }
}
