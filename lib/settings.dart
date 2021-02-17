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
  List<String> googleFonts = [
    'Roboto',
    'Open Sans',
    'Montserrat',
    'Yellowtail',
    'Baskervville'
  ];

  @override
  Widget build(BuildContext context) {
    readFont();
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  future: readFont(),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                          padding: EdgeInsets.all(0),
                          child: Column(children: [
                            Text(
                              "Preferred Font",
                              style: GoogleFonts.getFont(
                                selectedFont,
                                textStyle: TextStyle(
                                  fontSize: 24,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  height: 2,
                                ),
                              ),
                            ),
                            DropdownButton<String>(
                              value: selectedFont,
                              icon: Icon(Icons.arrow_downward),
                              iconSize: 24,
                              elevation: 16,
                              style: TextStyle(color: Colors.deepPurple),
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
                              items: googleFonts.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ]));
                    }
                    else{
                      return Container(
                        child: Text("Something is not right"),
                      );
                    }
                  }),
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
            ]),
          ])),
    );
  }

  saveFont() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'selectedFont';
    prefs.setString(key, selectedFont);
    print('saved $selectedFont');
  }

  Future<String> readFont() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'selectedFont';
    final value = prefs.getString("" + key) ?? "";
    if (value == "") {
      selectedFont = "Roboto";
      return "Roboto";
      print("selectedFont while reading" + selectedFont);
    } else {
      selectedFont = value;
      return value;
      print("selectedFont while reading" + selectedFont);
    }
  }
}
