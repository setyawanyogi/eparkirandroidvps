//declare packages
import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';
import 'package:e_parkir_02/home/pages/crud/add.dart';
import 'package:e_parkir_02/home/pages/crud/detail.dart';

class Selesai extends StatefulWidget {
  Selesai() : super();

  @override
  SelesaiState createState() => SelesaiState();
}

class Debouncer {
  int? milliseconds;
  VoidCallback? action;
  Timer? timer;

  run(VoidCallback action) {
    if (null != timer) {
      timer!.cancel();
    }
    timer = Timer(
      Duration(milliseconds: Duration.millisecondsPerSecond),
      action,
    );
  }
}

class SelesaiState extends State<Selesai> with AutomaticKeepAliveClientMixin {
  final _debouncer = Debouncer();

  List<Subject> ulist = [];
  List<Subject> userLists = [];
  //API call for All Subject List

  String url = 'https://login.schoolmedia.id/yogi/eparkir/parkir/listselesai.php';

  Future<List<Subject>> getAllulistList() async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // print(response.body);
        List<Subject> list = parseAgents(response.body);
        return list;
      } else {
        throw Exception('Error');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static List<Subject> parseAgents(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Subject>((json) => Subject.fromJson(json)).toList();
  }

  @override
  void initState() {
    super.initState();
    getAllulistList().then((subjectFromServer) {
      setState(() {
        ulist = subjectFromServer;
        userLists = ulist;
      });
    });
  }

  //Main Widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Keluar"),
        centerTitle: true,
        backgroundColor: Colors.orange,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: <Widget>[
          //Search Bar to List of typed Subject
          Container(
            padding: EdgeInsets.all(15),
            child: TextField(
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                    color: Colors.blue,
                  ),
                ),
                suffixIcon: InkWell(
                  child: Icon(Icons.search),
                ),
                contentPadding: EdgeInsets.all(15.0),
                hintText: 'Cari Plat Nomor',
              ),
              onChanged: (string) {
                _debouncer.run(() {
                  setState(() {
                    userLists = ulist
                        .where(
                          (u) => (u.plat_nomor.toLowerCase().contains(
                                string.toLowerCase(),
                              )),
                        )
                        .toList();
                  });
                });
              },
            ),
          ),

          Expanded(
            child: Scrollbar(
              child: ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                padding: EdgeInsets.all(5),
                itemCount: userLists.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          //routing into edit page
                          //we pass the id note
                          MaterialPageRoute(
                              builder: (context) => Detail(
                                    id: userLists[index].id_parkir,
                                  )));
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ListTile(
                              title: Text(
                                '${userLists[index].plat_nomor}   (${userLists[index].status})',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Rp. ${userLists[index].biaya}',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 15.0),
                              trailing: Column(
                                children: <Widget>[
                                  Text(
                                    '',
                                    style: TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    '${userLists[index].jam_masuk} - ${userLists[index].jam_keluar}',
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
                                    '${userLists[index].tgl}',
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                  //Icon(Icons.flight_land),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              showTrackOnHover: true,
              isAlwaysShown: true,
            ),
          ),
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

//Declare Subject class for json data or parameters of json string/data
//Class For Subject
class Subject {
  var text;
  var id_parkir;
  var plat_nomor;
  var jenis_kendaraan;
  var jam_masuk;
  var jam_keluar;
  var tgl;
  var status;
  var biaya;

  Subject({
    required this.text,
    required this.id_parkir,
    required this.plat_nomor,
    required this.jenis_kendaraan,
    required this.jam_keluar,
    required this.jam_masuk,
    required this.tgl,
    required this.status,
    required this.biaya,
  });

  factory Subject.fromJson(Map<dynamic, dynamic> json) {
    return Subject(
      text: json['text'],
      id_parkir: json['id_parkir'],
      plat_nomor: json['plat_nomor'],
      jenis_kendaraan: json['jenis_kendaraan'],
      jam_keluar: json['jam_keluar'],
      jam_masuk: json['jam_masuk'],
      tgl: json['tgl'],
      status: json['status'],
      biaya: json['biaya'],
    );
  }
}
