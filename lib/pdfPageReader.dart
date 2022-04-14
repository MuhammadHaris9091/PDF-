import 'dart:io';
import 'package:clipboard/clipboard.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart' as viewer;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pdf_text/pdf_text.dart';
import 'package:share/share.dart';

class PdfReaderPage extends StatefulWidget {
  const PdfReaderPage({Key key}) : super(key: key);

  @override
  _PdfReaderPageState createState() => _PdfReaderPageState();
}

bool _isLoading = true;
File result;
viewer.PDFDocument doc;

class _PdfReaderPageState extends State<PdfReaderPage> {


  void extractFile() async {
    result = await FilePicker.getFile(
      allowedExtensions: ['pdf', 'docx'],
      type: FileType.custom,
    );
    setState(() {
      _isLoading = true;
    });
    doc = await viewer.PDFDocument.fromFile(result);
    setState(() {
      _isLoading = false;
    });
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => FileViewer(
                  doc: doc,
                  result: result,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(image: DecorationImage(image: AssetImage('images/b1.png'),fit: BoxFit.fill)),
        child: Stack(
          children:[
            Positioned(

                top: MediaQuery.of(context).size.width*0.15,
                left: MediaQuery.of(context).size.width * 0.03,
                child: Center(child: Text('PDF Text Extractor\n&\nVoice Reader',textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: "Times New Roman",
                      fontWeight: FontWeight.w700,
                      fontSize: MediaQuery.of(context).size.width * 0.06),))),
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
                backgroundColor: MaterialStateProperty.all<Color>(Colors.redAccent),
                elevation: MaterialStateProperty.all(10),
                minimumSize: MaterialStateProperty.all<Size>(Size(60, 65)),
              ),
            ),
          ),
          ]
        ),
      ),
    );
  }
}

///............................................................................../////////////////////
class FileViewer extends StatefulWidget {
  final doc;
  final result;
  const FileViewer({this.doc, this.result, Key key}) : super(key: key);

  @override
  _FileViewerState createState() => _FileViewerState(doc: doc, result: result);
}

TextEditingController _textEditingController = TextEditingController();
PDFDoc pdfDoc;
PDFPage _page;
int pageNum;
String docText;

