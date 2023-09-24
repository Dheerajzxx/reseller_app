import 'package:flutter/material.dart';
import 'dart:convert';
import '../common/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:reseller_plusgrow/ticket/faqs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Ask extends StatefulWidget {
  const Ask({super.key});

  @override
  State<Ask> createState() => _AskState();
}

class _AskState extends State<Ask> {
  String apiToken = '', errMessage = '';
  String? question = '';
  final _saveQuesKey = GlobalKey<FormState>();

  bool _isAskEnable = true;

  void getPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apiToken = prefs.getString("apiToken") ?? '';
    });
  }

  void submitForm() {
    final form = _saveQuesKey.currentState;
    if (form != null && form.validate()) {
      form.save();
      setState(() {
        _isAskEnable = false;
      });
      saveQues();
    }
  }
  
  void saveQues() async {
    final response = await http.post(Uri.https(globals.baseURL,"/api/save-question"),headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $apiToken'
        }, body: jsonEncode({
      "question": question
    }));
    
    var data = jsonDecode(response.body);
    var resCode = response.statusCode;
    String message = data['message'];
    if (resCode == 200) {
      errorToast('$message !!');
      askCompleted();
    }else{
      errorToast('Oops! Something went wrong.');
    }
  }

  void askCompleted(){    
    setState(() {
      _isAskEnable = true;
    });
    goTofaqs(context);
  }

  void goTofaqs(BuildContext context){
      Navigator.push( context, MaterialPageRoute(builder: (context) => const Faqs()));
  }

  errorToast(String toast) {
    return Fluttertoast.showToast(
        msg: toast,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 3,
        webPosition: "center",
        webBgColor: "linear-gradient(to top, red, yellow)",
        backgroundColor: Colors.red,
        textColor: Colors.white);
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const globals.AppBarItems('Ask Question', '/', 1),
      body: Container(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(243, 246, 252, 1)
        ),
        child: Form(
          key: _saveQuesKey,
          child:  Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(top: 20, left: 30, right: 30),
                    child: const Text('ASK YOUR QUESTION', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),),
                  ),
                ]
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(top: 20, left: 30, right: 30),
                    child: const Text('Ask your question from expert here.', style: TextStyle(),),
                  ),
                ]
              ),
              // Question box
              Container(
                margin: const EdgeInsets.only(top: 20, left: 30, right: 30),
                child: TextFormField(
                  onSaved: (e) => question = e,
                  validator: (value) {
                    if (value == null || value.isEmpty) {                                      
                      return 'Please Enter Your Question';
                    }
                    else if(value.length < 5){                      
                      return 'The question must be at least 5 characters.';
                    }
                    return null;
                  },
                  maxLines: 8,
                  minLines: 8,
                  decoration: const InputDecoration(                                  
                    contentPadding: EdgeInsets.all(20),
                    hintText: 'Write your question here.',
                    border: UnderlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              // Question Submit
              Container(
                margin: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: (){
                    _isAskEnable ? submitForm() : null;
                  },
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(const Color.fromRGBO(13, 66, 255, 1))),
                  child: Container(
                    padding: const EdgeInsets.all(15.0),
                    child: const Text('Submit Question'),
                  )
                )
              ),
            ]
          ),
        ),
      )
    );
  }
}