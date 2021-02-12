import 'dart:convert';
import 'dart:convert' show utf8;
import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:reading_room_co/authentication_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_wordpress/flutter_wordpress.dart' as wp;
import 'package:http/http.dart' as http;
import 'package:reading_room_co/postdata.dart';
import 'wp-api.dart';
import 'dart:math' as math;
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:firebase_database/firebase_database.dart';

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List<PostData> postList = [];

DatabaseReference databaseReference;
  @override
  void initState() {

    final FirebaseAuth auth = FirebaseAuth.instance;

    void inputData() {
    final User user = auth.currentUser;
    final uid = user.uid;
    // here you write the codes to input the data into firestore
    databaseReference = FirebaseDatabase.instance.reference().child(uid).child("history");
    }
    inputData();
    databaseReference.once().then((DataSnapshot snap)
    {
      var keys = snap.value.keys;
      var data = snap.value;
      postList.clear();
      for(var individualKey in keys){
        PostData postData = new PostData(
          data[individualKey]['postid'],
          data[individualKey]['title'],
          data[individualKey]['author'],
          data[individualKey]['category'],
          data[individualKey]['content'],
          data[individualKey]['imageurl'],
        );
        postList.add(postData);
      }
      setState(() {

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Container(
          child: postList.length == 0 ? new Text("Nothing To Display!") : new ListView.builder(
            itemCount: postList.length,
            itemBuilder: (_, index){
              return PostsUI(postList[index].postId.toString(), postList[index].title, postList[index].author, postList[index].category, postList[index].content, postList[index].imageurl);
            },
          ),
      ) );
  }
  Widget PostsUI(String postId, String title, String author, String category, String content, String imageUrl){
    return Flexible(
      child: new Card(
        elevation: 10.0,
        margin:   EdgeInsets.all(15.0),
        child: new Container(
          padding: new EdgeInsets.all(14.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new  Container(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    imageUrl,
                    errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                      return Text('');
                    },
                  ),
                ),
                padding: EdgeInsets.fromLTRB(
                    8.0, 0.0, 8.0, 0.0),
                //Image.network(imageUrl,fit: BoxFit.contain,)
              ),
              new Container(
                padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: AutoSizeText(
                  title,
                  style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight:
                          FontWeight.bold)),
                  maxLines: 3,
                )),
              new Row(
                mainAxisAlignment: MainAxisAlignment
                    .spaceBetween,
                children: [
                  Flexible(child: Container(
                    padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                    child: Text(
                      "Author : $author",
                      style: GoogleFonts.openSans(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: Colors.black,
                      ),
                    ),
                  ),),

                  Container(
                    padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                    child: Text(
                      "Category : $category",
                      style: GoogleFonts.openSans(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),



            ],
          ),
        ),
      ),
    );
  }
}