class _FileViewerState extends State<FileViewer> with TickerProviderStateMixin {
  final doc;
  final result;
  _FileViewerState({this.doc, this.result});
  bool loadingContainer=false;
  void pickPage() async {

    setState(() {
      loadingContainer=true;
      pageNum = int.parse(_textEditingController.text);
    });
    pdfDoc = await PDFDoc.fromFile(result);
    if(pageNum<=pdfDoc.length){

      _page = pdfDoc.pageAt(pageNum);
      docText = await _page.text;
      loadingContainer=false;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ExtractTextPage(
                text: docText,
              )));
    }
    else{
      setState(() {
        loadingContainer=false;
        Fluttertoast.showToast(msg: 'Enter a valid page number');
      });
    }
  }
  // _pickPage() async {
  //   pdfDoc = await PDFDoc.fromFile(result);
  //   showDialog<int>(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return NumberPickerDialog.integer(
  //           title: Text("Select Page"),
  //           minValue: 1,
  //           cancelWidget: Container(),
  //           maxValue: pdfDoc.length,
  //           initialIntegerValue: pageNumber,
  //         );
  //       }).then((int value) {
  //     if (value != null) {
  //       pageNumber = value;
  //       _loadPage();
  //     }
  //   });
  // }
  // _loadPage(){
  //   print(pageNumber);
  //   setState(() {
  //     viewer.PDFPage('',pageNumber);
  //   });
  // }


  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.lightBlue,
      body:
      loadingContainer?
      Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(image: DecorationImage(image: AssetImage('images/b1.png'),fit: BoxFit.fill)),
        child: SpinKitCubeGrid(
          color: Colors.white,
          size: 70.0,
        ),
      ):Container(
        decoration: BoxDecoration(image: DecorationImage(image: AssetImage('images/b1.png'),fit: BoxFit.fill)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [

              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 18.0,left: 8.0),
                    child: Text('PDF Text Extractor\n&\nVoice Reader',textAlign: TextAlign.center,
                        style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Times New Roman",
                        fontWeight: FontWeight.w700,
                        fontSize: MediaQuery.of(context).size.width * 0.05),),
                  ),
                ],
              ),
              Container(
                  width: size.width,
                  height: size.height * 0.75,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(0),
                      border: Border.all(color: Colors.black, width: 1.5)),
                  child: _isLoading
                      ? Container(
                          width: size.width,
                          height: size.width * 1.5,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(0),
                              border:
                                  Border.all(color: Colors.black, width: 1.5)),
                        )
                      : viewer.PDFViewer(
                          document: doc,

                        )),
              // Container(
              //   child: FloatingActionButton(
              //     onPressed: () {
              //
              //       _pickPage();
              //       // showDialog(
              //       //     context: context,
              //       //     builder: (BuildContext context) {
              //       //       return NumberPickerDialog.integer(
              //       //           minValue: 1,
              //       //           maxValue: pdfDoc.length,
              //       //           initialIntegerValue: pageNumber);
              //       //     });
              //     },
              //     child: Icon(Icons.view_carousel),
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => new AlertDialog(
                        backgroundColor: Colors.redAccent,
                        contentTextStyle:
                            TextStyle(fontFamily: 'Times New Roman'),
                        titleTextStyle:
                            TextStyle(fontFamily: 'Times New Roman'),
                        shape: Border.all(
                          color: Colors.white70,
                          width: 2,
                        ),
                        title: new Text('Enter page number'),
                        content: new TextField(
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Times New Roman"),
                          controller: _textEditingController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Times New Roman',
                                fontSize: 13),
                            hintText: 'Enter Number',
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: new Text('Back',style: TextStyle(color: Colors.white,fontFamily: "Times New Roman"),),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                              pickPage();
                            },
                            child: new Text('Enter',style: TextStyle(color: Colors.white,fontFamily: "Times New Roman"),),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text('Read',style: TextStyle(
                      fontFamily: 'Times New Roman',
                      color: Colors.red,
                      fontSize: MediaQuery.of(context).size.width * 0.05),),

                  style: ButtonStyle(

                    shadowColor: MaterialStateProperty.all<Color>(Colors.lime),
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    elevation: MaterialStateProperty.all(10),
                    minimumSize: MaterialStateProperty.all<Size>(Size(size.width, size.height*0.07)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

///...............................................................................////////////////////////

class ExtractTextPage extends StatefulWidget {
  final text;
  const ExtractTextPage({this.text, Key key}) : super(key: key);

  @override
  _ExtractTextPageState createState() => _ExtractTextPageState(text: text);
}

enum TtsState { playing, stopped, paused, continued }

class _ExtractTextPageState extends State<ExtractTextPage> {
  final text;
  _ExtractTextPageState({this.text});
  FlutterTts flutterTts;
  TtsState ttsState = TtsState.stopped;
  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  dynamic languages;
  double volume = 1.0;
  double pitch = 1.0;
  double rate = 0.5;
  String _newVoiceText;
  bool _playing = false;
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
      body: Container(
        decoration: BoxDecoration(image: DecorationImage(image: AssetImage('images/b2.png'),fit: BoxFit.fill)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                height: MediaQuery.of(context).size.height * 0.75,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.white38, borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                      child: Text(
                    text,
                    style: TextStyle(color: Colors.black),
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
                            icon: Icon(Icons.copy,color: Colors.white)),
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
                            icon: Icon(Icons.share,color: Colors.white)),
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
                                _playing ? Icon(Icons.pause,color: Colors.white) : Icon(Icons.play_arrow,color: Colors.white)),
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
