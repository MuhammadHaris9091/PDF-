import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:pdf_reader/splachScreen.dart';
import 'package:splash_screen_view/SplashScreenView.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreenView(
        navigateRoute: SplashScreen(),
        duration: 5500,
        imageSize: 130,
        text: "Welcome To\nPDF\nText Extractor\n&\nTranslator",
        textType: TextType.TyperAnimatedText,
        textStyle: TextStyle(
          fontFamily: "Times New Roman",
          fontSize: 30.0,
          color: Colors.white,
        ),
        imageSrc: "images/appicon.png",
        backgroundColor: HexColor('#CB0000'),
      )
    );
  }
}


