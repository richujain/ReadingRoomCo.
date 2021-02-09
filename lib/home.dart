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
import 'package:reading_room_co/viewpost.dart';
import 'wp-api.dart';
import 'dart:math' as math;
import 'package:auto_size_text/auto_size_text.dart';
import 'postdata.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';



class HomePage extends StatefulWidget {
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool closeTopContainer = false;
  wp.WordPress wordPress;
  final String url = "https://readingroomco.com/";
  final String api = "wp-json/wp/v2/posts?_embed";
  List wp_posts;
  var postId;
  PostData postdata = new PostData();
  Future categoryFuture;
  final String categoriesApi = "wp-json/wp/v2/categories";
  String valueChoose="Latest Posts";
  bool isLoading = false;
  final databaseReference = FirebaseDatabase.instance.reference();



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    categoryFuture = fetchWpPosts(categoriesApi);
  }

  @override
  Widget build(BuildContext context) {
    initializeWordpress();
    //print('posts'+wp_posts.toString());
    final Size size = MediaQuery.of(context).size;
    int index = 0;
    List listItem = [
      "Latest Posts",
      "Fiction",
      "Graphic Novel",
      "Interview",
      "Memoir",
      "Poetry",
      "Review",
      "Essay",
      "Series",
      "K Saraswathi Amma"
    ];
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
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: 100.0,
                child: DrawerHeader(
                  child: Text('Hello, ' + _firebaseAuth.currentUser.displayName,style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight:
                          FontWeight.bold)),),
                  decoration: BoxDecoration(
                    // image: DecorationImage(
                    //     image: AssetImage("assets/images/logo.jpg"),
                    //       fit: BoxFit.cover
                    //
                    // ),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                // Update the state of the app.
                // ...
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.star),
              title: Text('Starred'),
              onTap: () {
                // Update the state of the app.
                // ...
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('History'),
              onTap: () {
                // Update the state of the app.
                // ...
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: Icon(Icons.rate_review),
              title: Text('Send Feedback'),
              onTap: () {
                // Update the state of the app.
                // ...
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.money),
              title: Text('Donate'),
              onTap: () {
                // Update the state of the app.
                // ...
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                // Update the state of the app.
                // ...
                Navigator.pop(context);
              },
            ),

            // Divider(
            //   height: 1,
            //   thickness: 1,
            // ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                // Update the state of the app.
                // ...
                //_signOut();
                context.read<AuthenticationService>().signOut();
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
    child: ConstrainedBox(
    constraints: BoxConstraints(),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: EdgeInsets.only(left: 16,right: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: DropdownButton(
                      hint: Text("Select Category",
                          style: GoogleFonts.roboto(
                              textStyle: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontWeight:
                                  FontWeight.bold))),
                      icon: Icon(Icons.arrow_drop_down),
                      iconSize: 36,
                      isExpanded: true,
                      underline: SizedBox(),
                      style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                              fontSize: 20,
                              color: Colors.black,)),
                      value: valueChoose,
                      onChanged: (newValue) {
                        setState(() {
                          isLoading = true;
                          valueChoose = newValue;
                          postsByCategory(size);
                          Future.delayed(const Duration(milliseconds: 10), () {
                            setState(() {
                              isLoading = false;
                            });

                          });
                        });
                      },
                      items: listItem.map((valueItem) {
                        return DropdownMenuItem(
                          value: valueItem,
                          child: Text(valueItem),
                        );
                      }).toList()),
                ),
              ),
              isLoading
                  ? Center(
                child: CircularProgressIndicator(),
              ): postsByCategory(size),
            ]),
      ),
      ),
    );
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

  postsByCategory(var size) {
    String api;
    switch(valueChoose){
      case "Latest Posts":
        api = "wp-json/wp/v2/posts?_embed";
        return categoryPostsAsRow(size,api);
        break;
      case "Fiction" :
        api = "wp-json/wp/v2/posts?_embed&categories=7&per_page=100";
        return categoryPostsAsRow(size,api);
        break;
      case "Graphic Novel" :
        api = "wp-json/wp/v2/posts?_embed&categories=196&per_page=100";
        return categoryPostsAsRow(size,api);
        break;
      case "Interview" :
        api = "wp-json/wp/v2/posts?_embed&categories=11&per_page=100";
        return categoryPostsAsRow(size,api);
        break;
      case "Memoir" :
        api = "wp-json/wp/v2/posts?_embed&categories=12&per_page=100";
        return categoryPostsAsRow(size,api);
        break;
      case "Poetry" :
        api = "wp-json/wp/v2/posts?_embed&categories=8&per_page=100";
        return categoryPostsAsRow(size,api);
        break;
      case "Review" :
        api = "wp-json/wp/v2/posts?_embed&categories=5&per_page=100";
        return categoryPostsAsRow(size,api);
        break;
      case "Essay" :
        api = "wp-json/wp/v2/posts?_embed&categories=10&per_page=100";
        return categoryPostsAsRow(size,api);
        break;
      case "Series" :
        api = "wp-json/wp/v2/posts?_embed&categories=194&per_page=100";
        return categoryPostsAsRow(size,api);
        break;
      case "K Saraswathi Amma" :
        api = "wp-json/wp/v2/posts?_embed&categories=13&per_page=100";
        return categoryPostsAsRow(size,api);
        break;
      default:
        api = "wp-json/wp/v2/posts?_embed";
        return categoryPostsAsRow(size,api);
        break;
    }
  }
  Row categoryPostsAsRow(var size,var api){
    return new Row(
      children: [
        Flexible(
          child: FutureBuilder(
            future: fetchWpPosts(api),
            builder: (context, snapshot) {
              int _index = 0;
              if (snapshot.hasData) {
                return Center(
                  child: SizedBox(
                    height: 400, // card height
                    child: PageView.builder(
                      allowImplicitScrolling: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data.length,
                      controller:
                      PageController(viewportFraction: 0.7, initialPage: 0),
                      onPageChanged: (int index) =>
                          setState(() => _index = index),
                      itemBuilder: (BuildContext context, int index) {
                        List colors = [
                          Colors.redAccent,
                          Colors.greenAccent,
                          Colors.yellow,
                          Colors.pinkAccent,
                          Colors.deepPurpleAccent,
                          Colors.deepOrangeAccent,
                          Colors.cyanAccent,
                          Colors.amberAccent,
                          Colors.lightBlueAccent,
                          Colors.lightGreenAccent,
                          Colors.limeAccent,
                          Colors.tealAccent
                        ];
                        Random random = new Random();
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
                          child: Transform.scale(
                            scale: index == _index ? 1 : 0.95,
                            child: Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              child: Container(
                                //color: colors[index],
                                child: Center(
                                    child: Container(
                                      /*
                                              * decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: NetworkImage(imageUrl),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              * */
                                      padding: EdgeInsets.all(8),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 200,
                                            width: size.width,
                                            child: Container(
                                                child: ClipRRect(
                                                  borderRadius:
                                                  BorderRadius.circular(8.0),
                                                  child: Image.network(
                                                    imageUrl,
                                                  ),
                                                )
                                              //Image.network(imageUrl,fit: BoxFit.contain,)
                                            ),
                                          ),
                                          Container(
                                              padding: EdgeInsets.all(8),
                                              child: AutoSizeText(
                                                convertedTitle,
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
                                              "Author : " + author.toString(),
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                  fontSize: 15),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(8),
                                            child: Text(
                                              "Category : " + category.toString(),
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                  fontSize: 15),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                              ),
                            ),
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
