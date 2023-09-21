import 'package:flutter/material.dart';
import 'dart:convert';
import './common/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:email_validator/email_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reseller_plusgrow/home.dart';

class DealerLogin extends StatefulWidget {
  const DealerLogin({super.key});

  @override
  State<DealerLogin> createState() => _DealerLoginState();
}

enum LoginStatus { notSignIn, signIn }

class _DealerLoginState extends State<DealerLogin> {
  LoginStatus _loginStatus = LoginStatus.notSignIn;
  String? email='', passcode='';
  final _loginKey = GlobalKey<FormState>();
  
  bool isPasswordValid(String passcode) { if(passcode.length == 8){ return false; } return true; }

  bool _isLoginEnable = true;

  void check() {
    final form = _loginKey.currentState;
    if (form != null && form.validate()) {  //form != null && form.validate() == form!.validate()
      form.save();
      login();
    }
  }
  
  void login() async {
    setState(() {
      _isLoginEnable = false;
    });
    final response = await http.post(Uri.https(globals.baseURL,"/api/reseller-login"),headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        }, body: jsonEncode({
      "email": email,
      "pass_code": passcode,
    }));

    var data = jsonDecode(response.body);
    var resCode = response.statusCode;
    
    String message = data['message'];
    if (resCode == 200 && data['api_token'] != null) {
      int id = data['customer']['id'];
      int customerId = data['customer']['customer_id'];
      String userEmail = data['customer']['email'];
      String firstName = data['customer']['first_name'];
      String lastName = data['customer']['last_name'];
      String phone = data['customer']['phone'] ?? '';
      String ordersCount = data['customer']['orders_count'];
      String totalSpent = data['customer']['total_spent'];
      int status = data['customer']['status'];
      String apiToken = data['api_token'];
      int cartCount = await globals.getCartCount(apiToken);
      int notificationCount = await globals.getNotificationCount(apiToken);
      if (status == 1) {
        setState(() {
          _loginStatus = LoginStatus.signIn;
          savePref(id, customerId, userEmail, firstName, lastName, phone, ordersCount, totalSpent, status, apiToken, cartCount, notificationCount);
        });
      }else{
        errorToast('Oops! your account is deactivated.');
      }
    }else{
      errorToast('$message !!');
    }
    setState(() {
      _isLoginEnable = true;
    });
  }

  void signOut() async {    
    savePref(0, 0, '', '', '', '', '', '', 0, '', 0, 0);
    setState(() {
      _loginStatus = LoginStatus.notSignIn;
    });
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

  void savePref(int id, int customerId, String userEmail, String firstName, String lastName, String phone, String ordersCount, String totalSpent, int status, String apiToken, int cartCount, int notifyCount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('id', id);
    await prefs.setInt('customerId', customerId);
    await prefs.setString('userEmail', userEmail);
    await prefs.setString('firstName', firstName);
    await prefs.setString('lastName', lastName);
    await prefs.setString('phone', phone);
    await prefs.setString('ordersCount', ordersCount);
    await prefs.setString('totalSpent', totalSpent);
    await prefs.setInt('status', status);
    await prefs.setString('apiToken', apiToken);
    await prefs.setInt('cartCount', 0);
    await prefs.setInt('notificationCount', 0);
  }

  int? userStatus = 0;
  void getPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userStatus = prefs.getInt("status");
      _loginStatus = userStatus == 1 ? LoginStatus.signIn : LoginStatus.notSignIn;
    });
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    switch (_loginStatus) {
      case LoginStatus.notSignIn:
        return Container(
          decoration: const BoxDecoration(
            color: Color.fromRGBO(14, 29, 48, 1),
            image: DecorationImage(
              image: AssetImage('assets/herobg.png'),
              fit: BoxFit.cover,
            )
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset : false,
            body: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 0, top: 100),
                  child: Column(
                    children: <Widget>[
                      // Logo
                      Image.asset('assets/PG_Logo.png',
                        width:250,
                        height: 100,
                      ),
                      
                      // Header
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          padding: const EdgeInsets.only(top: 25),
                          child: const Center(
                            child: Text(
                              "Reseller Login",
                              textAlign: TextAlign.left,
                              style: TextStyle(color: Colors.white, fontSize: 33, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ),
                      
                      // Sub Header
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          padding: const EdgeInsets.only(top: 15),
                          child: const Center(
                            child: Text(
                              "Enter your registered email & passcode.",
                              textAlign: TextAlign.left,
                              style: TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                      
                      // Login Form
                      Container(
                        margin: const EdgeInsets.only(top: 30),
                        padding: const EdgeInsets.all(8),                        
                        width:300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Colors.transparent,
                        ),
                        child: Form(
                          key: _loginKey,
                          child:  Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              // Email Input
                              Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                child: TextFormField(
                                  autofocus: true,
                                  initialValue: 'mailbox@plusgrow.com',
                                  onSaved: (e) => email = e,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {                                      
                                      return 'Please Enter Email ID';
                                    }
                                    else if(!EmailValidator.validate(value)){
                                      return 'Please Enter Valid Email ID';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(                                  
                                    contentPadding: EdgeInsets.only(left: 10),
                                    hintText: 'Email Id',
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ),
                              
                              // Passcode Input
                              TextFormField(
                                initialValue: '29443695',
                                onSaved: (e) => passcode = e,
                                  validator: (passcode) {
                                    if (passcode == null || passcode.isEmpty) {
                                      return 'Please Enter Pass Code';
                                    }
                                    else if (isPasswordValid(passcode) || !RegExp(r'^[0-9]+$').hasMatch(passcode)){
                                        return 'Please Enter Valid Pass Code.';
                                    }
                                    return null;
                                  },
                                decoration: const InputDecoration(                                  
                                    contentPadding: EdgeInsets.only(left: 10),
                                    hintText: 'Pass Code',
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                              ),
                              
                              // Login Button
                              Container(
                                margin: const EdgeInsets.only(top: 20),
                                child: ElevatedButton(
                                  onPressed: (){
                                    _isLoginEnable ? check() : null;
                                  },
                                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(const Color.fromRGBO(13, 66, 255, 1))),
                                  child: Container(
                                    padding: const EdgeInsets.all(15.0),
                                    child: const Text('Login'),
                                  )
                                )
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ),
              ],
            ),
          ),
        );
      case LoginStatus.signIn:
        return HomePage(signOut);
    }
  }
}
