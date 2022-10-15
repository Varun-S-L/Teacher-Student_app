import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:teachers_app/Teacher/homepage.dart';
import 'package:teachers_app/model/model.dart';
import 'package:teachers_app/model/firebasehelper.dart';
import 'package:teachers_app/style/googlefonts.dart';
import 'package:teachers_app/tesstudent/studenttestpage.dart';

import 'home.dart';
import 'register.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isObscure3 = true;
  bool visible = false;
  final _formkey = GlobalKey<FormState>();
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[400],
      body: ListView(children: [
        Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/85002.png", height: 230, width: 180),
                Text(
                  'Hello',
                  style: googlerobotowhite(context),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Sign in to continue',
                  style: googlerobotowhitesmall(context),
                ),
              ],
            )),
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30))),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Form(
                  key: _formkey,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Email',
                            enabled: true,
                            contentPadding: const EdgeInsets.only(
                                left: 14.0, bottom: 8.0, top: 8.0),
                            focusedBorder: OutlineInputBorder(
                              borderSide: new BorderSide(color: Colors.white),
                              borderRadius: new BorderRadius.circular(10),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: new BorderSide(color: Colors.white),
                              borderRadius: new BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value!.length == 0) {
                              return "Email cannot be empty";
                            }
                            if (!RegExp(
                                    "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                                .hasMatch(value)) {
                              return ("Please enter a valid email");
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) {
                            emailController.text = value!;
                          },
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          controller: passwordController,
                          obscureText: _isObscure3,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                                icon: Icon(_isObscure3
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                onPressed: () {
                                  setState(() {
                                    _isObscure3 = !_isObscure3;
                                  });
                                }),
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Password',
                            enabled: true,
                            contentPadding: const EdgeInsets.only(
                                left: 14.0, bottom: 8.0, top: 15.0),
                            focusedBorder: OutlineInputBorder(
                              borderSide: new BorderSide(color: Colors.white),
                              borderRadius: new BorderRadius.circular(10),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: new BorderSide(color: Colors.white),
                              borderRadius: new BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            RegExp regex = new RegExp(r'^.{6,}$');
                            if (value!.isEmpty) {
                              return "Password cannot be empty";
                            }
                            if (!regex.hasMatch(value)) {
                              return ("please enter valid password min. 6 character");
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) {
                            passwordController.text = value!;
                          },
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ])),
              SizedBox(
                height: 20,
              ),
              custombutton(
                onpress: () {
                  setState(() {
                    visible = true;
                  });
                  signIn(emailController.text, passwordController.text);
                },
                title: 'SIGN IN',
                icon: Icons.arrow_forward_ios,
              ),
              smallbutton(
                onpress: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Register(),
                    ),
                  );
                },
                title: 'SIGN UP',
              )
            ],
          ),
        ),
      ]),
    );
  }

  void signIn(String email, String password) async {
    if (_formkey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        String uid = userCredential.user!.uid;
        DocumentSnapshot userData =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        UserModel userModel =
            UserModel.fromMap(userData.data() as Map<String, dynamic>);

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(
                    userModel: userModel,
                    firebaseUser: userCredential.user!,
                  )
              // (rooll == '')
              //     ? searchhomestudent(
              //         userModel: userModel,
              //         firebaseUser: userCredential.user!,
              //       )
              //     : searchhome(
              //         userModel: userModel,
              //         firebaseUser: userCredential.user!,
              //       ),
              ),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          print('No user found for that email.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No user found for that email.'),
            ),
          );
        } else if (e.code == 'wrong-password') {
          print('Wrong password provided for that user.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Wrong password provided for that user'),
            ),
          );
        }
      }
    }
  }
}

class smallbutton extends StatelessWidget {
  final String title;
  final VoidCallback onpress;

  const smallbutton({super.key, required this.title, required this.onpress});
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          SizedBox(
            height: 20,
          ),
          MaterialButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            height: 20,
            elevation: 0,
            onPressed: onpress,
            color: Colors.grey[100],
            child: Text(
              title,
              style: TextStyle(
                color: Color.fromARGB(255, 8, 8, 8),
                fontSize: 10,
              ),
            ),
          )
        ]));
  }
}

class custombutton extends StatelessWidget {
  final VoidCallback onpress;
  final String title;
  final IconData icon;

  const custombutton(
      {super.key,
      required this.onpress,
      required this.title,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onpress,
      child: Container(
        margin: EdgeInsets.only(left: 50, right: 50),
        padding: EdgeInsets.only(right: 10),
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          color: Colors.blue[500],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Spacer(),
            Text(
              title,
              style: googlerobotowhitesmall(context),
            ),
            Spacer(),
            Icon(
              icon,
              size: 20,
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }
}
