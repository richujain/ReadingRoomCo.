import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reading_room_co/authentication_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_wordpress/flutter_wordpress.dart' as wp;
import 'package:http/http.dart' as http;
import 'package:reading_room_co/history.dart';
import 'package:reading_room_co/postdata.dart';
import 'package:reading_room_co/submissiondata.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:reading_room_co/starred.dart';
import 'package:reading_room_co/viewpost.dart';
import 'GoogleAuthClient.dart';
import 'wp-api.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'postdata.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart' as signIn;


class Submission extends StatefulWidget {
  Submission({Key key}) : super(key: key);
  @override
  _SubmissionState createState() => _SubmissionState();
}

class _SubmissionState extends State<Submission> {
  String apiKey = "AIzaSyB3FpKTDc5T8_T_x_aX0VqlBBK1JUHnRYY";
  SubmissionData submissionData = new SubmissionData();
  static const url = "https://docs.google.com/forms/d/e/1FAIpQLSfkOLT1DIbPY1h8psNZvcp9qmoAoidh6LOdUNbW59WXwzJiEQ/viewform";
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              Container(
                padding: EdgeInsets.all(12),
                child: Stack(
                  children: <Widget>[

                    Column(
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(15.0, 15.0, 0.0, 15.0),
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




                        Text(
                          "Looking to contribute? Reading Room Co. encourages submissions from writers, aspiring writers, academics, journalists, activists"
                              " and students. We consider original, previously unpublished fiction, essays, reviews and poetry for publication.\n\nTo "
                              "ease the contributors through our submission process, we have put together some basic guidelines:\n\n1. The "
                              "medium of expression should be English.\n\n2. The length of the essay/review should ideally be between 800-1200 words. "
                              "We are happy to consider longer essays if the topic demands it.\n\n3. Photo essays of not more than 800 words are also "
                              "welcome. 4-8 images that belong to the author can be featured in the essay.\n\n4.  We neither prescribe guidelines nor limit words "
                              "for fiction. The submissions can be experimental and as creative as the authors want them to be.\n\n5. Along with your"
                              "submission kindly send in a short biographical note and your headshot.\n\n6. Once we receive your submission, our review panel "
                              "will look into it and get back to you within 14-21 days.\n",
                          style: GoogleFonts.getFont(
                            "Roboto",
                            textStyle: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                              height: 2,
                            ),
                          ),
                        ),
                        MaterialButton(
                          padding: EdgeInsets.all(8.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.white)
                          ),
                          elevation: 0,
                          minWidth: double.maxFinite,
                          height: 50,
                          onPressed: ()  {
                            launchURL(url);
                          },
                          color: Colors.blue,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('Click Here to Open Submission Form',
                                  style: TextStyle(color: Colors.white, fontSize: 16)),
                            ],
                          ),
                          textColor: Colors.white,
                        ),







                      ],
                    )




                    // Form(
                    //   key: _formKey,
                    //   child: ListView(
                    //     children: <Widget>[
                    //       Column(), // we will work in here
                    //     ],
                    //   ),
                    // ),
                    //









                  ],
                ),
              ),

            ],
          ),
        ),
      ),
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
