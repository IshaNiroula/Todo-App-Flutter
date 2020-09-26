import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String input = "";

  createTodos() {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("My Todos").doc(input);

    Map<String, String> todos = {
      "todoTitle": input,
      "date": DateTime.now().toString().substring(0, 10),
      "time": TimeOfDay.now().toString().substring(10, 15),
    };

    documentReference.set(todos).whenComplete(
          () => print("$input created"),
        );
  }

  deleteTodos(input) {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("My Todos").doc(input);

    documentReference.delete().whenComplete(
          () => print("$input Deleted"),
        );
  }

  GlobalKey _key = GlobalKey();

  TextEditingController _newMediaLinkAddressController =
      TextEditingController();

  TextEditingController _dateController = TextEditingController();

  TextEditingController _timeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    //When there is no data in firebase
    Widget snapshotHasNoData() {
      return Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 25,
            child: Container(
              width: 300,
              height: 550,
              child: Image.asset(
                "images/todo.png",
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: Text(
              "TO-DO",
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            top: 30,
            right: 20,
            child: InkWell(
              onTap: () => print("Pressed Image"),
              child: CircleAvatar(
                backgroundImage: AssetImage("images/todo_pic.jpg"),
                radius: 32,
              ),
            ),
          ),
          Positioned(
            top: 70,
            right: 15,
            child: Icon(
              Icons.add_circle,
              color: Colors.greenAccent,
            ),
          ),
        ],
      );
    }

    //When you create the todo-list app and that is returned in your Screen
    Widget snapshotHasData() {
      return StreamBuilder(
        stream: FirebaseFirestore.instance.collection("My Todos").snapshots(),
        builder: (context, snapshots) {
          if (snapshots.data.documents.length != 0) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshots.data.documents.length,
              itemBuilder: (context, index) {
                DocumentSnapshot data = snapshots.data.documents[index];
                return Card(
                  child: ListTile(
                    title: Text(
                      data.data()["todoTitle"] ?? "",
                    ),
                    subtitle: Column(
                      children: [
                        Text(
                          data.data()["date"] ?? "",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          data.data()["time"] ?? "",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.cyan,
                      ),
                      onPressed: () {
                        deleteTodos(data.data()["todoTitle"] ?? '');
                      },
                    ),
                  ),
                );
              },
            );
          } else {
            return snapshotHasNoData();
          }
        },
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFF2D2F41),
      body: snapshotHasData(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("Pressed");
          addTask();
          _newMediaLinkAddressController.clear();
        },
        backgroundColor: Colors.white,
        tooltip: "Add New Task",
        child: Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
    );
  }

  //This is the UI for todo method creation
  addTask() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      backgroundColor: Colors.grey,
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: 8.0,
            ),
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                children: [
                  Form(
                    key: _key,
                    child: TextField(
                      onChanged: (String text) {
                        input = text;
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Add Task',
                        hintStyle: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      autofocus: true,
                      controller: _newMediaLinkAddressController,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.calendar_today,
                          color: Colors.cyanAccent,
                          size: 30,
                        ),
                        onPressed: () async {
                          DateTime showdate = DateTime(2018);
                          FocusScope.of(context).requestFocus(FocusNode());
                          showdate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2018),
                            lastDate: DateTime(2025),
                          );
                          _dateController.text =
                              showdate.toString().substring(0, 10);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.date_range,
                          color: Colors.cyanAccent,
                          size: 30,
                        ),
                        onPressed: () async {
                          DateTime now = DateTime.now();
                          TimeOfDay showtime = TimeOfDay.now();
                          FocusScope.of(context).requestFocus(FocusNode());
                          showtime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(
                              hour: now.hour,
                              minute: now.minute,
                            ),
                          );
                          _timeController.text = showtime.toString();
                        },
                      ),
                      Spacer(),
                      FlatButton(
                        onPressed: () {
                          createTodos();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Save",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
