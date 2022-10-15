import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:teachers_app/Teacher/homepage.dart';

import 'package:teachers_app/home.dart';
import 'package:teachers_app/login.dart';
import 'package:teachers_app/model/model.dart';
import 'package:teachers_app/model/firebasehelper.dart';
import 'package:uuid/uuid.dart';

import 'register.dart';

var uuid = Uuid();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  User? currentuser = FirebaseAuth.instance.currentUser;
  if (currentuser != null) {
    UserModel? thisusermodel =
        await FirebaseHelper.getUserModelById(currentuser.uid);
    if (thisusermodel != null) {
      runApp(MyAppLoggedIn(
        usermodel: thisusermodel,
        firebaseuser: currentuser,
      ));
    } else {
      runApp(MyApp());
    }
  } else {
    runApp(MyApp());
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.blue[900],
        ),
        home: LoginPage());
  }
}

class MyAppLoggedIn extends StatelessWidget {
  final UserModel usermodel;
  final User firebaseuser;

  const MyAppLoggedIn(
      {super.key, required this.usermodel, required this.firebaseuser});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.blue[900],
        ),
        home: HomePage(userModel: usermodel, firebaseUser: firebaseuser));
  }
}





// class MyAppLoggedIn extends StatefulWidget {
//   final UserModel usermodel;
//   final User firebaseuser;

//   const MyAppLoggedIn(
//       {super.key, required this.usermodel, required this.firebaseuser});

//   @override
//   _MyAppLoggedInState createState() => _MyAppLoggedInState();
// }

// class _MyAppLoggedInState extends State<MyApp> {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//           primaryColor: Colors.blue[900],
//         ),
//         home: HomePage()
//         //HomePage(),
//         );
//   }
// }
