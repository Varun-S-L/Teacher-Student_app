import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:teachers_app/Teacher/notificationroom.dart';
import 'package:teachers_app/Teacher/searchpage.dart';
import 'package:teachers_app/login.dart';
import 'package:teachers_app/model/model.dart';
import 'package:teachers_app/model/chatroommodel.dart';
import 'package:teachers_app/model/firebasehelper.dart';
import 'package:teachers_app/tesstudent/studentroommodel.dart';

class searchhomestudent extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const searchhomestudent(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<searchhomestudent> createState() => _searchhomestudentState();
}

class _searchhomestudentState extends State<searchhomestudent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(widget.userModel.email.toString()),
        actions: [
          IconButton(
            onPressed: () {
              logout(context);
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("notificationroom")
                .where("participants.${widget.userModel.uid}", isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot notificationroomsnapshot =
                      snapshot.data as QuerySnapshot;

                  return ListView.builder(
                    itemCount: notificationroomsnapshot.docs.length,
                    itemBuilder: (context, index) {
                      ChatRoom notificationroommodel = ChatRoom.fromMap(
                          notificationroomsnapshot.docs[index].data()
                              as Map<String, dynamic>);
                      Map<String, dynamic> participants =
                          notificationroommodel.participants!;
                      List<String> participantkeys = participants.keys.toList();
                      participantkeys.remove(widget.userModel.uid);
                      return FutureBuilder(
                          future: FirebaseHelper.getUserModelById(
                              participantkeys[0]),
                          builder: (context, userData) {
                            if (userData.connectionState ==
                                ConnectionState.done) {
                              if (userData.data != null) {
                                UserModel targetUser =
                                    userData.data as UserModel;
                                return Card(
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return notificaionroomstudent(
                                            targetuser: targetUser,
                                            notificationroom:
                                                notificationroommodel,
                                            userModel: widget.userModel,
                                            firebaseUser: widget.firebaseUser);
                                      }));
                                    },
                                    title: Text(targetUser.email.toString()),
                                    subtitle: Text(notificationroommodel
                                        .lastMessage
                                        .toString()),
                                  ),
                                );
                              } else {
                                return Container();
                              }
                            } else {
                              return Container();
                            }
                          });
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                } else {
                  return Center(
                    child: Text("NO notifications"),
                  );
                }
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    CircularProgressIndicator();
    await FirebaseAuth.instance.signOut();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }
}
