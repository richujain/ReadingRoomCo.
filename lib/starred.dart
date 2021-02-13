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
import 'package:reading_room_co/viewpost.dart';
import 'wp-api.dart';
import 'dart:math' as math;
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:firebase_database/firebase_database.dart';

class Starred extends StatefulWidget {
  @override
  _StarredState createState() => _StarredState();
}

class _StarredState extends State<Starred> {
  List<PostData> postList = [];
  PostData postdata = new PostData("loading...","loading...","loading...","loading...","loading...","loading...");
  DatabaseReference databaseReference;
  String uid;

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;
    uid = user.uid;
    // here you write the codes to input the data into firestore
    databaseReference = FirebaseDatabase.instance.reference().child(uid).child("starred");
    databaseReference.once().then((DataSnapshot snap)
    {
      if(snap.value != null){
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
          if(mounted){
            setState(() {

            });
          }
        }
      }
    });
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
        body: uid==null && uid.length==0 ? Text("Loading") : Container(
          child: postList.length == 0 ? new Text("Nothing To Display!") : new ListView.builder(
            itemCount: postList.length,
            physics: BouncingScrollPhysics(),
            itemBuilder: (_, index){
              return PostsUI(postList[index].postId.toString(), postList[index].title, postList[index].author, postList[index].category, postList[index].content, postList[index].imageurl);
            },
          ),
        ) );
  }

  Widget PostsUI(String postId, String title, String author, String category, String content, String imageUrl){
    return new Card(
      elevation: 10.0,
      margin:   EdgeInsets.all(15.0),
    child: InkWell(
    onTap: () {
    // Function is executed on tap.
      postdata.postId = postId;
      postdata.title = title;
      postdata.imageurl = imageUrl;
      postdata.category = category;
      postdata.content = content;
      postdata.author = author;
      Navigator.of(context).push(_createRoute());
    },
      onLongPress: (){
          postList.remove(postdata);
          //print("postlist lenghth"+postList.length.toString());
          FirebaseDatabase.instance.reference().child(uid).child("starred").child(postId).remove();
          if(postList.length <= 1){
            Navigator.of(context).pop();
          }
      },
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
                Container(
                  padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: AutoSizeText(
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
                  child: AutoSizeText(
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
    ));
  }
  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => ViewPost(
        postData: postdata,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
        Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

}
