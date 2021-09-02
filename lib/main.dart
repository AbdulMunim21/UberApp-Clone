import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:uberapp_clone/Data/appData.dart';
import 'package:uberapp_clone/screens/homescreen.dart';
import 'package:uberapp_clone/screens/login_screen.dart';
import 'package:uberapp_clone/screens/registrationScreen.dart';
import 'package:uberapp_clone/screens/search_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

final auth = FirebaseAuth.instance;
final riderRef = FirebaseFirestore.instance.collection('rider');

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        return ChangeNotifierProvider(
          create: (ctx) => AppData(),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'UberApp Clone',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: snapshot.connectionState == ConnectionState.waiting
                ? Scaffold(
                    body: Center(
                      child: Lottie.network(
                          "https://assets7.lottiefiles.com/private_files/lf30_us6Qcj.json"),
                    ),
                  )
                : StreamBuilder(
                    stream: auth.authStateChanges(),
                    builder: (ctx, snapshot) {
                      if (snapshot.hasData) {
                        return HomeScreen();
                      } else {
                        return LoginScreen();
                      }
                    },
                  ),
            routes: {
              RegistrationScreen.routeName: (ctx) => RegistrationScreen(),
              LoginScreen.routeName: (ctx) => LoginScreen(),
              HomeScreen.routeName: (ctx) => HomeScreen(),
              SearchScreen.routeName: (ctx) => SearchScreen(),
            },
          ),
        );
      },
    );
  }
}
