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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: isLoading ? CircularProgressIndicator() : Stack(
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
                    validator: (value) {
                      if (value.isEmpty) return "This form value must be filled";
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.always,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
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
                    validator: (value) {
                      if (value.isEmpty) return "This form value must be filled";
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.always,
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  Container(
                    alignment: Alignment(1.0,0.0),
                    padding: EdgeInsets.only(top: 15.0, left: 20.0),
                    child: InkWell(
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
                  Container(
                    height: 50.0,
                    child: Material(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.green,
                      elevation: 7.0,
                      child: GestureDetector(
                        onTap: (){
                          setState(() {
                            isLoading = true;
                          });
                          context.read<AuthenticationService>().signIn(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                          ).whenComplete(() {
                            setState(() {
                              isLoading = false;
                              Navigator.of(context).popAndPushNamed('/home');
                            });
                          });
                        },

                        child: Center(
                          child: Text(
                            'Login',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Montserrat'
                            ),
                          ),
                        ),
                      ),
                    ),
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

  Future<String> signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    if (googleSignInAccount == null) {
      // cancelled login
      print('Google Signin ERROR! googleUser: null!');
      return null;
    }
    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential userCredential = await firebaseAuth.signInWithCredential(credential);
    final User user = userCredential.user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final User currentUser = await firebaseAuth.currentUser;
    assert(user.uid == currentUser.uid);

    return 'signInWithGoogle succeeded: $user';
  }

  void signOutGoogle() async{
    FirebaseAuth.instance.signOut();
    await googleSignIn.signOut();
    print("User Sign Out");
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
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: isLoading? CircularProgressIndicator() : Stack(
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
                      validator: (value) {
                        if (value.isEmpty) return "This form value must be filled";
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.always,
                    ),
                    SizedBox(height: 20),
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
                      validator: (value) {
                        if (value.isEmpty) return "This form value must be filled";
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.always,
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
                    Container(
                      height: 50.0,
                      child: Material(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Colors.green,
                        elevation: 7.0,
                        child: GestureDetector(
                          onTap: (){

                            _createUser(context);

                          },

                          child: Center(
                            child: Text(
                              'Register',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat'
                              ),
                            ),
                          ),
                        ),
                      ),
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
      ).whenComplete(() async {
        User currentUser = firebaseAuth.currentUser;
        await currentUser.reload().whenComplete(() {
          currentUser.updateProfile(displayName: displayName);
          setState(() {
            isLoading = false;
          });
          currentUser == null ? print("null login") :
          context.read<AuthenticationService>().signOut();
          Navigator.of(context).pop();
        });

      });

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        setState(() {
          isLoading = false;
        });
        print('The password provided is too weak.');
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("The password provided is too weak"),
          duration: const Duration(seconds: 1),
        ));
      } else if (e.code == 'email-already-in-use') {
        setState(() {
          isLoading = false;
        });
        print('The account already exists for that email.');
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("The account already exists for that email."),
          duration: const Duration(seconds: 1),
        ));
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }

  }
}