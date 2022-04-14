import 'package:avatar_glow/avatar_glow.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pdf_reader/speechAPI.dart';
import 'package:share/share.dart';
import 'package:speech_to_text/speech_to_text.dart';



class VoiceMessage extends StatefulWidget {
  const VoiceMessage({Key key}) : super(key: key);

  @override
  _VoiceMessageState createState() => _VoiceMessageState();
}

enum TtsState { playing, stopped, paused, continued }

class _VoiceMessageState extends State<VoiceMessage> {
  bool _isListening = false;
  SpeechToText _speechToText;
  TextEditingController _textEditingController = TextEditingController();
  FlutterTts flutterTts;
  dynamic languages;
  double volume = 1.0;
  double pitch = 1.0;
  double rate = 0.5;
  String _newVoiceText;
  TtsState ttsState = TtsState.stopped;
  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initTts();
    _speechToText = SpeechToText();
  }
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
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              top:0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
            decoration: BoxDecoration(image: DecorationImage(image: AssetImage('images/b2.png'),fit: BoxFit.fill)),
          )),
          ///speech to text heading
          Positioned(
              top: 80,
              left: 10,
              right: 10,
              child: Center(
                  child: Text(
                    "Speech TO Text",
                    style: TextStyle(
                        color:
                        Colors.black,
                        fontFamily: "Times New Roman",
                        fontSize: MediaQuery.of(context).size.height * 0.03),
                  ))),
          ///Text Box Container
          Positioned(
              top: 110,
              bottom: size.width * 0.28,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      color:
                      Colors.black87,
                      //Colors.tealAccent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white,width: 2)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      _textEditingController.text,
                      style: TextStyle(
                          fontFamily: "Times New Roman",
                          color: Colors.white,
                          fontSize: 18),
                    ),
                  ),
                ),
              )
          ),
          ///Tap on mic button and speak
          Positioned(
              top: 120,
              left: 0,
              right: 0,
              child: Center(
                  child: Text(
                    'Tap on Mic button and speak',
                    style: TextStyle(
                        color: Colors.white, fontFamily: "Times New Roman"),
                  ))
          ),
          ///mic ........
          Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: size.width * 0.25,
                color: Colors.transparent,
                child: Stack(
                  children: [
                    Center(
                      heightFactor: 0.5,
                      child: InkWell(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.18,
                          height: MediaQuery.of(context).size.width * 0.18,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white,width: 2,
                              ),shape: BoxShape.circle
                          ),
                          child: AvatarGlow(
                            animate: _isListening,
                            glowColor: Colors.black38,
                            endRadius: 90.0,
                            repeat: true,
                            showTwoGlows: _isListening,
                            duration: Duration(milliseconds: 2000),
                            repeatPauseDuration: Duration(milliseconds: 100),
                            child: _isListening
                                ? Icon(
                              Icons.mic,
                              size: size.width * 0.15,
                            )
                                : Icon(
                              Icons.mic_none,
                              size: size.width * 0.15,
                            ),
                          ),
                        ),
                        onTap: () {
                          _listen();
                        },
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ///Delete button icon
                          Column(
                            children: [
                              IconButton(
                                icon: Icon(Icons.delete,color: Colors.white,),
                                onPressed: () {
                                  if (_textEditingController.text.isNotEmpty) {
                                    setState(() {
                                      _textEditingController.text = '';
                                    });
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "There will be no text to delete");
                                  }
                                },
                              ),
                              Text(
                                'Delete',
                                style: TextStyle(fontFamily: 'Times New Roman'),
                              ),
                            ],
                          ),

                          ///copy icon button
                          Column(
                            children: [
                              IconButton(
                                icon: Icon(Icons.copy,color: Colors.white,),
                                onPressed: () {
                                  if (_textEditingController.text.isNotEmpty) {
                                    Fluttertoast.showToast(
                                        msg: 'Text will be copied',
                                        backgroundColor: Colors.yellowAccent);
                                    FlutterClipboard.copy(
                                        _textEditingController.text);
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: 'Text will be empty',
                                        backgroundColor: Colors.yellowAccent);
                                  }
                                },
                              ),
                              Text(
                                'Copy',
                                style: TextStyle(fontFamily: 'Times New Roman'),
                              ),
                            ],
                          ),

                          ///Spacing container
                          Column(
                            children: [
                              Container(
                                width: size.width * 0.1,
                                height: size.width * 0.14,
                              ),
                              Text(
                                'Translate',
                                style: TextStyle(fontFamily: 'Times New Roman'),
                              ),
                            ],
                          ),

                          ///Share icon button
                          Column(
                            children: [
                              IconButton(
                                icon: Icon(Icons.share,color: Colors.white,),
                                onPressed: () {
                                  if (_textEditingController
                                      .text.isNotEmpty) {
                                    Share.share(
                                        _textEditingController.text);
                                  } else {
                                    Fluttertoast.showToast(
                                        msg:
                                        'There will be no text to shared');
                                  }
                                },
                              ),
                              Text(
                                'Share',
                                style: TextStyle(fontFamily: 'Times New Roman'),
                              ),
                            ],
                          ),

                          ///speaker icon button
                          Column(
                            children: [
                              IconButton(
                                icon: Icon(Icons.speaker,color: Colors.white,),
                                onPressed: () {
                                  if (_textEditingController
                                      .text.isNotEmpty) {
                                    setState(() {
                                      flutterTts.setLanguage('en_US');
                                    });
                                    _speak();
                                  } else {
                                    Fluttertoast.showToast(
                                        msg:
                                        'There Will be no translated text to speak');
                                  }
                                },
                              ),
                              Text(
                                'Speak',
                                style: TextStyle(fontFamily: 'Times New Roman'),
                              ),
                            ],
                          ),

                        ],
                      ),
                    )
                  ],
                ),
              ))
        ],
      ),
    );
  }
  Future _getLanguage() async {
    languages = await flutterTts.getLanguages;
    print('Available language ${languages}');
    if (languages != null) {
      setState(() {
        languages;
      });
    }
  }

  Future _speak() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (_textEditingController != null) {
      setState(() {
        _newVoiceText = _textEditingController.text;
      });
      if (_newVoiceText.isNotEmpty) {
        var result = await flutterTts.speak(_newVoiceText);
        if (result == 1)
          setState(() {
            ttsState = TtsState.playing;
          });
      }
    }
  }

  Future toggleRecording() async {
    if (_isListening == true)
      SpeechApi.toggleRecording(
        onResult: (text) => setState(() {
          this._textEditingController.text = text;
          _isListening = false;
          print(_textEditingController.text);
        }),
        onListening: (isListening) {
          this._isListening = isListening;
          setState(() => this._isListening = isListening);
        },
      );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize(
        onStatus: (val) => print('onStatus:$val'),
        onError: (val) => print('onError:$val'),
      );
      if (available) {
        setState(() {
          _isListening = true;
        });
        _speechToText.listen(
            onResult: (val) => setState(() {
              _textEditingController.text = val.recognizedWords;
              _isListening = false;
            }));
      } else
        setState(() {
          _isListening = false;
        });
    } else
      setState(() {
        _isListening = false;
        _speechToText.stop();
      });
  }
}
