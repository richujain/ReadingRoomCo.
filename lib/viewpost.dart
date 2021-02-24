import 'dart:convert';
import 'dart:convert' show utf8;
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:reading_room_co/authentication_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_wordpress/flutter_wordpress.dart' as wp;
import 'package:http/http.dart' as http;
import 'package:reading_room_co/postdata.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'wp-api.dart';
import 'dart:math' as math;
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:firebase_database/firebase_database.dart';

class ViewPost extends StatefulWidget {
  PostData postData = new PostData("loading...","loading...","loading...","loading...","loading...","loading...");
  ViewPost({Key key, @required this.postData}) : super(key: key);

  @override
  _ViewPostState createState() => _ViewPostState();
}

class _ViewPostState extends State<ViewPost> {
  wp.WordPress wordPress;
  String selectedFont = "Roboto";
  final ThemeData specialThemeData = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.yellow[700],
    // and so on...
  );
  @override
  Widget build(BuildContext context) {
    var content;
    var postId;
    var category;
    var author;
    var imageurl;
    var title;
    readFont();
    if(widget.postData.content != null){
      String tempContent = widget.postData.content;
      content = tempContent.replaceAll('http://', 'https://');
    }
    if(widget.postData.title != null){
      title = widget.postData.title;
    }
    if(widget.postData.postId != null){
      postId = widget.postData.postId;
    }
    if(widget.postData.category != null){
      category = widget.postData.category;
    }
    if(widget.postData.author != null){
      author = widget.postData.author;
    }
    if(widget.postData.imageurl != null){
      imageurl = widget.postData.imageurl;
    }
    final FirebaseAuth auth = FirebaseAuth.instance;

    void inputData() {
      final User user = auth.currentUser;
      final uid = user.uid;
      // here you write the codes to input the data into firestore
      final databaseReference = FirebaseDatabase.instance.reference();

      databaseReference.child(uid).child("history").child("$postId").set({
        'postid' : postId,
        'title' : ""+title,
        'category' : ""+category,
        'author' : ""+author,
        'imageurl' : ""+imageurl,
        'content' : ""+content,
      });
    }
    inputData();
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
        body: FutureBuilder(
               future: readFont(),
                builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasData) {
                return Container(
                    child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end, children: <
                            Widget>[
                          Row(
                              children: [
                                Expanded(
                                  child: Container(
                                      child: Column(children: [
                                        Container(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8.0),
                                            child: Image.network(
                                              imageurl,
                                                errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                                  return Text('');
                                                }),
                                          ),
                                          padding: EdgeInsets.fromLTRB(
                                              8.0, 0.0, 8.0, 0.0),
                                          //Image.network(imageUrl,fit: BoxFit.contain,)
                                        ),
                                        Container(
                                          padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                                          child: Text(
                                            title,
                                            style: GoogleFonts.openSans(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 22,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                                              child: Text(
                                                "Author : $author",
                                                style: GoogleFonts.openSans(
                                                  fontSize: 15,
                                                  fontStyle: FontStyle.italic,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
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
                                        SingleChildScrollView(
                                          child: Html(
                                            data: """
                               $content
                              """,
                                            padding: EdgeInsets.all(8.0),
                                            onLinkTap: (url) {
                                              print("Opening $url...");
                                            },
                                            customRender: (node, children) {
                                              if (node is dom.Element) {
                                                switch (node.localName) {
                                                  case "custom_tag": // using this, you can handle custom tags in your HTML
                                                    return Column(children: children);
                                                }
                                              }
                                            },

                                            defaultTextStyle: GoogleFonts.getFont(selectedFont,textStyle:TextStyle(fontSize: 18,
                                              color: Colors.black,
                                              fontWeight: FontWeight.normal,
                                              height: 2,),
                                            ),

                                          ),
                                        ),
                                      ])),
                                ),
                              ]),
                        ],
                        )
                    )); // your widget
                } else return CircularProgressIndicator();
                }
                ));






  }



  void initializeWordpress() {
    // adminName and adminKey is needed only for admin level APIs
    wordPress = wp.WordPress(
      baseUrl: 'https://readingroomco.com/wp-json/wp/v2/posts/',
      authenticator: wp.WordPressAuthenticator.JWT,
      adminName: '',
      adminKey: '',
    );
  }

    Future<String> readFont() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'selectedFont';
    final value = prefs.getString(""+key) ?? "";
    if(value == ""){
      selectedFont = "Roboto";
      return "Roboto";
      print("selectedFont while reading" + selectedFont);
    }
    else{
      selectedFont = value;
      return value;
      print("selectedFont while reading" + selectedFont);

    }
  }
}
