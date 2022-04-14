import 'dart:io';
import 'package:clipboard/clipboard.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart'
    as viewer;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pdf_text/pdf_text.dart';
import 'package:share/share.dart';
import 'package:translator/translator.dart';

class VoicePDFTranslator extends StatefulWidget {
  const VoicePDFTranslator({Key key}) : super(key: key);

  @override
  _VoicePDFTranslatorState createState() => _VoicePDFTranslatorState();
}

bool _isLoading = true;
File result;
viewer.PDFDocument doc;

class _VoicePDFTranslatorState extends State<VoicePDFTranslator> {

  void extractFile() async {
    result = await FilePicker.getFile(
      allowedExtensions: ['pdf', 'doc'],
      type: FileType.custom,
    );
    setState(() {
      _isLoading = true;
      //paths=result.path;
    });
    doc = await viewer.PDFDocument.fromFile(result);
    setState(() {
      _isLoading = false;
    });
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => FileViewer2(
              doc: doc,
              result: result,
            )));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('images/b1.png'), fit: BoxFit.fill)),
          child: Stack(
            children: [
              Positioned(
                  top: MediaQuery.of(context).size.width * 0.15,
                  left: MediaQuery.of(context).size.width * 0.03,
                  child: Center(
                      child: Text(
                    'PDF Language Converter\n&\nVoice Reader',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Times New Roman",
                        fontWeight: FontWeight.w700,
                        fontSize: MediaQuery.of(context).size.width * 0.05),
                  ))),
              Center(
                child: TextButton(
                  onPressed: () {
                    extractFile();
                  },
                  child: Text(
                    'Choose File',
                    style: TextStyle(
                        fontFamily: 'Times New Roman',
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.05),
                  ),
                  style: ButtonStyle(
                    shadowColor: MaterialStateProperty.all<Color>(Colors.lime),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.redAccent),
                    elevation: MaterialStateProperty.all(10),
                    minimumSize: MaterialStateProperty.all<Size>(Size(60, 65)),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}

///.........................//////////////////////////////////////////////////////////////////////////////////// new class
class FileViewer2 extends StatefulWidget {
  final doc;
  final result;
  const FileViewer2({this.doc, this.result, Key key}) : super(key: key);

  @override
  _FileViewer2State createState() =>
      _FileViewer2State(doc: doc, result: result);
}



class _FileViewer2State extends State<FileViewer2> {
  final doc;
  final result;
  _FileViewer2State({this.doc, this.result});
  String fromLanguage = 'English';
  String toLanguage = 'French';
  String countryCodeTo = 'fr';
  String countryCodeFrom = 'en';
  PDFDoc pdfDoc;
  PDFPage _page;
  int pageNum;
  String docText;
  final translator = GoogleTranslator();
  String translatedText;
  bool position = false;
  bool loadingContainer = false;
  TextEditingController _textEditingController = TextEditingController();

  void pickPage() async {
    setState(() {
      loadingContainer = true;
    });
    var connectivityResult = await (Connectivity().checkConnectivity());
    pdfDoc = await PDFDoc.fromFile(result);
    int length=pdfDoc.length;
    if (connectivityResult!=ConnectivityResult.none && _textEditingController.text.isNotEmpty && int.parse(_textEditingController.text)<=length ) {
      setState(() {
        pageNum = int.parse(_textEditingController.text);
      });
      _page = pdfDoc.pageAt(pageNum);
      docText = await _page.text;
      _translateLanguage();
    }
    else if(_textEditingController.text.isEmpty){

      setState(() {
        loadingContainer = false;
      });
      Fluttertoast.showToast(msg: "Please Enter Page Number");
    }
    else if(int.parse(_textEditingController.text)>length){
      setState(() {
        loadingContainer = false;
      });
      Fluttertoast.showToast(msg: "Please Enter Valid Page Number");
    }
    else if(connectivityResult==ConnectivityResult.none){
      setState(() {
        loadingContainer = false;
      });
      showDialog(context: context, builder: (context)=>AlertDialog(
        title: new Text('Warning'),
        content: new Text('Please Check You Internet Connection'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('Ok'),
          ),
        ],
      ));
    }

  }

  _translateLanguage() async {
    await translator
        .translate(docText.toString(),
            to: '$countryCodeTo', from: '$countryCodeFrom')
        .then((result) {
          if (mounted){
            setState(() {
              translatedText = result.toString();
              loadingContainer = false;
            });
          }
    });
    _navigate();
  }

  _navigate() async {

    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ExtractPageText2(
                  text: translatedText,
                )));
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(

      resizeToAvoidBottomInset: false,
      body: loadingContainer
          ? Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('images/b1.png'), fit: BoxFit.fill)),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: SpinKitCubeGrid(
                color: Colors.white,
                size: 70.0,
                //controller: AnimationController(vsync: this, duration: const Duration(milliseconds: 1200)),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('images/b1.png'), fit: BoxFit.fill)),
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(children: [
                    Positioned(
                        top: MediaQuery.of(context).size.height * 0.03,
                        left: MediaQuery.of(context).size.width * 0.02,
                        child: Center(
                            child: Text(
                          'PDF Language Converter\n&\nVoice Reader',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: "Times New Roman",
                              fontWeight: FontWeight.w700,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.05),
                        ))),
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.12,
                      left: 5,
                      right: 5,
                      child: Container(
                          width: size.width,
                          height: size.height * 0.74,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(0),
                              border:
                                  Border.all(color: Colors.black, width: 1.5)),
                          child: _isLoading
                              ? Container(
                                  width: size.width,
                                  height: size.width * 1.5,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(0),
                                      border: Border.all(
                                          color: Colors.black, width: 1.5)),
                                )
                              : viewer.PDFViewer(
                                  document: doc,
                                )),
                    ),
                    Positioned(
                      bottom: 5,
                      left: 5,
                      right: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              position = true;
                            });
                          },
                          child: Text(
                            'Translate Page',
                            style: TextStyle(
                                fontFamily: 'Times New Roman',
                                color: Colors.black,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.05),
                          ),
                          style: ButtonStyle(
                            shadowColor:
                                MaterialStateProperty.all<Color>(Colors.lime),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            elevation: MaterialStateProperty.all(10),
                            minimumSize: MaterialStateProperty.all<Size>(
                                Size(size.width, size.height * 0.08)),
                          ),
                        ),
                      ),
                    ),
                    position
                        ? Positioned(
                            top: MediaQuery.of(context).size.height * 0.12,
                            left: 5,
                            right: 5,
                            bottom: 10,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                      color: Colors.black87, width: 1.5)),
                              child: Column(
                                children: [
                                  ///select language text...
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 18.0, left: 10.0),
                                        child: Text(
                                          "Select Languages",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.05,
                                              color: Colors.white,
                                              fontFamily: "Times New Roman"),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      height: size.width * 0.2,
                                      width: size.width,
                                      decoration: BoxDecoration(
                                          color: Colors.black87,
                                          border: Border.all(),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            'From',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: "Times New Roman"),
                                          ),
                                          DropdownButton(
                                              dropdownColor: Colors.black,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily:
                                                      "Times New Roman"),
                                              value: fromLanguage,
                                              items: [
                                                ///1french
                                                DropdownMenuItem(
                                                  child: Text(
                                                    "French",
                                                  ),
                                                  value: 'French',
                                                ),

                                                ///2english
                                                DropdownMenuItem(
                                                  child: Text("English"),
                                                  value: 'English',
                                                ),
                                                ///3urdu
                                                DropdownMenuItem(
                                                  child: Text("Urdu"),
                                                  value: 'Urdu',
                                                ),
                                                ///4Arabic
                                                DropdownMenuItem(
                                                  child: Text("Arabic"),
                                                  value: 'Arabic',
                                                ),
                                                ///5Hindi
                                                DropdownMenuItem(
                                                  child: Text("Hindi"),
                                                  value: 'Hindi',
                                                ),
                                                ///6German
                                                DropdownMenuItem(
                                                  child: Text("German"),
                                                  value: "German",
                                                ),
                                                ///7japanese
                                                DropdownMenuItem(
                                                  child: Text("Japanese"),
                                                  value: "Japanese",
                                                ),
                                                ///8Korean
                                                DropdownMenuItem(
                                                  child: Text("Korean"),
                                                  value: "Korean",
                                                ),
                                                ///9turkish
                                                DropdownMenuItem(
                                                  child: Text("Turkish"),
                                                  value: "Turkish",
                                                ),
                                                ///10Armenia//hy//am
                                                DropdownMenuItem(
                                                  child: Text("Armenia"),
                                                  value: "Armenia",
                                                ),
                                                ///11Bengali//bn
                                                DropdownMenuItem(
                                                  child: Text("Bengali"),
                                                  value: "Bengali",
                                                ),
                                                ///12Bulgarian//bg
                                                DropdownMenuItem(
                                                  child: Text("Bulgarian"),
                                                  value: "Bulgarian",
                                                ),
                                                ///13Dutch//nl
                                                DropdownMenuItem(
                                                  child: Text("Dutch"),
                                                  value: "Dutch",
                                                ),
                                                ///14Danish//da
                                                DropdownMenuItem(
                                                  child: Text("Danish"),
                                                  value: "Danish",
                                                ),
                                                ///15Spanish//es
                                                DropdownMenuItem(
                                                  child: Text("Spanish"),
                                                  value: "Spanish",
                                                ),
                                                ///16Swedish//sv
                                                DropdownMenuItem(
                                                  child: Text("Swedish"),
                                                  value: "Swedish",
                                                ),
                                                ///17Estonian
                                                DropdownMenuItem(
                                                  child: Text("Estonian"),
                                                  value: "Estonian",
                                                ),
                                                ///18Greek
                                                DropdownMenuItem(
                                                  child: Text("Greek"),
                                                  value: "Greek",
                                                ),
                                                ///19ungarian//hu
                                                DropdownMenuItem(
                                                  child: Text("Hungarian"),
                                                  value: "Hungarian",
                                                ),
                                                ///20Italian//it
                                                DropdownMenuItem(
                                                  child: Text("Italian"),
                                                  value: "Italian",
                                                ),
                                                ///21Latvian//lv
                                                DropdownMenuItem(
                                                  child: Text("Latvian"),
                                                  value: "Latvian",
                                                ),
                                                ///22Polish//pl
                                                DropdownMenuItem(
                                                  child: Text("Polish"),
                                                  value: "Polish",
                                                ),
                                                ///23Romanian//ro
                                                DropdownMenuItem(
                                                  child: Text("Romanian"),
                                                  value: "Romanian",
                                                ),
                                                ///24Russian//ru
                                                DropdownMenuItem(
                                                  child: Text("Russian"),
                                                  value: "Russian",
                                                ),
                                                ///25Thai
                                                DropdownMenuItem(
                                                  child: Text("Thai"),
                                                  value: "Thai",
                                                ),
                                                ///26Ukrainian//uk
                                                DropdownMenuItem(
                                                  child: Text("Ukrainian"),
                                                  value: "Ukrainian",
                                                ),


                                              ],
                                              onChanged: (value) {
                                                if (value == 'French') {
                                                  setState(() {
                                                    fromLanguage = value;
                                                    countryCodeFrom = 'fr';
                                                  });
                                                }
                                                else if (value == 'English') {
                                                  setState(() {
                                                    fromLanguage = value;
                                                    countryCodeFrom = 'en';
                                                  });
                                                }
                                                else if (value == 'Urdu') {
                                                  setState(() {
                                                    fromLanguage = value;
                                                    countryCodeFrom = 'ur';
                                                  });
                                                }
                                                else if (value == 'Arabic') {
                                                  setState(() {
                                                    fromLanguage = value;
                                                    countryCodeFrom = 'ar';
                                                  });
                                                }
                                                else if (value == 'Hindi') {
                                                  setState(() {
                                                    fromLanguage = value;
                                                    countryCodeFrom = 'hi';
                                                  });
                                                }
                                                else if (value == 'German') {
                                                  setState(() {
                                                    fromLanguage = value;
                                                    countryCodeFrom = 'de';
                                                  });
                                                }
                                                else if (value == 'Japanese') {
                                                  setState(() {
                                                    fromLanguage = value;
                                                    countryCodeFrom = 'ja';
                                                  });
                                                }
                                                else if (value == 'Korean') {
                                                  setState(() {
                                                    fromLanguage = value;
                                                    countryCodeFrom = 'ko';
                                                  });
                                                }
                                                else if (value == 'Turkish') {
                                                  setState(() {
                                                    fromLanguage = value;
                                                    countryCodeFrom = 'tr';
                                                  });
                                                }
                                                else if (value == 'Armenia') {
                                                  setState(() {
                                                    fromLanguage = value;
                                                    countryCodeFrom = 'hy';
                                                  });
                                                }
                                                else if (value == 'Bengali') {
                                                  setState(() {
                                                    fromLanguage = value;
                                                    countryCodeFrom = 'bn';
                                                  });
                                                }
                                                else if (value == 'Bulgarian') {
                                                  setState(() {
                                                    fromLanguage = value;
                                                    countryCodeFrom = 'bg';
                                                  });
                                                }
                                                else if (value == 'Danish') {
                                                  setState(() {
                                                    fromLanguage = value;
                                                    countryCodeFrom = 'da';
                                                  });
                                                }
                                                else if (value == 'Dutch') {
                                                  setState(() {
                                                    fromLanguage = value;
                                                    countryCodeFrom = 'nl';
                                                  });
                                                }
                                                else if (value == 'Spanish') {
                                                  setState(() {
                                                    fromLanguage = value;
                                                    countryCodeFrom = 'es';
                                                  });
                                                }
                                                else if (value == 'Swedish') {
                                                  setState(() {
                                                    fromLanguage = value;
                                                    countryCodeFrom = 'sv';
                                                  });
                                                }
                                                else if (value == 'Estonian') {
                                                  setState(() {
                                                    fromLanguage = value;
                                                    countryCodeFrom = 'et';
                                                  });
                                                }
                                                else if (value == 'Greek') {
                                                  setState(() {
                                                    fromLanguage = value;
                                                    countryCodeFrom = 'el';
                                                  });
                                                }
                                                else if (value == 'Hungarian') {
                                                  setState(() {
                                                    fromLanguage = value;
                                                    countryCodeFrom = 'hu';
                                                  });
                                                }
                                                else if (value == 'Italian') {
                                                  setState(() {
                                                    fromLanguage = value;
                                                    countryCodeFrom = 'it';
                                                  });
                                                }
                                                else if (value == 'Latvian') {
                                                  setState(() {
                                                    fromLanguage = value;
                                                    countryCodeFrom = 'lv';
                                                  });
                                                }
                                                else if (value == 'Polish') {
                                                  setState(() {
                                                    fromLanguage = value;
                                                    countryCodeFrom = 'pl';
                                                  });
                                                }
                                                else if (value == 'Romanian') {
                                                  setState(() {
                                                    fromLanguage = value;
                                                    countryCodeFrom = 'ro';
                                                  });
                                                }
                                                else if (value == 'Russian') {
                                                  setState(() {
                                                    fromLanguage = value;
                                                    countryCodeFrom = 'ru';
                                                  });
                                                }
                                                else if (value == 'Thai') {
                                                  setState(() {
                                                    fromLanguage = value;
                                                    countryCodeFrom = 'th';
                                                  });
                                                }
                                                else if (value == 'Ukrainian') {
                                                  setState(() {
                                                    fromLanguage = value;
                                                    countryCodeFrom = 'uk';
                                                  });
                                                }
                                              }),


                                          Text(
                                            'To',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: "Times New Roman"),
                                          ),
                                          DropdownButton(
                                              dropdownColor: Colors.black,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily:
                                                      "Times New Roman"),
                                              value: toLanguage,
                                              items: [
                                                ///french
                                                DropdownMenuItem(
                                                  child: Text(
                                                    "French",
                                                  ),
                                                  value: 'French',
                                                ),
                                                ///english
                                                DropdownMenuItem(
                                                  child: Text("English"),
                                                  value: 'English',
                                                ),
                                                ///urdu
                                                DropdownMenuItem(
                                                  child: Text("Urdu"),
                                                  value: 'Urdu',
                                                ),
                                                ///Arabic
                                                DropdownMenuItem(
                                                  child: Text("Arabic"),
                                                  value: 'Arabic',
                                                ),
                                                ///Hindi
                                                DropdownMenuItem(
                                                  child: Text("Hindi"),
                                                  value: 'Hindi',
                                                ),
                                                ///German
                                                DropdownMenuItem(
                                                  child: Text("German"),
                                                  value: "German",
                                                ),
                                                ///japanese
                                                DropdownMenuItem(
                                                  child: Text("Japanese"),
                                                  value: "Japanese",
                                                ),
                                                ///Korean
                                                DropdownMenuItem(
                                                  child: Text("Korean"),
                                                  value: "Korean",
                                                ),
                                                ///turkish
                                                DropdownMenuItem(
                                                  child: Text("Turkish"),
                                                  value: "Turkish",
                                                ),
                                                ///Armenia//hy//am
                                                DropdownMenuItem(
                                                  child: Text("Armenia"),
                                                  value: "Armenia",
                                                ),
                                                ///Bengali//bn
                                                DropdownMenuItem(
                                                  child: Text("Bengali"),
                                                  value: "Bengali",
                                                ),
                                                ///Bulgarian//bg
                                                DropdownMenuItem(
                                                  child: Text("Bulgarian"),
                                                  value: "Bulgarian",
                                                ),
                                                ///Danish//da
                                                DropdownMenuItem(
                                                  child: Text("Danish"),
                                                  value: "Danish",
                                                ),
                                                ///Dutch//nl
                                                DropdownMenuItem(
                                                  child: Text("Dutch"),
                                                  value: "Dutch",
                                                ),
                                                ///Spanish//es
                                                DropdownMenuItem(
                                                  child: Text("Spanish"),
                                                  value: "Spanish",
                                                ),
                                                ///Swedish//sv
                                                DropdownMenuItem(
                                                  child: Text("Swedish"),
                                                  value: "Swedish",
                                                ),
                                                ///Estonian
                                                DropdownMenuItem(
                                                  child: Text("Estonian"),
                                                  value: "Estonian",
                                                ),
                                                ///Greek
                                                DropdownMenuItem(
                                                  child: Text("Greek"),
                                                  value: "Greek",
                                                ),
                                                ///Hungarian//hu
                                                DropdownMenuItem(
                                                  child: Text("Hungarian"),
                                                  value: "Hungarian",
                                                ),
                                                ///Italian//it
                                                DropdownMenuItem(
                                                  child: Text("Italian"),
                                                  value: "Italian",
                                                ),
                                                ///Latvian//lv
                                                DropdownMenuItem(
                                                  child: Text("Latvian"),
                                                  value: "Latvian",
                                                ),
                                                ///Polish//pl
                                                DropdownMenuItem(
                                                  child: Text("Polish"),
                                                  value: "Polish",
                                                ),
                                                ///Romanian//ro
                                                DropdownMenuItem(
                                                  child: Text("Romanian"),
                                                  value: "Romanian",
                                                ),
                                                ///Russian//ru
                                                DropdownMenuItem(
                                                  child: Text("Russian"),
                                                  value: "Russian",
                                                ),
                                                ///Thai
                                                DropdownMenuItem(
                                                  child: Text("Thai"),
                                                  value: "Thai",
                                                ),
                                                ///Ukrainian//uk
                                                DropdownMenuItem(
                                                  child: Text("Ukrainian"),
                                                  value: "Ukrainian",
                                                ),


                                              ],
                                              onChanged: (value) {
                                                if (value == 'French') {
                                                  setState(() {
                                                    toLanguage = value;
                                                    countryCodeTo = 'fr';
                                                  });
                                                }
                                                else if (value == 'English') {
                                                  setState(() {
                                                    toLanguage = value;
                                                    countryCodeTo = 'en';
                                                  });
                                                }
                                                else if (value == 'Urdu') {
                                                  setState(() {
                                                    toLanguage = value;
                                                    countryCodeTo = 'ur';
                                                  });
                                                }
                                                else if (value == 'Arabic') {
                                                  setState(() {
                                                    toLanguage = value;
                                                    countryCodeTo = 'ar';
                                                  });
                                                }
                                                else if (value == 'Hindi') {
                                                  setState(() {
                                                    toLanguage = value;
                                                    countryCodeTo = 'hi';
                                                  });
                                                }
                                                else if (value == 'German') {
                                                  setState(() {
                                                    toLanguage = value;
                                                    countryCodeTo = 'de';
                                                  });
                                                }
                                                else if (value == 'Japanese') {
                                                  setState(() {
                                                    toLanguage = value;
                                                    countryCodeTo = 'ja';
                                                  });
                                                }
                                                else if (value == 'Korean') {
                                                  setState(() {
                                                    toLanguage = value;
                                                    countryCodeTo = 'ko';
                                                  });
                                                }
                                                else if (value == 'Turkish') {
                                                  setState(() {
                                                    toLanguage = value;
                                                    countryCodeTo = 'tr';
                                                  });
                                                }
                                                else if (value == 'Armenia') {
                                                  setState(() {
                                                    toLanguage = value;
                                                    countryCodeTo = 'hy';
                                                  });
                                                }
                                                else if (value == 'Bengali') {
                                                  setState(() {
                                                    toLanguage = value;
                                                    countryCodeTo = 'bn';
                                                  });
                                                }
                                                else if (value == 'Bulgarian') {
                                                  setState(() {
                                                    toLanguage = value;
                                                    countryCodeTo = 'bg';
                                                  });
                                                }
                                                else if (value == 'Danish') {
                                                  setState(() {
                                                    toLanguage = value;
                                                    countryCodeTo = 'da';
                                                  });
                                                }
                                                else if (value == 'Dutch') {
                                                  setState(() {
                                                    toLanguage = value;
                                                    countryCodeTo = 'nl';
                                                  });
                                                }
                                                else if (value == 'Spanish') {
                                                  setState(() {
                                                    toLanguage = value;
                                                    countryCodeTo = 'es';
                                                  });
                                                }
                                                else if (value == 'Swedish') {
                                                  setState(() {
                                                    toLanguage = value;
                                                    countryCodeTo = 'sv';
                                                  });
                                                }
                                                else if (value == 'Estonian') {
                                                  setState(() {
                                                    toLanguage = value;
                                                    countryCodeTo = 'et';
                                                  });
                                                }
                                                else if (value == 'Greek') {
                                                  setState(() {
                                                    toLanguage = value;
                                                    countryCodeTo = 'el';
                                                  });
                                                }
                                                else if (value == 'Hungarian') {
                                                  setState(() {
                                                    toLanguage = value;
                                                    countryCodeTo = 'hu';
                                                  });
                                                }
                                                else if (value == 'Italian') {
                                                  setState(() {
                                                    toLanguage = value;
                                                    countryCodeTo = 'it';
                                                  });
                                                }
                                                else if (value == 'Latvian') {
                                                  setState(() {
                                                    toLanguage = value;
                                                    countryCodeTo = 'lv';
                                                  });
                                                }
                                                else if (value == 'Polish') {
                                                  setState(() {
                                                    toLanguage = value;
                                                    countryCodeTo = 'pl';
                                                  });
                                                }
                                                else if (value == 'Romanian') {
                                                  setState(() {
                                                    toLanguage = value;
                                                    countryCodeTo = 'ro';
                                                  });
                                                }
                                                else if (value == 'Russian') {
                                                  setState(() {
                                                    toLanguage = value;
                                                    countryCodeTo = 'ru';
                                                  });
                                                }
                                                else if (value == 'Thai') {
                                                  setState(() {
                                                    toLanguage = value;
                                                    countryCodeTo = 'th';
                                                  });
                                                }
                                                else if (value == 'Ukrainian') {
                                                  setState(() {
                                                    toLanguage = value;
                                                    countryCodeTo = 'uk';
                                                  });
                                                }
                                              })
                                        ],
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(18.0),
                                        child: Text(
                                          'Enter page number',
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.05,
                                              color: Colors.white,
                                              fontFamily: "Times New Roman"),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: new TextField(
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: "Times New Roman"),
                                          controller: _textEditingController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            hintStyle: TextStyle(
                                                color: Colors.white,
                                                //fontWeight: FontWeight.w700,
                                                fontFamily: 'Times New Roman',
                                                fontSize: 13),
                                            hintText: 'Enter Page Number',
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(18.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              position = false;
                                            });
                                          },
                                          child: new Text(
                                            'Back',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: "Times New Roman"),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            pickPage();
                                          },
                                          child: new Text(
                                            'Convert',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: "Times New Roman"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ))
                        : Container()
                  ])),
            ),
    );
  }
}

