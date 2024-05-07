import 'package:stream_mate/firebase_options.dart';
import 'package:stream_mate/screens/home_screen.dart';
import 'package:stream_mate/screens/login_screen.dart';
import 'package:stream_mate/screens/enter_details_screen.dart';
import 'package:stream_mate/screens/splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stream Mate',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            brightness: Brightness.dark, seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const DecidePage(),
    );
  }
}

class DecidePage extends ConsumerWidget {
  const DecidePage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.metadata.creationTime ==
              snapshot.data!.metadata.lastSignInTime) {
            return const UserDetails();
          }
          return FutureBuilder(
            future:
                FirebaseFirestore.instance.collection(snapshot.data!.uid).get(),
            builder: (context, snap) {
              if (snap.hasData) {
                if (snap.data!.docs.isEmpty) {
                  return const UserDetails();
                } else {
                  return const HomeScreen();
                }
              }
              return const SplashScreen();
            },
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoginScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
