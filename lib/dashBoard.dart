import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:pdf_reader/languageTranslator.dart';
import 'package:pdf_reader/pdfPageReader.dart';
import 'package:pdf_reader/speechToText.dart';


class DashBoard extends StatefulWidget {
  const DashBoard({Key key}) : super(key: key);

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {


  AppUpdateInfo _updateInfo;
  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        _updateInfo = info;
        print(_updateInfo);
      });
      if (_updateInfo.updateAvailability ==
          UpdateAvailability.updateAvailable) {
        InAppUpdate.performImmediateUpdate();
      }
    }).catchError((e) {
      return null;
    });
  }
  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to exit an App'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('No'),
          ),
          TextButton(
            onPressed: () => exit(0),
            child: new Text('Yes'),
          ),
        ],
      ),
    )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: Stack(
          children: [
            Positioned(
              top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: Image.asset('images/b1.png',fit: BoxFit.fill,)),
            Positioned(
                top: size.width * 0.15,
                left: size.width * 0.03,
                child: Text(
                  'Welcome To\n PDF Voice Reader',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: "Times New Roman",
                      fontWeight: FontWeight.w700,
                      fontSize: size.width * 0.06),
                )),
            Positioned(
                top: size.width * 0.5,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          child: container(AssetImage('images/microphone.png'),
                              ' PDF Voice Reader'),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PdfReaderPage()));
                          },
                        ),
                        Container(
                          width: 2,
                          height: size.width*0.35,
                          color: Colors.white,),
                        InkWell(
                            child: container(AssetImage('images/translator.png'),
                                'Language Translator'),
                        onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>VoicePDFTranslator()));},)
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: size.width*0.38,
                            height: 2,
                            color: Colors.white,),
                          Container(
                            width: size.width*0.38,
                            height: 2,
                            color: Colors.white,)
                      ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                            child: container(AssetImage('images/text-to-speech.png'),
                                'Speech To Text'),
                          onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>VoiceMessage()));},

                        ),
                        // Container(
                        //   width: 2,
                        //   height: size.width*0.35,
                        //   color: Colors.white,),
                        // InkWell(
                        //     child: container(AssetImage('images/apps.png'),
                        //         'Voice App Navigator'),
                        //   onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>AppNavigation()));},
                        // )
                      ],
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }

  Widget container(image, text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: MediaQuery.of(context).size.width * 0.42,
        width: MediaQuery.of(context).size.width * 0.4,
        decoration: BoxDecoration(
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: MediaQuery.of(context).size.width * 0.25,
                width: MediaQuery.of(context).size.width * 0.25,
                decoration: BoxDecoration(
                    image: DecorationImage(image: image, fit: BoxFit.fill),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top:8.0),
              child: Text(
                text,
                style: TextStyle(fontFamily: "Times New Roman",color: Colors.white,fontWeight: FontWeight.w500),
              ),
            )
          ],
        ),
      ),
    );
  }
}
 class BluePainter extends CustomPainter{

  @override
   void paint (Canvas canvas,Size size){
    final height=size.height;
    final width=size.width;
    Paint paint=Paint();
    Path mainBackground=Path();
    mainBackground.addRect(Rect.fromLTRB(0, 0, width, height));
    paint.color=
    HexColor('#CB0000');
    canvas.drawPath(mainBackground, paint);
    Path ovalPath=Path();
    ovalPath.moveTo(0, height*0.3);
    ovalPath.quadraticBezierTo(width*0.45, height*0.25, width*0.5, height*0.5);
    ovalPath.quadraticBezierTo(width*0.5, height*0.8, width, height);
    ovalPath.lineTo(0, height);
    ovalPath.close();
    paint.color=
        HexColor('#CB0000');
    canvas.drawPath(ovalPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate!=this;
  }

 }