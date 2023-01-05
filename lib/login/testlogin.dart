import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:e_parkir_02/home/home.dart';
import 'package:e_parkir_02/home/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class testlogin extends StatefulWidget {
  // testlogin({Key? key, required this.title}) : super(key: key);
  // final String title;

  @override
  _testloginState createState() => _testloginState();
}

class _testloginState extends State<testlogin> {
  //For LinearProgressIndicator.
  bool _visible = false;

  //Textediting Controller for Username and Password Input
  final userController = TextEditingController();
  final pwdController = TextEditingController();

  Future userLogin() async {
    //Login API URL
    //use your local IP address instead of localhost or use Web API
    //String url = "http://10.0.2.2/eparkirlogin/login/login.php";
    String url = "https://login.schoolmedia.id/yogi/eparkir/login/login.php";

    // Showing LinearProgressIndicator.
    setState(() {
      _visible = true;
    });

    // Getting username and password from Controller
    var data = {
      'email': userController.text,
      'password': pwdController.text,
    };

    //Starting Web API Call.
    var response = await http.post(url, body: json.encode(data));

    if (response.statusCode == 200) {
      //Server response into variable
      print(response.body);
      var msg = jsonDecode(response.body);

      //Check Login Status
      if (msg['loginStatus'] == true) {
        var idu = msg['userInfo']['id'];
        print('iduser:$idu');
        setState(() {
          //hide progress indicator
          iduser(int.parse(idu));

          _visible = false;
        });

        // Navigate to Home Screen
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        setState(() {
          //hide progress indicator
          _visible = false;

          //Show Error Message Dialog
          showMessage(msg["message"]);
        });
      }
    } else {
      setState(() {
        //hide progress indicator
        _visible = false;

        //Show Error Message Dialog
        showMessage("Error during connecting to Server.");
      });
    }
  }

  iduser(int a) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      //print();
    });
    prefs.setInt('iduser', a);
  }

  Future<void> _iduser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      print(pid);
    });
    prefs.setInt('iduser', pid);
  }

  hapusSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('iduser');
  }

  Future<dynamic>? showMessage(String _msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(_msg),
          actions: <Widget>[
            TextButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/images/login.png'), fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(children: [
          Container(
            padding: const EdgeInsets.only(left: 35, top: 110),
            child: const Text(
              "E-Parkir",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                  right: 35,
                  left: 35,
                  top: MediaQuery.of(context).size.height * 0.5),
              child: Column(children: [
                TextField(
                  controller: userController,
                  decoration: InputDecoration(
                    fillColor: Colors.grey.shade100,
                    filled: true,
                    hintText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextField(
                  obscureText: true,
                  controller: pwdController,
                  autocorrect: true,
                  decoration: InputDecoration(
                    fillColor: Colors.grey.shade100,
                    filled: true,
                    hintText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 65,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sign In',
                      style: TextStyle(
                        color: Color(0xff4c505b),
                        fontSize: 27,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Visibility(
                        visible: _visible,
                        child: Container(
                            margin: EdgeInsets.only(bottom: 30),
                            child: CircularProgressIndicator())),
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color(0xff4c505b),
                      child: IconButton(
                        color: Colors.white,
                        onPressed: userLogin,
                        icon: const Icon(Icons.arrow_forward),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                // Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       TextButton(
                //         onPressed: () {
                //           Navigator.pushNamed(context, 'register');
                //         },
                //         child: const Text(
                //           'Sign Up',
                //           style: TextStyle(
                //             decoration: TextDecoration.underline,
                //             fontSize: 18,
                //             color: Color(0xff4c505b),
                //           ),
                //         ),
                //       ),
                //       TextButton(
                //         onPressed: () {},
                //         child: const Text(
                //           'Forgot Password',
                //           style: TextStyle(
                //             decoration: TextDecoration.underline,
                //             fontSize: 18,
                //             color: Color(0xff4c505b),
                //           ),
                //         ),
                //       ),
                //     ]),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
