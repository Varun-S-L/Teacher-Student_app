import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:teachers_app/Teacher/notificationroom.dart';
import 'package:teachers_app/login.dart';
import 'package:teachers_app/main.dart';
import 'package:teachers_app/model/model.dart';
import 'package:teachers_app/model/chatroommodel.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SearchPage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchcontroller = TextEditingController();
  Future<ChatRoom?> getnotificationroomModel(UserModel targetUser) async {
    ChatRoom? notifyroom;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("notificationroom")
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();
    if (snapshot.docs.length > 0) {
      var docData = snapshot.docs[0].data();
      ChatRoom existingnotroom =
          ChatRoom.fromMap(docData as Map<String, dynamic>);
      notifyroom = existingnotroom;
    } else {
      ChatRoom newnotificationroom = ChatRoom(
          chatroomid: uuid.v1(),
          lastMessage: "",
          participants: {
            widget.userModel.uid.toString(): true,
            targetUser.uid.toString(): true
          });
      await FirebaseFirestore.instance
          .collection("notificationroom")
          .doc(newnotificationroom.chatroomid)
          .set(newnotificationroom.toMap());
      notifyroom = newnotificationroom;
      log("new chatroom created");
    }
    return notifyroom;
  }

  @override
  Widget build(BuildContext context) {
    String wrool = 'Student';
    return Scaffold(
      appBar: AppBar(
        title: Text('search'),
      ),
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(children: [
          TextField(
              controller: searchcontroller,
              decoration: InputDecoration(labelText: 'Email address')),
          SizedBox(
            height: 20,
          ),
          CupertinoButton(
              child: Text('Search'),
              color: Colors.blue,
              onPressed: () {
                setState(() {});
              }),
          SizedBox(
            height: 20,
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("users")
                .where("email", isEqualTo: searchcontroller.text)
                //.where("wrool", isEqualTo: wrool)
                .where("email", isNotEqualTo: widget.userModel.email)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                  if (dataSnapshot.docs.length > 0) {
                    Map<String, dynamic> userMap =
                        dataSnapshot.docs[0].data() as Map<String, dynamic>;
                    UserModel searcheduser = UserModel.fromMap(userMap);

                    return (searcheduser.wrool.toString() == 'Student')
                        ? ListTile(
                            onTap: () async {
                              ChatRoom? notificationroommodel =
                                  await getnotificationroomModel(searcheduser);
                              if (notificationroommodel != null) {
                                Navigator.pop(context);
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return notificaionroom(
                                    targetuser: searcheduser,
                                    firebaseUser: widget.firebaseUser,
                                    userModel: widget.userModel,
                                    notificationroom: notificationroommodel,
                                  );
                                }));
                              }
                            },
                            title: Text(searcheduser.email.toString()),
                            trailing: Icon(Icons.arrow_forward_ios),
                          )
                        : Text('No Results Found');
                  } else {
                    return Text('No Results Found');
                  }
                } else if (snapshot.hasError) {
                  return Text('An Error occured');
                } else {
                  return Text('No Results Found');
                }
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
        ]),
      )),
    );
  }
}
