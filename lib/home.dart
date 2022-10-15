import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:teachers_app/Teacher/homepage.dart';

import 'package:teachers_app/tesstudent/studenttestpage.dart';

import 'model/model.dart';

class HomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const HomePage(
      {super.key, required this.userModel, required this.firebaseUser});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  _HomePageState();
  @override
  Widget build(BuildContext context) {
    return contro(
      userModel: widget.userModel,
      firebaseUser: widget.firebaseUser,
    );
  }
}

class contro extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const contro(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  _controState createState() => _controState();
}

class _controState extends State<contro> {
  _controState();
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  var rooll;
  var emaill;
  var id;
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("users") //.where('uid', isEqualTo: user!.uid)
        .doc(user!.uid)
        .get()
        .then((value) {
      this.loggedInUser = UserModel.fromMap(value.data());
    }).whenComplete(() {
      CircularProgressIndicator();
      setState(() {
        //emaill = loggedInUser.email.toString();
        rooll = loggedInUser.wrool.toString();
        //id = loggedInUser.uid.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    CircularProgressIndicator();
    return routing();
  }

  routing() {
    if (rooll == 'Student') {
      return searchhomestudent(
          userModel: widget.userModel, firebaseUser: widget.firebaseUser);
    } else {
      return searchhome(
          userModel: widget.userModel, firebaseUser: widget.firebaseUser);
    }
  }
}
