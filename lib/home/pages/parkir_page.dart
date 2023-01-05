import 'package:e_parkir_02/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:e_parkir_02/home/pages/crud/add.dart';
import 'package:e_parkir_02/home/pages/crud/detail.dart';

import 'package:intl/intl.dart';

class ParkirPage extends StatefulWidget {
  ParkirPage({Key? key}) : super(key: key);

  @override
  _ParkirPageState createState() => _ParkirPageState();
}

class _ParkirPageState extends State<ParkirPage>
    with AutomaticKeepAliveClientMixin {
  //search bar
  // bool searching, error;
  // var data;
  // String query;
  // String dataurl = "http://10.0.2.2/eparkirlogin/widget/search_suggestion.php";
  List _get = [];
  @override
  void initState() {
    //searchbar
    
    super.initState();
    //in first time, this method will be executed
    _getData();
  }

  // void getSuggestion() async {
  //   //get suggestion function
  //   var res = await http.post(dataurl + "?query=" + Uri.encodeComponent(query));
  //   //in query there might be unwant character so, we encode the query to url
  //   if (res.statusCode == 200) {
  //     setState(() {
  //       data = json.decode(res.body);
  //       //update data value and UI
  //     });
  //   } else {
  //     //there is error
  //     setState(() {
  //       error = true;
  //     });
  //   }
  // }

  Future _getData() async {
    try {
      final response = await http.get(Uri.parse(
          //you have to take the ip address of your computer.
          //because using localhost will cause an error
          //'http://10.0.2.2/eparkirlogin/parkir/list.php'));
          'https://login.schoolmedia.id/yogi/eparkir/parkir/list.php'));

      // if response successful
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // entry data to variabel list _get
        setState(() {
          _get = data;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.orange,
        automaticallyImplyLeading: false,
        title: Text("Parkir"),
      ),
      body: _get.length != 0
          ? Scrollbar(
              child: ListView.builder(
                itemCount: _get.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    // onTap: () {
                    //   Navigator.push(
                    //   context,
                    //   //routing into edit page
                    //   //we pass the id note
                    //   MaterialPageRoute(builder: (context) => Detail(id_parkir: _get[index]['id_parkir'],))
                    //   );
                    // },
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          children: <Widget>[
                            // Text('${_get[index]['plat_nomor']}',
                            // style:
                            //   TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
                            //   //color: index % 2 == 0? Colors.white : null,
                            //   ),
                            //   ),
                            // SizedBox(
                            //   height: 2,
                            // ),
                            // Text('${_get[index]['jenis_kendaraan']}',
                            // style:
                            //   TextStyle(fontSize: 16,
                            //   //color: index % 2 == 0? Colors.white : null,
                            //   ),
                            // ),

                            ListTile(
                              title: Text(
                                '${_get[index]['plat_nomor']}   (${_get[index]['status']})',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Rp. ${_get[index]['biaya']}',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              // leading: CircleAvatar(
                              //   backgroundColor: Colors.green,
                              //   radius: 30,
                              //   child: Icon(Icons.local_parking, color: Colors.white,size: 30.0,),
                              // ),
                              //Icon(Icons.local_parking, color: Colors.green,size: 30.0,),
                              //trailing: Icon(Icons.star)),
                              trailing: Column(
                                children: <Widget>[
                                  Text(
                                    '',
                                    style: TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    '${_get[index]['jam_masuk']} - ${_get[index]['jam_keluar']}',
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                  Text(
                                    '',
                                    style: TextStyle(
                                      fontSize: 3,
                                    ),
                                  ),
                                  Text(
                                    '${_get[index]['tgl']}',
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                  //Icon(Icons.flight_land),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              showTrackOnHover: true,
              isAlwaysShown: true,
            )
          : Center(
              child: Text(
                "No Data Available",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
              context,
              //routing into add page
              MaterialPageRoute(builder: (context) => Add()));
        },
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