///............................................................//////////////////////////////////////////////////////////////new class

class ExtractPageText2 extends StatefulWidget {
  final text;
  const ExtractPageText2({this.text, Key key}) : super(key: key);

  @override
  _ExtractPageText2State createState() => _ExtractPageText2State(text: text);
}

enum TtsState { playing, stopped, paused, continued }

class _ExtractPageText2State extends State<ExtractPageText2> {
  final text;
  _ExtractPageText2State({this.text});
  bool _playing = false;
  FlutterTts flutterTts;
  TtsState ttsState = TtsState.stopped;
  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  get isPaused => ttsState == TtsState.paused;
  get isContinue=> ttsState == TtsState.continued;
  dynamic languages;
  double volume = 1.0;
  double pitch = 1.0;
  double rate = 0.5;
  String _newVoiceText;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initTts();
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  ///
  Future _getLanguage() async {
    languages = await flutterTts.getLanguages;
    print('Available language ${languages}');
    if (languages != null) {
      setState(() {
        languages;
      });
    }
  }

  ///
  initTts() {
    flutterTts = FlutterTts();
    _getLanguage();
    flutterTts.setStartHandler(() {
      setState(() {
        print('Playing');
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print('Complete');
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setErrorHandler((message) {
      setState(() {
        print('error:$message');
        ttsState = TtsState.stopped;
      });
    });
  }

  ///
  Future _speak() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (toString() != null) {
      setState(() {
        _newVoiceText = text.toString();
      });
      if (_newVoiceText.isNotEmpty) {
        var result = await flutterTts.speak(_newVoiceText);
        if (result == 1)
          setState(() {
            ttsState = TtsState.playing;
            _playing = true;
          });
      }
    }
  }

  ///
  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) {
      setState(() {
        ttsState = TtsState.stopped;
        _playing = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.greenAccent,
      body: Container(
        decoration: BoxDecoration(image: DecorationImage(image: AssetImage('images/b2.png'),fit: BoxFit.fill)),
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 25.0,left: 8.0),
                  child: Text('PDF Text Extractor\n&\nVoice Reader',textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Times New Roman",
                        fontWeight: FontWeight.w700,
                        fontSize: MediaQuery.of(context).size.width * 0.05),),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.76,
                decoration: BoxDecoration(
                    color: Colors.black, borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                      child: Text(
                    text,
                    style: TextStyle(color: Colors.white),
                  )),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(color: Colors.black,shape: BoxShape.circle,border: Border.all(color: Colors.white)),
                        child: IconButton(
                            onPressed: () {
                              FlutterClipboard.copy(text);
                              Fluttertoast.showToast(msg: "Text will be copied");
                            },
                            icon: Icon(Icons.copy,color: Colors.white,)),
                      ),
                      Text('Copy',style: TextStyle(fontFamily: "Times New Roman",color: Colors.white),)
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(color: Colors.black,shape: BoxShape.circle,border: Border.all(color: Colors.white)),
                        child: IconButton(
                            onPressed: () {
                              Share.share(text);
                            },
                            icon: Icon(Icons.share,color: Colors.white,)),
                      ),
                      Text('Share',style: TextStyle(fontFamily: "Times New Roman",color: Colors.white),)
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(color: Colors.black,shape: BoxShape.circle,border: Border.all(color: Colors.white)),
                        child: IconButton(
                            onPressed: () {
                              if(_playing==false){
                                _speak();
                                setState(() {
                                  _text='Stop';
                                });
                              }
                              else{
                                _stop();
                                setState(() {
                                  _playing=true;
                                  _text='Play';
                                });
                              }
                            },
                            icon:
                                _playing ? Icon(Icons.pause,color: Colors.white,) : Icon(Icons.play_arrow,color: Colors.white,) ),
                      ),
                      Text(_text,style: TextStyle(fontFamily: "Times New Roman",color: Colors.white),)
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
String _text='Play';
}
