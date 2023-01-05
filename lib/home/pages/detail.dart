import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

class Detail extends StatefulWidget {
  Detail({required this.id});

  String id;

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  final _formKey = GlobalKey<FormState>();

  //inisialize field
  var plat_nomor = TextEditingController();
  var image = TextEditingController();
  var images;

  List _images = [];

  @override
  void initState() {
    super.initState();
    //in first time, this method will be executed
    _getData();
  }

  //Http to get detail data
  Future _getData() async {
    try {
      final response = await http.get(Uri.parse(
          //you have to take the ip address of your computer.
          //because using localhost will cause an error
          //get detail data with id
          "https://login.schoolmedia.id/yogi/eparkir/parkir/detail.php?id_parkir='${widget.id}'"));
      print("id :" + widget.id);

      // if response successful
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          plat_nomor = TextEditingController(text: data['plat_nomor']);
          image = TextEditingController(text: data['image']);
          images = (data['image']);
          print(plat_nomor.text);
          print(image.text);

          print(images);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text("Foto Kendaraan"),
        // ignore: prefer_const_literals_to_create_immutables
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 5),
              SizedBox(height: 20),
              CachedNetworkImage(
                imageUrl: 'http://yogi.cybersecjustfor.fun/eparkir_api/parkir/images/$images',
                //imageUrl: 'http://10.0.2.2/eparkirlogin/parkir/images/3019368972.jpg',
                placeholder: (context, url) => new CircularProgressIndicator(),
                errorWidget: (context, url, error) => new Icon(Icons.error),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
