import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:reading_room_co/submissiondata.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';




class Submission extends StatefulWidget {
  Submission({Key key}) : super(key: key);
  @override
  _SubmissionState createState() => _SubmissionState();
}

class _SubmissionState extends State<Submission> {
  String apiKey = "AIzaSyB3FpKTDc5T8_T_x_aX0VqlBBK1JUHnRYY";
  SubmissionData submissionData = new SubmissionData();
  String genre;
  String emailForPath;

  File headShot, document;
  final picker = ImagePicker();
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final titleController = TextEditingController();
  final genreController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String datetime = DateTime.now().toString();
  String name,description,title;
  String headShotdownloadUrl;
  String documentDownloadUrl;
  bool checkTermsAndConditions = false;

  @override
  Widget build(BuildContext context) {
    if (_firebaseAuth.currentUser.displayName != null) {
      emailForPath = _firebaseAuth.currentUser.email;
    }
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
                                  'assets/images/logo.png',
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
                        Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                        SizedBox(height: 10,),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              _showPicker(context);
                            },
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: Color(0xffFDCF09),
                              child: headShot != null
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.file(
                                  headShot,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.fitHeight,
                                ),
                              )
                                  : Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(50)),
                                width: 100,
                                height: 100,
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                          ),
                        ),
                        TextFormField(
                          onSaved: (val) => submissionData.email = val,
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            icon: Icon(Icons.account_circle),
                          ),
                          controller: emailController,
                        ),

                        TextFormField(
                          onSaved: (val) => submissionData.name = val,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            icon: Icon(Icons.contacts),
                          ),
                          controller: nameController,
                          keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.sentences,
                          validator: (value) {
                            if (value.isEmpty) return "This form value must be filled";
                            return null;
                          },
                        ),

                        TextFormField(
                          onSaved: (val) => submissionData.email = val,
                          decoration: InputDecoration(
                            labelText: 'Your Short Bio',
                            icon: Icon(Icons.description),
                          ),
                          controller: descriptionController,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          validator: (value) {
                            if (value.isEmpty) return "This form value must be filled";
                            return null;
                          },
                        ),
                        TextFormField(
                          onSaved: (val) => submissionData.email = val,
                          decoration: InputDecoration(
                            labelText: 'Title',
                            icon: Icon(Icons.title),
                          ),
                          controller: titleController,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          validator: (value) {
                            if (value.isEmpty) return "This form value must be filled";
                            return null;
                          },
                        ),
                        DropdownButtonFormField<String>(
                          onSaved: (val) => submissionData.genre = val,
                          value: genre,
                          items: [
                            'Essay','Fiction','Interview','Poetry','Review','Memoir'
                          ].map<DropdownMenuItem<String>>(
                                (String val) {
                              return DropdownMenuItem(
                                child: Text(val),
                                value: val,
                              );
                            },
                          ).toList(),
                          onChanged: (val) {
                            setState(() {
                              genre = val;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Genre',
                            icon: Icon(Icons.category),
                          ),
                          validator: (value) {
                            if (value.isEmpty) return "This form value must be filled";
                            return null;
                          },
                        ),
                        SizedBox(height: 30,),
                        MaterialButton(
                          padding: EdgeInsets.all(8.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.white)),
                          elevation: 0,
                          minWidth: double.maxFinite,
                          height: 50,
                          onPressed: () async {

                            FilePickerResult result = await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['jpg', 'pdf', 'doc'],
                            );

                            if(result != null) {
                              document = File(result.files.single.path);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("File Attached."),duration: const Duration(seconds: 1),));
                            } else {
                              // User canceled the picker
                            }


                          },

                          color: Colors.green,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(FontAwesomeIcons.file),
                              SizedBox(width: 10,),
                              Text('Attach File',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16)),
                            ],
                          ),
                          textColor: Colors.white,
                        ),






                        SizedBox(height: 20),
                        Container(
                          alignment: Alignment(0.0,0.0),
                          padding: EdgeInsets.only(top: 15.0, left: 20.0),
                          child: InkWell(
                            onTap: (){
                              showAlertDialog(context);
                              // AlertDialog(
                              //   title: Text('Very, very large title', textScaleFactor: 5),
                              //   content: Text('Very, very large content', textScaleFactor: 5),
                              //   actions: <Widget>[
                              //     TextButton(child: Text('Button 1'), onPressed: () {}),
                              //     TextButton(child: Text('Button 2'), onPressed: () {}),
                              //   ],
                              // );
                            },
                            child: Text('Terms and conditions',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Montserrat',
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),





                        SizedBox(height: 30,),

                        MaterialButton(
                          padding: EdgeInsets.all(8.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.white)
                          ),
                          elevation: 0,
                          minWidth: double.maxFinite,
                          height: 50,
                          onPressed: () async {
                            emailForPath = emailController.text;
                            name = nameController.text;
                            description = descriptionController.text;
                            title = titleController.text;

                            if(checkTermsAndConditions == false){
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Agree to the Terms and conditions before submitting."),duration: const Duration(seconds: 3),));
                            }
                            else if(emailForPath.isEmpty || name.isEmpty || description.isEmpty || title.isEmpty || genre.isEmpty){
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Fill all the fields before submitting."),duration: const Duration(seconds: 3),));
                            }
                            else if(headShot == null && document == null){
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload your headshot and document."),duration: const Duration(seconds: 3),));
                            }
                            else{
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Uploading almost done..."),duration: const Duration(seconds: 3),));
                              final FirebaseAuth auth = FirebaseAuth.instance;
                              final User user = auth.currentUser;
                              final uid = user.uid;


                              final myFuture = uploadToFirebaseStorage(uid,emailForPath,name,description,title,datetime,genre);
                              myFuture.then((value) => (downloadUrl){
                                print("inside then"+downloadUrl[0] + "::::" + downloadUrl[1]);
                              });
                            }



                          },
                          color: Colors.blue,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('Submit',
                                  style: TextStyle(color: Colors.white, fontSize: 16)),
                            ],
                          ),
                          textColor: Colors.white,
                        ),







                      ],
                    )




                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("I Agree"),
      onPressed: () {
        checkTermsAndConditions = true;
        Navigator.of(context).pop();

      },
    );
    Widget continueButton = FlatButton(
      child: Text("Close"),
      onPressed:  () {
        Navigator.of(context).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Terms and Conditions"),
      content: SingleChildScrollView(
        child: Text("I hereby agree that:\n\n 1. The articles /materials which are offered for publishing by the author to the publisher shall be editor compared by the editor "
            "of the firm to adhere to appropriate publishing norms followed by the industry and will be subjected to rules government regulation.\n\n"
          "2. Any articles / materials may be returned to the author unpublished being rejected by the editor of the firm for any reason and the firm has absolute right to do so.\n\n"
          "3. The author shall give a written authorisation to the publisher to publish articles/ materials in the company website and shall not claim or make any demands for copyright benefits from the publisher.\n\n"
          "4. Reading Room Co. reserves all rights to convert the matter or materials either fully or partially to PDF or PUB for kindle application simultaneously while publishing or at any future period as and when the company may think deem fit.\n\n"
          "5. Reading Room Co. reserves all rights for any commercial value accrued to the Article / material published by any author on its website, while shall be only entitled to the publisher. The author will not get any payments/monetary benefits from the publisher.\n\n"
         "6. Any advertisements or campaign run and promoted by the company either at the beginning or in between or after the article/material which published, is at the sole discretion of the publisher and the author has no right to demand any explanation for the same.\n\n"
          "7. The name of the author shall be published along with the article/ materials given for publication. However the editor reserves all rights to change the original name of the author to pen name or use any pseudonym or hide the name accordingly at appropriate situation.\n\n"
          "8. Reading Room Co. will not be responsible to any author for any comments made by any readers/ viewers of the website and shall be liable to pay any compensation to the author if any viewer/ readers for any legal action taken against the author  of the article/ materials.\n"        "9. In the events of the transfer of ownership of  Reading Room Co. to any other Company or person / business house any policy change shall not affect the present ownership and the present owners do not own any responsibility and liability towards the authors who have authorised to publish their articles.\n\n"
          "10. Reading Room Company reserves all rights to change / amend any clause in this agreement in the best interest of the company.\n"),
      ),

      actions: [
        okButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _imgFromCamera() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50
    );

    setState(() {
      headShot = image;
    });
  }

  _imgFromGallery() async {
    File image = await  ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50
    );

    setState(() {
      headShot = image;
    });
  }
  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        }
    );
  }
   uploadToFirebaseStorage(uid,emailForPath,name,description,title,datetime,genre) async{

    final _firebaseStorage = FirebaseStorage.instance;
    var file = File(headShot.path);
    if (headShot != null){
      //Upload to Firebase
      var snapshot = await _firebaseStorage.ref()
          .child(emailForPath+"/"+datetime+"/image")
          .putFile(file);
      // headShotdownloadUrl = await snapshot.ref.getDownloadURL();


      var fileDocument = File(document.path);
      if (document != null){
        //Upload to Firebase
        var snapshot = await _firebaseStorage.ref()
            .child(emailForPath+"/"+datetime+"/document")
            .putFile(fileDocument);
        // documentDownloadUrl = await snapshot.ref.getDownloadURL();

        final databaseReference = FirebaseDatabase.instance.reference();
        databaseReference.child(uid).child("submission").push().set({
          'email' : emailForPath,
          'name' : name,
          'description' : description,
          'title' : title,
          'datetime' : datetime,
          'genre' : genre,
          'headshotdownloadurl' : headShotdownloadUrl,
          'documentdownloadurl' : documentDownloadUrl,
        }).then((value) => Navigator.pop(context));



      } else {
        print('No Document Path Received');
      }

    } else {
      print('No Image Path Received');
    }
  }



  }
