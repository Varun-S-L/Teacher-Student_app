import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:teachers_app/main.dart';
import 'package:teachers_app/model/model.dart';
import 'package:teachers_app/model/chatroommodel.dart';
import 'package:teachers_app/model/notificationmodel.dart';

class notificaionroomstudent extends StatefulWidget {
  final UserModel targetuser;
  final ChatRoom notificationroom;
  final UserModel userModel;
  final User firebaseUser;

  const notificaionroomstudent(
      {super.key,
      required this.targetuser,
      required this.notificationroom,
      required this.userModel,
      required this.firebaseUser});

  @override
  State<notificaionroomstudent> createState() => _notificaionroomstudentState();
}

class _notificaionroomstudentState extends State<notificaionroomstudent> {
  TextEditingController messagecontroller = TextEditingController();

  void sendMessage() async {
    String notify = messagecontroller.text.trim();
    messagecontroller.clear();
    if (notify != "") {
      MessageModel newnotification = MessageModel(
        messageid: uuid.v1(),
        sender: widget.userModel.uid,
        createdate: DateTime.now(),
        text: notify,
        seen: false,
      );
      FirebaseFirestore.instance
          .collection("notificationroom")
          .doc(widget.notificationroom.chatroomid)
          .collection("messages")
          .doc(newnotification.messageid)
          .set(newnotification.toMap());
      widget.notificationroom.lastMessage = notify;
      FirebaseFirestore.instance
          .collection("notificationroom")
          .doc(widget.notificationroom.chatroomid)
          .set(widget.notificationroom.toMap());

      log("message sent");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.targetuser.email.toString()),
      ),
      body: SafeArea(
          child: Container(
        child: Column(
          children: [
            Expanded(
                child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("notificationroom")
                    .doc(widget.notificationroom.chatroomid)
                    .collection("messages")
                    .orderBy("createdate", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot datasnapshot =
                          snapshot.data as QuerySnapshot;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: PageView.builder(
                          // reverse: true,
                          itemCount: datasnapshot.docs.length,
                          itemBuilder: (context, index) {
                            MessageModel currentmessage = MessageModel.fromMap(
                                datasnapshot.docs[index].data()
                                    as Map<String, dynamic>);
                            MessageModel currentdate = MessageModel.fromMap(
                                datasnapshot.docs[index].data()
                                    as Map<String, dynamic>);

                            DateTime now = DateTime.now();
                            int difference =
                                now.difference(currentdate.createdate!).inDays;
                            print(difference);
                            if (difference > 30) {
                              snapshot.data!.docs[index].reference.delete();
                            }

                            return Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                margin: EdgeInsets.symmetric(
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                    color: Colors.blue[100],
                                    borderRadius: BorderRadius.circular(5)),
                                child: Column(
                                  children: [
                                    Text(
                                      currentmessage.text.toString(),
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    Spacer(),
                                    Text(DateFormat('d MMM')
                                        .format(currentdate.createdate!)
                                        .toString()),
                                    TextButton(
                                        onPressed: () {},
                                        child: Text('Understood'))
                                  ],
                                ));
                          },
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text("error occured"),
                      );
                    } else {
                      return Center(
                        child: Text("Send Notifications to your student"),
                      );
                    }
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            )),
          ],
        ),
      )),
    );
  }
}
