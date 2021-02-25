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
import 'package:reading_room_co/history.dart';
import 'package:reading_room_co/postdata.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:reading_room_co/starred.dart';
import 'package:reading_room_co/viewpost.dart';
import 'wp-api.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'postdata.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';


class SendFeedback extends StatefulWidget {
  @override
  _SendFeedbackState createState() => _SendFeedbackState();
}

class _SendFeedbackState extends State<SendFeedback> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String ratingValue = "5";
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
        physics: BouncingScrollPhysics(),
        child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

                Container(
                  child: Stack(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(15.0, 110.0, 0.0, 0.0),
                        child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                'assets/images/circle_logo.jpg',
                                height: 150,
                                width: 150,
                              ),
                            )
                        ),
                      ),


                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 50.0,left: 20.0, right: 20.0),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 20),
                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(top: 15.0, left: 20.0),
                        child: RatingBar.builder(
                            initialRating: 5,
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              switch (index) {
                                case 0:
                                  return Icon(
                                    Icons.sentiment_very_dissatisfied,
                                    color: Colors.red,
                                  );
                                case 1:
                                  return Icon(
                                    Icons.sentiment_dissatisfied,
                                    color: Colors.redAccent,
                                  );
                                case 2:
                                  return Icon(
                                    Icons.sentiment_neutral,
                                    color: Colors.amber,
                                  );
                                case 3:
                                  return Icon(
                                    Icons.sentiment_satisfied,
                                    color: Colors.lightGreen,
                                  );
                                case 4:
                                  return Icon(
                                    Icons.sentiment_very_satisfied,
                                    color: Colors.green,
                                  );
                              }
                            },
                            onRatingUpdate: (rating) {
                              print(rating);
                              ratingValue = ""+rating.toString();
                            },

                        ),
                      ),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                            labelText: 'Title',
                            labelStyle: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.green)
                            )
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        keyboardType: TextInputType.multiline,
                        maxLength: null,
                        maxLines: null,
                        controller: descriptionController,
                        decoration: InputDecoration(
                            labelText: 'Description',
                            labelStyle: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.green)
                            )
                        ),
                      ),
                      SizedBox(height: 40),
                      Container(
                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                        height: 50.0,
                        child: Material(
                          borderRadius: BorderRadius.circular(20.0),
                          color: Colors.green,
                          elevation: 7.0,
                          child: GestureDetector(
                            onTap: (){

                            },

                            child: Center(
                              child : InkWell(
                                child: Text("Send Feedback",style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Montserrat'
                                ),),
                                onTap: () {
                                  print("tapped");
                                  writeToDatabase();

                                  // here you write the codes to input the data into firestore

                                },
                              )
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ],
            ),
          ),
      ),
    );
  }

  void writeToDatabase() {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final User user = auth.currentUser;
  final uid = user.uid;
  if(titleController.text.isEmpty){
    print("Title is Empty!");
  }
  else if(descriptionController.text.isEmpty){
    print("Description is Empty!");

  }else{
  String title = titleController.text.trim();
  String description = descriptionController.text.trim();
  final databaseReference = FirebaseDatabase.instance.reference();
  databaseReference.child(uid).child("feedback").push().set({
  'title' : title,
  'desciption' : description,
  'rating' : ratingValue,
  }).then((value) => Navigator.pop(context));
  }
}}
