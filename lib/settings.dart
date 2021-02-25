import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:reading_room_co/authentication_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_wordpress/flutter_wordpress.dart' as wp;
import 'package:http/http.dart' as http;
import 'package:reading_room_co/booklists.dart';
import 'package:reading_room_co/history.dart';
import 'package:reading_room_co/postdata.dart';
import 'package:reading_room_co/sendfeedback.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:reading_room_co/starred.dart';
import 'package:reading_room_co/viewpost.dart';
import 'archive.dart';
import 'wp-api.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'postdata.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String selectedFont;
  final TextEditingController passwordFirstController = TextEditingController();
  final TextEditingController passwordSecondController =
      TextEditingController();

  List<String> googleFonts = [
    'Roboto',
    'Open Sans',
    'Montserrat',
    'Yellowtail',
    'Baskervville'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Reading Room Co.",
            style: GoogleFonts.yellowtail(
                textStyle: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold))),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
            Column(children: [
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: Container(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              FutureBuilder(
                  future: fetchFont(),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                          padding: EdgeInsets.all(0),
                          child: Column(children: [
                            Container(
                              padding:
                                  EdgeInsets.fromLTRB(15.0, 15.0, 0.0, 0.0),
                              child: Center(
                                  child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  height: 150,
                                  width: 150,
                                ),
                              )),
                            ),
                            Container(
                              padding:
                                  EdgeInsets.fromLTRB(15.0, 15.0, 0.0, 15.0),
                              child: Center(
                                child: Text(
                                  "Version 1.1.2",
                                  style: GoogleFonts.getFont(
                                    selectedFont,
                                    textStyle: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal,
                                      height: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),


                            new Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Text(
                                      "Preferred Font",
                                      style: GoogleFonts.getFont(
                                        selectedFont,
                                        textStyle: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          height: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: DropdownButton<String>(
                                      value: selectedFont,
                                      icon: Icon(Icons.arrow_downward),
                                      iconSize: 24,
                                      elevation: 16,
                                      style:
                                          TextStyle(color: Colors.deepPurple),
                                      underline: Container(
                                        height: 2,
                                        color: Colors.deepPurpleAccent,
                                      ),
                                      onChanged: (String newValue) {
                                        setState(() {
                                          selectedFont = newValue;
                                          saveFont();
                                        });
                                      },
                                      items: googleFonts
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ]),



                            Container(
                                padding: EdgeInsets.only(
                                    top: 0.0, left: 20.0, right: 20.0),
                                child: Column(children: <Widget>[
                                  SizedBox(height: 20),
                                  TextField(
                                    controller: passwordFirstController,
                                    decoration: InputDecoration(
                                        labelText: 'New Password',
                                        labelStyle: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.green))),
                                    obscureText: true,
                                  ),
                                  SizedBox(height: 20),
                                  TextField(
                                    controller: passwordSecondController,
                                    decoration: InputDecoration(
                                        labelText: 'Confirm Password',
                                        labelStyle: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.green))),
                                    obscureText: true,
                                  ),
                                  SizedBox(height: 40),
                                  MaterialButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                        side: BorderSide(color: Colors.white)),
                                    elevation: 0,
                                    minWidth: double.maxFinite,
                                    height: 50,
                                    onPressed: () {
                                      if(passwordFirstController.value.text.trim() == passwordSecondController.value.text.trim()){
                                        _changePassword(""+passwordFirstController.value.text.trim().toString());
                                      }
                                      else{
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Password does not match. Try Again."),duration: const Duration(seconds: 1),));
                                      }
                                    },
                                    color: Colors.green,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        SizedBox(width: 10),
                                        Text('Change Passowrd',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16)),
                                      ],
                                    ),
                                    textColor: Colors.white,
                                  ),
                                ])),









                          ]));
                    } else {
                      return Container(
                        child: Text("Something is not right"),
                      );
                    }
                  }),
              SizedBox(
                height: 30,
              ),
              Container(
                padding: EdgeInsets.only(
                    top: 0.0, left: 20.0, right: 20.0, bottom: 20.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: MaterialButton(
                    padding: EdgeInsets.all(8.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.white)),
                    elevation: 0,
                    minWidth: double.maxFinite,
                    height: 50,
                    onPressed: () async {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacementNamed('/');
                      context.read<AuthenticationService>().signOut();
                    },
                    color: Colors.red,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Logout',
                            style: TextStyle(color: Colors.white, fontSize: 16)),
                      ],
                    ),
                    textColor: Colors.white,
                  ),
                ),
              ),
            ]),
          ])),
    );
  }

  void _changePassword(String password) async {
    //Create an instance of the current user.
    User user = FirebaseAuth.instance.currentUser;

    //Pass in the password to updatePassword.
    user.updatePassword(password).then((_) {
      print("Successfully changed password");
    }).catchError((error) {
      print("Password can't be changed" + error.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed : " + error.message),duration: const Duration(seconds: 3),));
      //This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
    });
  }

  saveFont() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'selectedFont';
    prefs.setString(key, selectedFont);
    print('saved $selectedFont');
  }

  Future<String> fetchFont() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'selectedFont';
    final value = prefs.getString("" + key) ?? "";
    if (value == "") {
      selectedFont = "Roboto";
      return "Roboto";
    } else {
      selectedFont = value;
      return value;
    }
  }
}
