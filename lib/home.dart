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
import 'package:reading_room_co/settings.dart';
import 'package:reading_room_co/submission.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:reading_room_co/starred.dart';
import 'package:reading_room_co/viewpost.dart';
import 'archive.dart';
import 'wp-api.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'postdata.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

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
  String displayName = "";
  PostData postdata = new PostData("loading...", "loading...", "loading...",
      "loading...", "loading...", "loading...");
  Future categoryFuture;
  final String categoriesApi = "wp-json/wp/v2/categories";
  String valueChoose = "Latest Posts";
  bool isLoading = false;
  final databaseReference = FirebaseDatabase.instance.reference();
  List<String> starredPosts = [];
  DatabaseReference databaseReferenceForStarred;
  String uid;
  List<BookLists> bookLists = [];
  // LinkedScrollControllerGroup _controllers;
  // ScrollController _singleChildScrollViewController = new ScrollController();
  // ScrollController _staggeredViewController = new ScrollController();

  List colors = [
    Colors.deepOrangeAccent,
    Colors.cyan,
    Colors.lightGreen,
    Colors.purpleAccent,
    Colors.blue,
    Colors.grey,
  ];

  @override
  void initState() {

    if (_firebaseAuth.currentUser.displayName != null) {
      displayName = _firebaseAuth.currentUser.displayName;
    }
    categoryFuture = fetchWpPosts(categoriesApi);
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;
    uid = user.uid;
    void fetchBookRecommendation() {
      final databaseReferenceForBookList =
          FirebaseDatabase.instance.reference().child("booklists");
      databaseReferenceForBookList.once().then((DataSnapshot snap) {
        var keys = snap.value.keys;
        var data = snap.value;

        bookLists.clear();
        for (var individualKey in keys) {
          BookLists book = new BookLists(
            data[individualKey]['name'],
            data[individualKey]['link'],
            data[individualKey]['icon'],
            data[individualKey]['postid'],
          );
          bookLists.add(book);
          if (this.mounted) {
            setState(() {
              // Your state change code goes here
            });
          }
        }
        for (var i = 0; i < 6; i++) {
          print("" + bookLists[5].name);
        }
      });
    }

    fetchBookRecommendation();

    void inputDataOnce() {
      databaseReferenceForStarred =
          FirebaseDatabase.instance.reference().child(uid).child("starred");
      databaseReferenceForStarred.once().then((DataSnapshot snap) {

        try{
          if(snap.value.keys != null){
            var keys = snap.value.keys;
            var data = snap.value;
            //starredPosts.clear();
            for (var individualKey in keys) {
              String starredPost = data[individualKey]['imageurl'].toString();
              starredPosts.add(starredPost);
            }
            setState(() {});
          }
        }catch(e){
          print(e);
        }

      }

      );
    }

    inputDataOnce();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    initializeWordpress();
    final Size size = MediaQuery.of(context).size;
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
                  child: Text(
                    'Hello, ' + displayName,
                    style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold)),
                  ),
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
              leading: Icon(Icons.archive),
              title: Text('Archive'),
              onTap: () {
                // Update the state of the app.
                // ...
                Navigator.pop(context);
                Navigator.of(context).push(_createRouteToArchive());
              },
            ),
            ListTile(
              leading: Icon(Icons.star),
              title: Text('Starred'),
              onTap: () {
                // Update the state of the app.
                // ...
                Navigator.pop(context);
                Navigator.of(context).push(_createRouteToStarred());
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('History'),
              onTap: () {
                // Update the state of the app.
                // ...
                Navigator.pop(context);
                Navigator.of(context).push(_createRouteToHistory());
              },
            ),
            ListTile(
              leading: Icon(Icons.rate_review),
              title: Text('Submission'),
              onTap: () {
                // Update the state of the app.
                // ...
                Navigator.pop(context);
                Navigator.of(context).push(_createRouteToSubmission());
              },
            ),
            ListTile(
              leading: Icon(Icons.rate_review),
              title: Text('About'),
              onTap: () {
                // Update the state of the app.
                // ...
                Navigator.pop(context);
                Navigator.of(context).push(_createRouteToAbout());
              },
            ),

            ListTile(
              leading: Icon(Icons.rate_review),
              title: Text('Send Feedback'),
              onTap: () {
                // Update the state of the app.
                // ...
                Navigator.pop(context);
                Navigator.of(context).push(_createRouteToSendFeedback());
              },
            ),
            ListTile(
              leading: Icon(Icons.money),
              title: Text('Donate'),
              onTap: () {
                Navigator.pop(context);
                const url = 'http://paypal.me/readingroomco';
                launchURL(url);
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                // Update the state of the app.
                // ...
                Navigator.pop(context);
                Navigator.of(context).push(_createRouteToSettings());
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
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/');
                context.read<AuthenticationService>().signOut();
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        //controller: _singleChildScrollViewController,
        physics: BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
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
                    child: DropdownButton(
                        hint: Text("Select Category",
                            style: GoogleFonts.roboto(
                                textStyle: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold))),
                        icon: Icon(Icons.arrow_drop_down),
                        iconSize: 36,
                        isExpanded: true,
                        underline: SizedBox(),
                        style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        )),
                        value: valueChoose,
                        onChanged: (newValue) {
                          setState(() {
                            isLoading = true;
                            valueChoose = newValue;
                            postsByCategory(size);
                            Future.delayed(const Duration(milliseconds: 10),
                                () {
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
                isLoading && uid == null && uid.length == 0
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : postsByCategory(size),

                Container(
                  padding: EdgeInsets.fromLTRB(25, 25, 8, 20),
                  alignment: Alignment.centerLeft,
                  child: AutoSizeText(
                    "Top Suggestions",
                    style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                            fontSize: 25,
                            color: Colors.black,
                            fontWeight: FontWeight.bold)),
                  ),
                ),




                Container(
                  child: new StaggeredGridView.countBuilder(
                      physics: NeverScrollableScrollPhysics(),
                    //controller: _staggeredViewController,
                      primary: false,
                        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                        crossAxisCount: 2,
                      shrinkWrap: true,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 10,
                      itemCount: bookLists.length,
                      itemBuilder: (BuildContext context, int index) => new Container(
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(15))
                              ),
                              child: Column(
                            children: [
                              new Expanded(
                                child: InkWell(
                                  child: Image.network(
                                    ""+bookLists[index].icon,fit: BoxFit.cover,
                                    errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                                      return Text('Image Unavailable');
                                    },
                                  ),
                                  onTap:(){
                                  },
                                ),
                              ),
                    ]),
                          )),
                      staggeredTileBuilder: (index) {
                        return StaggeredTile.count(1, index.isEven ? 1.2 : 1.8);
                      }
                    ),
                ),


                Container(
                  padding: EdgeInsets.fromLTRB(25, 25, 8, 8),
                  alignment: Alignment.bottomCenter,
                  child: InkWell(
                    child: Text(
                      "Visit our Website : ReadingRoomCo.com",
                      style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                          fontStyle: FontStyle.italic),
                    ),
                    onTap: () {
                      const url = 'https://readingroomco.com';
                      launchURL(url);
                    },
                  ),
                ),
















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

  Route _createRouteToHistory() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => History(),
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
  Route _createRouteToSubmission() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => Submission(),
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


  Route _createRouteToSettings() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => Settings(),
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

  Route _createRouteToSendFeedback() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => SendFeedback(),
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

  Route _createRouteToStarred() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => Starred(),
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

  Route _createRouteToArchive() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => Archive(),
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
    switch (valueChoose) {
      case "Latest Posts":
        api = "wp-json/wp/v2/posts?_embed";
        return isLoading
            ? CircularProgressIndicator()
            : categoryPostsAsRow(size, api);
        break;
      case "Fiction":
        api = "wp-json/wp/v2/posts?_embed&categories=7&per_page=100";
        return isLoading
            ? CircularProgressIndicator()
            : categoryPostsAsRow(size, api);
        break;
      case "Graphic Novel":
        api = "wp-json/wp/v2/posts?_embed&categories=196&per_page=100";
        return isLoading
            ? CircularProgressIndicator()
            : categoryPostsAsRow(size, api);
        break;
      case "Interview":
        api = "wp-json/wp/v2/posts?_embed&categories=11&per_page=100";
        return isLoading
            ? CircularProgressIndicator()
            : categoryPostsAsRow(size, api);
        break;
      case "Memoir":
        api = "wp-json/wp/v2/posts?_embed&categories=12&per_page=100";
        return isLoading
            ? CircularProgressIndicator()
            : categoryPostsAsRow(size, api);
        break;
      case "Poetry":
        api = "wp-json/wp/v2/posts?_embed&categories=8&per_page=100";
        return isLoading
            ? CircularProgressIndicator()
            : categoryPostsAsRow(size, api);
        break;
      case "Review":
        api = "wp-json/wp/v2/posts?_embed&categories=5&per_page=100";
        return isLoading
            ? CircularProgressIndicator()
            : categoryPostsAsRow(size, api);
        break;
      case "Essay":
        api = "wp-json/wp/v2/posts?_embed&categories=10&per_page=100";
        return isLoading
            ? CircularProgressIndicator()
            : categoryPostsAsRow(size, api);
        break;
      case "Series":
        api = "wp-json/wp/v2/posts?_embed&categories=194&per_page=100";
        return isLoading
            ? CircularProgressIndicator()
            : categoryPostsAsRow(size, api);
        break;
      case "K Saraswathi Amma":
        api = "wp-json/wp/v2/posts?_embed&categories=13&per_page=100";
        return isLoading
            ? CircularProgressIndicator()
            : categoryPostsAsRow(size, api);
        break;
      default:
        api = "wp-json/wp/v2/posts?_embed";
        return isLoading
            ? CircularProgressIndicator()
            : categoryPostsAsRow(size, api);
        break;
    }
  }

  Row categoryPostsAsRow(var size, var api) {
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
                    height: 450, // card height
                    child: PageView.builder(
                      allowImplicitScrolling: true,
                      physics: BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data.length,
                      controller:
                          PageController(viewportFraction: 0.7, initialPage: 0),
                      onPageChanged: (int index) =>
                          setState(() => _index = index),
                      itemBuilder: (BuildContext context, int index) {
                        Map wpPost = snapshot.data[index];
                        var imageUrl;
                        String title = wpPost['title']['rendered'];
                        var unescape = new HtmlUnescape();
                        var convertedTitle = unescape.convert(title);
                        if (snapshot.data[index]["_embedded"]
                                ["wp:featuredmedia"] !=
                            null) {
                          imageUrl = wpPost["_embedded"]["wp:featuredmedia"][0]
                              ["source_url"];
                        } else {
                          imageUrl = null;
                        }

                        String category =
                            wpPost['_embedded']['wp:term'][0][0]['name'];
                        var postId = wpPost['id'];
                        var author = wpPost['_embedded']['author'][0]['name'];
                        var content = wpPost['content']['rendered'];
                        return GestureDetector(
                          onTap: () {
                            postdata.postId = postId;
                            //print("postId ontap : "+postdata.postId.toString());
                            postdata.title = convertedTitle;
                            postdata.imageurl = imageUrl;
                            postdata.category = category;
                            postdata.content = content;
                            postdata.author = author;
                            Navigator.of(context).push(_createRoute());
                          },
                          onLongPress: () {
                            databaseReference
                                .child(uid)
                                .child("starred")
                                .child("" + postId.toString())
                                .set({
                              'author': author.toString(),
                              'category': category.toString(),
                              'content': content.toString(),
                              'imageurl': imageUrl.toString(),
                              'postid': postId.toString(),
                              'title': convertedTitle.toString(),
                            });
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Added to Starred."),duration: const Duration(seconds: 1),));

                            print("title : " +
                                convertedTitle +
                                "Post ID " +
                                postId.toString());
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
                                          child: returnImage(imageUrl),
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

  void launchURL(String url) async {
    print("Trying");
    if (await canLaunch(url)) {
      await launch(url,
          forceWebView: true, enableJavaScript: true, forceSafariVC: true);
    } else {
      throw 'Could not launch $url';
    }
  }
}

returnImage(imageUrl) {
  if(imageUrl == null) {
    return Image.asset(
      'assets/images/app_logo.jpg',
      height: 100,
      width: 100,
    );
  }
  else{
    return Image.network(
      imageUrl,
      errorBuilder: (BuildContext context,
          Object exception,
          StackTrace stackTrace) {
        return Text('');
      },
    );
  }
}
