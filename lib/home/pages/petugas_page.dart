import 'package:e_parkir_02/login/testlogin.dart';
import 'package:e_parkir_02/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:e_parkir_02/login/login.dart';
import 'package:e_parkir_02/login/testlogin.dart';
import 'package:e_parkir_02/home/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PetugasPage extends StatefulWidget {
  State<PetugasPage> createState() => _PetugasPage();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class _PetugasPage extends State<PetugasPage> {
  final _formKey = GlobalKey<FormState>();

  //inisialize field

  int? id_user;

  @override
  void initState() {
    super.initState();
    //in first time, this method will be executed

    _loadid();
  }

  Future<List<dynamic>> _fecthDataUsers() async {
    var result = await http
        //.get("http://10.0.2.2/eparkirlogin/login/userlist.php?id='$id_user'");
        .get("https://login.schoolmedia.id/yogi/eparkir/login/userlist.php?id='$id_user'");
    return json.decode(result.body)['users'];
  }

  Future<void> _loadid() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      id_user = (prefs.getInt('iduser') ?? 0);
    });
  }

  // User Logout Function.
  logout() async {
    final pref = await SharedPreferences.getInstance();
    pref.clear();
    Navigator.pushReplacement(
        context, new MaterialPageRoute(builder: (context) => new MyApp()));
    //showAlertDialog(context);
  }

  removeValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Remove String
    await prefs.clear();
  }



  showAlertDialog(BuildContext contexts) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Tidak"),
      onPressed: () {
        // Close the dialog
        Navigator.of(contexts).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Iya"),
      onPressed: () {
        logout();
        Navigator.of(context).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Logout"),
      content: Text("Apa anda yakin ingin keluar?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            title: Text('Petugas'),
            backgroundColor: Colors.orange,
            centerTitle: true,
            automaticallyImplyLeading: false),
        body: Container(
          child: FutureBuilder<List<dynamic>>(
            future: _fecthDataUsers(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    padding: EdgeInsets.all(50),
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 150,
                          ),
                          Text(
                            snapshot.data[index]['nama'],
                            //"$id_user",
                            style: TextStyle(
                                fontSize: 30.0,
                                color: Colors.black,
                                letterSpacing: 2.0,
                                fontWeight: FontWeight.w400),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            snapshot.data[index]['email'],
                            style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.black,
                                letterSpacing: 2.0,
                                fontWeight: FontWeight.w300),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                              onPressed: () {
                                //showAlertDialog(context);
                                logout();
                              },
                              child: const Text('Logout')),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(),
                            ),
                          ),
                        ],
                      );
                    });
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }
}
