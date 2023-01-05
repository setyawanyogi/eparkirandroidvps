import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:e_parkir_02/home/home.dart';
import 'package:e_parkir_02/home/home_page.dart';
import 'package:e_parkir_02/login/email_provider.dart';
import 'package:e_parkir_02/home/pages/petugas_page.dart';

class LoginUser extends StatefulWidget {
  LoginUserState createState() => LoginUserState();
}

class LoginUserState extends State {
  // For CircularProgressIndicator.
  bool visible = false;

  // Getting value from TextField widget.
  final emailController = TextEditingController();
  final passwordController = TextEditingController();


  

  Future userLogin() async {
    // Showing CircularProgressIndicator.
    setState(() {
      visible = true;
    });

    // Getting value from Controller
    String email = emailController.text;
    String password = passwordController.text;
    
    

    // SERVER LOGIN API URL
    var url = 'http://10.0.2.2/eparkirlogin/login/login_user.php';
    //var url = 'http://10.0.2.2/eparkirlogin/login/login.php';
    //var url = 'http://103.55.37.171/eparkir/login/login_user.php';

    // Store all data with Param Name.
    var data = {'email': email, 'password': password};

    // Starting Web API Call.
    var response = await http.post(url, body: json.encode(data));

    // Getting Server response into variable.
    var message = jsonDecode(response.body);
    // print(message['id']);
    // If the Response Message is Matched.
    if (message == 'Login Matched') {
      print(message);
      // print(message['id']); 
      // print(message['email']);  
      // Hiding the CircularProgressIndicator.
      setState(() {
        visible = true;
      });
    
      // Navigate to Profile Screen & Sending Email to Next Screen.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => new HomePage()),
        //MaterialPageRoute(builder: (context) => ProfileScreen(email : emailController.text))
      );
    } else {
      // If Email or Password did not Matched.
      // Hiding the CircularProgressIndicator.
      setState(() {
        visible = false;
      });

      // Showing Alert Dialog with Response JSON Message.
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text(message),
            actions: <Widget>[
              FlatButton(
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
  }

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
                  controller: emailController,
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
                  controller: passwordController,
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
                        visible: visible,
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
