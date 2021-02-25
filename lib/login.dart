import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reading_room_co/authentication_service.dart';
import 'package:reading_room_co/home.dart';
import 'package:provider/provider.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/home': (context) => HomePage(),
      },
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(),
        child: isLoading? new Container(
          width: MediaQuery.of(context).size.width,//70.0,
          height: MediaQuery.of(context).size.height, //70.0,
          child: new Padding(
              padding: const EdgeInsets.all(5.0),
              child: new Center(child: new CircularProgressIndicator())),
        ): Column(
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
                          'assets/images/app_logo.jpg',
                          height: 100,
                          width: 100,
                        ),
                      )
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(0.0, 215.0, 30.0, 0.0),
                    child: Center(
                        child: Text(
                          'Reading Room Co',
                          style: GoogleFonts.yellowtail(
                            textStyle: TextStyle(color: Colors.black, fontSize: 50,fontWeight: FontWeight.bold),
                          ),
                        )
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(345.0, 195.0, 0.0, 0.0),
                    child: Text(
                      '.',
                      style: TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 50.0,left: 20.0, right: 20.0),
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                        labelText: 'Email',
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
                    controller: passwordController,
                    decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.green)
                        )
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  Container(
                    alignment: Alignment(1.0,0.0),
                    padding: EdgeInsets.only(top: 15.0, left: 20.0),
                    child: InkWell(
                      onTap: (){
                        if(emailController.text.trim().isEmpty){
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter your Email Address."),duration: const Duration(seconds: 1),));
                        }
                        else{
                          resetPassword(emailController.text.trim());
                        }
                      },
                      child: Text('Forgot Password',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.white)
                    ),
                    elevation: 0,
                    minWidth: double.maxFinite,
                    height: 50,
                    onPressed: () {
                        _login(context);
                    },
                    color: Colors.green,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(width: 10),
                        Text('Login',
                            style: TextStyle(color: Colors.white, fontSize: 16)),
                      ],
                    ),
                    textColor: Colors.white,
                  ),


                  SizedBox(height: 30.0),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.white)
                    ),
                    elevation: 0,
                    minWidth: double.maxFinite,
                    height: 50,
                    onPressed: () {
                      signInWithGoogle().whenComplete(() {
                        User currentUser = firebaseAuth.currentUser;
                        print("current user"+currentUser.toString());
                        currentUser == null ? print("null login") :
                        Navigator.of(context).popAndPushNamed('/home');
                      });
                    },
                    color: Colors.blue,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(FontAwesomeIcons.google),
                        SizedBox(width: 10),
                        Text('Sign-in using Google',
                            style: TextStyle(color: Colors.white, fontSize: 16)),
                      ],
                    ),
                    textColor: Colors.white,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            Container(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'New to ReadingRoomCo.?',
                    style: TextStyle(
                        fontFamily: 'Montserrat'
                    ),
                  ),
                  SizedBox(width: 5.0),
                  InkWell(
                    onTap: (){
                      //Navigator.popAndPushNamed(context, '/register');
                      Route route = MaterialPageRoute(builder: (context) => RegisterPage());
                      Navigator.push(context, route);
                    },
                    child: Text(
                      'Register',
                      style: TextStyle(
                        color: Colors.green,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
      ),
    );
  }
  @override
  Future<void> resetPassword(String email) async {
    await firebaseAuth.sendPasswordResetEmail(email: email).whenComplete(() {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Password reset link send to $email"),duration: const Duration(seconds: 1),));
    });
  }
  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create a new credential
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  void signOutGoogle() async{
    FirebaseAuth.instance.signOut();
    await googleSignIn.signOut();
    print("User Sign Out");
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void _login(context) async{
    if(emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter your credentials."),duration: const Duration(seconds: 1),));
    }
    else{
      setState(() {
        isLoading = true;
      });
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          print('No user found for that email.');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No user found for that email."),duration: const Duration(seconds: 1),));
        } else if (e.code == 'wrong-password') {
          print('Wrong password provided for that user.');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Wrong password provided for that user."),duration: const Duration(seconds: 1),));
          Navigator.of(context).pushReplacementNamed('/');
        }
      }
    }

  }
}
class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController displayNameController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    displayNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(),
          child: isLoading? new Container(
            width: MediaQuery.of(context).size.width,//70.0,
            height: MediaQuery.of(context).size.height, //70.0,
            child: new Padding(
                padding: const EdgeInsets.all(5.0),
                child: new Center(child: new CircularProgressIndicator())),
          ): Column(
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
                              'assets/images/app_logo.jpg',
                              height: 100,
                              width: 100,
                            ),
                          )
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(0.0, 215.0, 30.0, 0.0),
                      child: Center(
                          child: Text(
                            'Reading Room Co',
                            style: GoogleFonts.yellowtail(
                              textStyle: TextStyle(color: Colors.black, fontSize: 50,fontWeight: FontWeight.bold),
                            ),
                          )
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(345.0, 195.0, 0.0, 0.0),
                      child: Text(
                        '.',
                        style: TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 50.0,left: 20.0, right: 20.0),
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: displayNameController,
                      decoration: InputDecoration(
                          labelText: 'Display Name',
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
                      controller: emailController,
                      decoration: InputDecoration(
                          labelText: 'Email',
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
                      controller: passwordController,
                      decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.green)
                          )
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 40),
                    MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.white)
                      ),
                      elevation: 0,
                      minWidth: double.maxFinite,
                      height: 50,
                      onPressed: () {
                        _createUser(context);
                      },
                      color: Colors.green,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(width: 10),
                          Text('Register',
                              style: TextStyle(color: Colors.white, fontSize: 16)),
                        ],
                      ),
                      textColor: Colors.white,
                    ),
                    SizedBox(height: 30.0),
                  ],
                ),
              ),
              SizedBox(height: 20.0),
              Container(
                padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already Registered?',
                      style: TextStyle(
                          fontFamily: 'Montserrat'
                      ),
                    ),
                    SizedBox(width: 5.0),
                    InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.green,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _createUser(context) async{
    if(emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty || displayNameController.text.trim().isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("All fields must be filled."),duration: const Duration(seconds: 1),));
    }
    else{
      setState(() {
        isLoading = true;
      });
      String displayName = displayNameController.text.trim();
      String email = emailController.text.trim();
      String password = passwordController.text.trim();
      FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      try {
        await firebaseAuth.createUserWithEmailAndPassword(
          email: email.toString(),
          password: password.toString(),
        ).then((firebaseUser) async {
          await FirebaseAuth.instance.currentUser.updateProfile(
                    displayName: displayName
          ).then((value) async{
            setState(() {
              isLoading = false;
            });
            //I don't know if the next statement is necessary
            firebaseAuth.signOut().whenComplete(() {
              Navigator.of(context).pop();
            });
          });


        });



        //
        // whenComplete(() async {
        //   if(FirebaseAuth.instance.currentUser.email != null){
        //     await FirebaseAuth.instance.currentUser.updateProfile(
        //         displayName: displayName
        //     );
        //     setState(() {
        //       isLoading = false;
        //     });
        //     context.read<AuthenticationService>().signOut();
        //     Navigator.of(context).pop();
        //   }


        // });

      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          setState(() {
            isLoading = false;
          });
          print('The password provided is too weak.');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("The password provided is too weak."),duration: const Duration(seconds: 1),));
        } else if (e.code == 'email-already-in-use') {
          setState(() {
            isLoading = false;
          });
          print('The account already exists for that email.');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("The account already exists for that email."),duration: const Duration(seconds: 1),));

        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print(e);
      }
    }

  }
}