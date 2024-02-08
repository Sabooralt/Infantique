import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infantique/models/cart_provider.dart';
import 'package:infantique/screens/home_screen.dart';
import 'package:infantique/screens/login_screen.dart';
import 'package:infantique/screens/splash_screen.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    EasyLoading.init();

    return MultiProvider(
        providers: [
        ChangeNotifierProvider<CartProvider>(
        create: (context) => CartProvider(),
    ),

    ],
    child: MaterialApp(

      navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Infantique',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            textTheme: GoogleFonts.mulishTextTheme(),
          ),
          home: const spscreen(),
          builder: EasyLoading.init(),
        )
    );
  }

}
class Authentication extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(

        stream: _auth.authStateChanges(),

        builder: (context,snapshot){
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data;

            return user == null ? const loginscreen() : const HomeScreen();
          }
          return  const spscreen();
        }
    );
  }
}
