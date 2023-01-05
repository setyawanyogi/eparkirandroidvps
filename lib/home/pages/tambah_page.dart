import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TambahPage extends StatefulWidget {
  //TambahPage({Key key}) : super(key: key);

  @override
  _TambahPageState createState() => _TambahPageState();
}

class _TambahPageState extends State<TambahPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tambah"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
    );
  }
}