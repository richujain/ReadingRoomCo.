import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:reading_room_co/aboutdata.dart';
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

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  var databaseReference;
  List<AboutData> aboutList = [];

  @override
  void initState() {
    fetchAboutDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: true,
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
    child: FutureBuilder(
      future: fetchAboutDetails(),
      builder: (context,snapshot){
        return Container(
          child: Column(
            children: [






              new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(15.0, 15.0, 0.0, 15.0),
                        child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                'assets/images/logo.png',
                                height: 150,
                                width: 150,
                              ),
                            )
                        ),
                      ),
                    ),
                  ]
              ),
              new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "Reading Room Co. is an independent online publication platform dedicated to exploring literature, politics, society and culture. We embody a creative, publishing practice that integrates critical engagement with literature as well as contemporary socio-political issues. We offer fiction, articles, poetry and interviews by setting the stage for aspiring writers to share their creations, and readers to reflect on them. Reading Room Co. is essentially a progressive space that encourages writers to explore and experiment with their creativity as well as develop a strong sense of inquiry. Be it fiction, nonfiction or poetry, we offer stories that are diverse, political, and original.",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                            height: 2,
                          ),
                        )),
                  ]
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),













              new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                      child:
                      ClipRRect(
                        borderRadius:
                        BorderRadius.circular(16.0),
                        child: Image.network(aboutList[0].imageurl,fit: BoxFit.contain,),
                      )
                    //
                  ),
                ),
              ]
          ),
              new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          ""+aboutList[0].about,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                            height: 2,
                          ),
                        )),
                  ]
              ),






              new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      child: Container(
                          child: ClipRRect(
                            borderRadius:
                            BorderRadius.circular(100.0),
                            child: Image.network(aboutList[1].imageurl,fit: BoxFit.contain,),
                          )
                        //
                      ),
                    ),
                  ]
              ),
              new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          ""+aboutList[1].about,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                            height: 2,
                          ),
                        )),
                  ]
              ),








              new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      child: Container(
                          child: ClipRRect(
                            borderRadius:
                            BorderRadius.circular(100.0),
                            child: Image.network(aboutList[2].imageurl,fit: BoxFit.contain,),
                          )
                        //
                      ),
                    ),
                  ]
              ),
              new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          ""+aboutList[2].about,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                            height: 2,
                          ),
                        )),
                  ]
              ),







              new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      child: Container(
                          child: ClipRRect(
                            borderRadius:
                            BorderRadius.circular(100.0),
                            child: Image.network(aboutList[3].imageurl,fit: BoxFit.contain,),
                          )
                        //
                      ),
                    ),
                  ]
              ),
              new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          ""+aboutList[3].about,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                            height: 2,
                          ),
                        )),
                  ]
              ),













              new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      child: Container(
                          child: ClipRRect(
                            borderRadius:
                            BorderRadius.circular(100.0),
                            child: Image.network(aboutList[4].imageurl,fit: BoxFit.contain,),
                          )
                        //
                      ),
                    ),
                  ]
              ),
              new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          ""+aboutList[4].about,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                            height: 2,
                          ),
                        )),
                  ]
              ),



            ],
          ),
        );
      },
    )
            ),
        ),
    );
  }
  fetchAboutDetails() {
    databaseReference = FirebaseDatabase.instance.reference().child("about").orderByChild("order").once();
    databaseReference.then((DataSnapshot snap)
    {
      if(snap.value != null){
        var keys = snap.value.keys;
        var data = snap.value;
        aboutList.clear();
        for(var individualKey in keys){
          AboutData aboutData = new AboutData(
            data[individualKey]['name'],
            data[individualKey]['imageurl'],
            data[individualKey]['about'],
            data[individualKey]['order'],
          );
          aboutList.add(aboutData);
          if(mounted){
            setState(() {
            });
          }
        }
        aboutList.sort((a, b) => a.order.compareTo(b.order));
      }
    });
  }
}
