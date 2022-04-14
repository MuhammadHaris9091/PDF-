import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pdf_reader/dashBoard.dart';
import 'package:slider_button/slider_button.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  final controller=PageController(initialPage: 0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/b1.png'), fit: BoxFit.fill)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 28.0),
                child:
                 SliderButton(
                   backgroundColor: Colors.transparent,
                  buttonColor: Colors.transparent,
                  action: () {
                    ///Do something here
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>DashBoard()));
                  },
                  label: Text(
                    "Slide to start ",
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontFamily: "Times New Roman",
                        color: Color(0xff4a4a4a),
                        fontWeight: FontWeight.w500,
                        fontSize: 17),
                  ),

                  icon: Center(
                      child: Icon(
                        Icons.arrow_forward,
                        color: Colors.black,
                        size: 40.0,
                        semanticLabel: 'Text to announce in accessibility modes',
                      )),

                  boxShadow: BoxShadow(
                    color: Colors.redAccent,
                    blurRadius: 2,
                  ),
                ),
              ),

            )
          ],
        ),
      ),
    );
  }
}
