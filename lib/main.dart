import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:reading_room_co/home.dart';
import 'package:reading_room_co/login.dart';
import 'authentication_service.dart';
import 'package:provider/provider.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}



class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(
          create: (_) => AuthenticationService(FirebaseAuth.instance),
        ),
        StreamProvider(
          create: (context) => context.read<AuthenticationService>().authStateChanges,
        )
      ],
      child: MaterialApp(
        title: 'Reading Room Co.',
        theme: ThemeData.light(),
        home: AuthenticationWrapper(),
        routes: <String, WidgetBuilder>{
          '/home' : (BuildContext context) => new HomePage(),
         // '/login' : (BuildContext context) => new LoginPage(),
         },
      ),

    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();

    if (firebaseUser != null) {
      //Navigator.pushNamedAndRemoveUntil(context, '/home', (Route<dynamic> route) => false);
      return HomePage();
    }
    //Navigator.popAndPushNamed(context, '/login');
    return LoginPage();
  }
}