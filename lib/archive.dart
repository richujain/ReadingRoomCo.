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
import 'package:url_launcher/url_launcher.dart';
import 'package:reading_room_co/starred.dart';
import 'package:reading_room_co/viewpost.dart';
import 'archive.dart';
import 'wp-api.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'postdata.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';



class Archive extends StatefulWidget {
  _Archive createState() => _Archive();
}

class _Archive extends State<Archive> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool closeTopContainer = false;
  wp.WordPress wordPress;
  final String url = "https://readingroomco.com/";
  int offset = 0;
  int currentMax = 10;
  String api = "wp-json/wp/v2/posts?_embed&per_page=10";
  List wp_posts;
  var postId;
  List<PostData> posts = [];
  PostData post;
  PostData postdata = new PostData(
      "loading...", "loading...", "loading...", "loading...", "loading...",
      "loading...");
  Future categoryFuture;
  String valueChoose = "Latest Posts";
  bool isLoading = false;
  final databaseReference = FirebaseDatabase.instance.reference();
  List<String> starredPosts = [];
  DatabaseReference databaseReferenceForStarred;
  String uid;
  StreamBuilder streamBuilder;
  Future<List> futureData;

  @override
  void initState() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;
    uid = user.uid;
    void inputDataOnce() {
      databaseReferenceForStarred =
          FirebaseDatabase.instance.reference().child(uid).child("starred");
      databaseReferenceForStarred.once().then((DataSnapshot snap) {
        var keys = snap.value.keys;
        var data = snap.value;
        starredPosts.clear();
        for (var individualKey in keys) {
          String starredPost = data[individualKey]['imageurl'].toString();
          starredPosts.add(starredPost);
        }
        setState(() {

        });
      });
    }
    inputDataOnce();
    futureData = fetchWpPosts(api);
    // scrollController.addListener(() {
    //   if(scrollController.position.pixels == scrollController.position.maxScrollExtent){
    //     print("hello");
    //     getMoreData();
    //   }
    // });
    super.initState();
  }

  nextButtonForMoreData(){
    currentMax += 10;
    api = "wp-json/wp/v2/posts?_embed&per_page=10&offset=$currentMax";
    var tempFutureData = fetchWpPosts(api);
    setState(() {
      futureData = tempFutureData;
    });
    print("next is pressed");
  }


  @override
  Widget build(BuildContext context) {
    initializeWordpress();
    final Size size = MediaQuery
        .of(context)
        .size;

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
        child: ConstrainedBox(
          constraints: BoxConstraints(),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                        alignment: Alignment.bottomLeft,
                        width: MediaQuery
                            .of(context)
                            .size
                            .width / 2,
                        child: MaterialButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.white)
                          ),
                          elevation: 0,
                          height: 50,
                          onPressed: () {


                          },
                          color: Colors.blue,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(FontAwesomeIcons.arrowCircleLeft),
                              SizedBox(width: 20),
                              Text("Previous",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16)),
                            ],
                          ),
                          textColor: Colors.white,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                        alignment: Alignment.bottomLeft,
                        width: MediaQuery
                            .of(context)
                            .size
                            .width / 2,
                        child: MaterialButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.white)
                          ),
                          elevation: 0,
                          height: 50,
                          onPressed: () {
                            nextButtonForMoreData();
                          },
                          color: Colors.blue,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text("Next",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16)),
                              SizedBox(width: 20),
                              Icon(FontAwesomeIcons.arrowCircleRight),
                            ],
                          ),
                          textColor: Colors.white,
                        ),
                      ),
                    ]
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                isLoading && uid == null && uid.length == 0
                    ? Center(
                  child: CircularProgressIndicator(),
                ) : postsAsRow(size, api),



              ]),
        ),
      ),
    );
  }

  Row postsAsRow(var size, var api) {
    return new Row(
      children: [
        Flexible(
          child: FutureBuilder(
            future: futureData,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Center(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height-210, // card height
                    child: new ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        Map wpPost = snapshot.data[index];
                        var imageUrl;
                        if (snapshot.data[index]["_embedded"]
                        ["wp:featuredmedia"] !=
                            null) {
                          imageUrl = wpPost["_embedded"]["wp:featuredmedia"][0]
                          ["source_url"];
                        } else {
                          imageUrl =
                          "https://www.readingroomco.com/wp-content/uploads/2020/12/IMG_3643.jpg";
                        }
                        String title = wpPost['title']['rendered'];
                        String category =
                        wpPost['_embedded']['wp:term'][0][0]['name'];
                        postId = wpPost['id'];
                        var author = wpPost['_embedded']['author'][0]['name'];
                        var unescape = new HtmlUnescape();
                        var convertedTitle = unescape.convert(title);
                        var content = wpPost['content']['rendered'];
                        post = new PostData(postId, convertedTitle, author, category, content, imageUrl);
                        posts.add(post);

                        return GestureDetector(
                          onTap: () {
                            postdata.postId = postId;
                            postdata.title = convertedTitle;
                            postdata.imageurl = imageUrl;
                            postdata.category = category;
                            postdata.content = content;
                            postdata.author = author;
                            Navigator.of(context).push(_createRoute());
                          },
                          onLongPress: () {
                            databaseReference.child(uid).child("starred").child(
                                "" + postId.toString()).set({
                              'author': author.toString(),
                              'category': category.toString(),
                              'content': content.toString(),
                              'imageurl': imageUrl.toString(),
                              'postid': postId.toString(),
                              'title': convertedTitle.toString(),
                            });
                            Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text("Added to Starred"),
                              duration: const Duration(seconds: 1),
                            ));
                          },





                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 100,
                                width: size.width,
                                child: Container(
                                    child: ClipRRect(
                                      borderRadius:
                                      BorderRadius.circular(8.0),
                                      child: Image.network(
                                        posts[index].imageurl,
                                      ),
                                    )
                                  //Image.network(imageUrl,fit: BoxFit.contain,)
                                ),
                              ),
                              Container(
                                  padding: EdgeInsets.all(8),
                                  child: AutoSizeText(
                                    posts[index].title,
                                    style: GoogleFonts.roboto(
                                        textStyle: TextStyle(
                                            fontSize: 20,
                                            color: Colors.black,
                                            fontWeight:
                                            FontWeight.bold)),
                                    maxLines: 3,
                                  )),
                              Container(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  "Author : " + posts[index].author.toString(),
                                  style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 15),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  "Category : " +
                                      posts[index].category.toString(),
                                  style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: SizedBox(
                      child: CircularProgressIndicator(),
                      height: 25.0,
                      width: 25.0,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          ViewPost(
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
  void initializeWordpress() {
    // adminName and adminKey is needed only for admin level APIs
    wordPress = wp.WordPress(
      baseUrl: 'https://readingroomco.com/wp-json/wp/v2/posts',
      authenticator: wp.WordPressAuthenticator.JWT,
      adminName: '',
      adminKey: '',
    );
  }

 


}
