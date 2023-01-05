import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:async/async.dart';
import 'package:e_parkir_02/main.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:path/path.dart' as path;
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:e_parkir_02/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:e_parkir_02/home/pages/parkir_page.dart';
import 'package:e_parkir_02/login/testlogin.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import 'package:shared_preferences/shared_preferences.dart';

//import 'package:flutter_mobile_vision_2/flutter_mobile_vision_2.dart';

class Add extends StatefulWidget {
  // final String id_user;

  //  const Add({Key? key, required this.id_user}) : super(key: key);
  //Add({Key? key}) : super(key: key);

  @override
  State<Add> createState() => _AddState();
}

class _AddState extends State<Add> {
  final _formKey = GlobalKey<FormState>();
  List _getlist = [];
  //image
  File? _imageFile;
  int? id_user;

  bool textScanning = false;
  String scannedText = "";

  //thremal printer
  List<BluetoothDevice> devices = [];
  BluetoothDevice? selectedDevice;
  BlueThermalPrinter printer = BlueThermalPrinter.instance;
  //inisialize field
  List _get = [];
  List<String> items = ['Parkir', 'Selesai'];
  String? statusValue = 'Parkir';
  String jenis_kendaraan = '';
  int? id_kendaraan;
  var plat_nomor = TextEditingController();
  var status = TextEditingController();
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    //in first time, this method will be executed
    _getData();
    getDevices();
    _loadid();
    print(id_user.toString());

    //print("iduser : $id_user");
  }

  _pilihKamera() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 1920.0, maxWidth: 1080.0);
    setState(() {
      _imageFile = image;
    });
  }

  _pilihGallery() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 1920.0, maxWidth: 1080.0);

    setState(() {
      _imageFile = image;
    });
  }

  void getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker.pickImage(source: source);
      if (pickedImage != null) {
        textScanning = true;
        _imageFile = pickedImage;

        setState(() {});
        getRecognisedText(pickedImage);
      }
    } catch (e) {
      textScanning = false;
      _imageFile = null;
      scannedText = "Error occured while scanning";
      setState(() {});
    }
  }

  void getRecognisedText(File image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final textDetector = GoogleMlKit.vision.textDetector();
    RecognisedText recognisedText = await textDetector.processImage(inputImage);
    await textDetector.close();
    scannedText = "";

    // String scannedTextlast = scannedText.substring(0, scannedText.length - 4);
    // String pattern = r"(?m)([a-zA-Z]{1,3})(\d{1,4})([a-zA-Z]{0,3})";
    // RegExp regEx = RegExp(pattern);

    for (TextBlock block in recognisedText.blocks) {
      final String text = block.text;
      print("block of text: ");
      print(text);

  

      for (TextLine line in block.lines) {
        final String text = line.text;

        print("line of text: ");
        print(text);
        
        // for (TextElement element in line.elements) {
        //   final String text = element.text;

        //   print("element of text: ");
        //   print(text);
        //   //       if (regEx.hasMatch(line.text)) {
        //   //       scannedText += line.text + '\n';
        //   // }
        //   // scannedText += element.text + ' ';
        //   // plat_nomor.text = scannedText;

        //   //scannedText.substring(0,5);
        // }
        
         scannedText += line.text + ' ';
        plat_nomor.text = scannedText;
      }
    }
    textScanning = false;
    setState(() {});
  }

  Future _getData() async {
    try {
      final response = await http.get(Uri.parse(
          //you have to take the ip address of your computer.
          //because using localhost will cause an error
          //'http://10.0.2.2/eparkirlogin/parkir/list.php'));
          //'http://103.55.37.171/eparkir/parkir/list.php'));
          'http://yogi.cybersecjustfor.fun/eparkir_api/parkir/list.php'));

      // if response successful
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // entry data to variabel list _get
        setState(() {
          _getlist = data;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _loadid() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      id_user = (prefs.getInt('iduser') ?? 0);
    });
  }

  Future _onSubmit() async {
    setState(() {
      _visible = true;
    });
    try {
      var stream =
          http.ByteStream(DelegatingStream.typed(_imageFile!.openRead()));
      var lenght = await _imageFile!.length();
      var uri = Uri.parse("https://login.schoolmedia.id/yogi/eparkir/parkir/create.php");
      //var uri = Uri.parse("http://10.0.2.2/eparkirlogin/parkir/create.php");
      var request = http.MultipartRequest("POST", uri);

      var multipartFile = new http.MultipartFile("image", stream, lenght,
          filename: path.basename(_imageFile!.path));

      request.files.add(multipartFile);
      request.fields['id_kendaraan'] = id_kendaraan.toString();
      request.fields['status'] = statusValue;
      request.fields['plat_nomor'] = plat_nomor.text;
      request.fields['addedby'] = id_user.toString();

      // request.fields['id_kendaraan'] = id_kendaraan.toString();
      // request.fields['status'] = statusValue;
      // request.fields['plat_nomor'] = plat_nomor.text;
      // request.files.add(http.MultipartFile('image', stream, lenght,
      //     filename: path.basename(_imageFile.path)));
      var response = await request.send();
      if (response.statusCode > 2) {
        print(response.toString());
        response.stream.transform(utf8.decoder).listen((value) {
          var data = jsonDecode(value);
          print(data["message"]);
          print(data["id_parkir"]);
          print(data["biaya"]);
          print(data["plat_nomor"]);
          print(data["status"]);
          Navigator.push(context,
              new MaterialPageRoute(builder: (context) => new HomePage()));
          //print bluetooth
          printer.connect(selectedDevice!);
          printer.printNewLine();
          printer.printNewLine();
          printer.printCustom('E-PARKIR', 3, 1);
          printer.printNewLine();
          printer.printNewLine();
          printer.printCustom(plat_nomor.text, 2, 1);
          printer.printCustom(jenis_kendaraan, 2, 1);
          printer.printNewLine();
          printer.print3Column("Datang:", data["jam_masuk"], "", 1);
          printer.print3Column("Keluar:", data["jam_keluar"], "", 1);
          printer.print3Column("Tanggal:", data["tgl"], "", 1);
          printer.print3Column("Status:", data["status"], "", 1);
          printer.print3Column("Harga:", data["biaya"], "", 1);
          printer.printNewLine();
          printer.printNewLine();
          printer.printQRcode(data["id_parkir"].toString(), 200, 200, 1);
          printer.printNewLine();
          printer.printNewLine();
          printer.printNewLine();
        });
        setState(() {
          _visible = false;
          Navigator.pop(context);
        });
      } else {
        print("error");
      }
    } catch (e) {
      debugPrint("Error $e");
    }
  }

  // Future _onSubmitText() async {
  //   var uri = Uri.parse("http://103.55.37.171/eparkir/parkir/create.php");
  //   var request = http.MultipartRequest("POST", uri);
  //   try {
  //     return await http.post(
  //       //Uri.parse("http://10.0.2.2/eparkirlogin/parkir/create.php"),
  //       Uri.parse("http://103.55.37.171/eparkir/parkir/create.php"),
  //       body: {
  //         "id_kendaraan": id_kendaraan.toString(),
  //         "status": statusValue,
  //         "plat_nomor": plat_nomor.text,
  //         //"image" :
  //         //"status": status.text,
  //       },
  //     ).then((value) {
  //       //print message after insert to database
  //       //you can improve this message with alert dialog
  //       var data = jsonDecode(value.body);
  //       print(data["message"]);
  //       Navigator.push(context,
  //           new MaterialPageRoute(builder: (context) => new HomePage()));
  //       // showDialog(context: context,
  //       // builder: (BuildContext context) => AlertDialog(
  //       //     // title: Text('${data["plat_nomor"]}'),
  //       //     title: Text(data["plat_nomor"]),
  //       // ));
  //       printer.connect(selectedDevice!);
  //       printer.printNewLine();
  //       printer.printNewLine();
  //       printer.printCustom('e_parkir_02', 3, 1);
  //       printer.printNewLine();
  //       printer.printNewLine();
  //       printer.printCustom(plat_nomor.text, 2, 1);
  //       printer.printCustom(jenis_kendaraan, 2, 1);
  //       printer.printNewLine();
  //       printer.print3Column("Datang:", data["jam_masuk"], "", 1);
  //       printer.print3Column("Keluar:", data["jam_keluar"], "", 1);
  //       printer.print3Column("Tanggal:", data["tgl"], "", 1);
  //       printer.print3Column("Status:", data["status"], "", 1);
  //       printer.print3Column("Harga:", data["biaya"], "", 1);
  //       printer.printNewLine();
  //       printer.printNewLine();
  //       printer.printQRcode(data["id_parkir"].toString(), 200, 200, 1);
  //       printer.printNewLine();
  //       printer.printNewLine();
  //       printer.printNewLine();
  //       // Navigator.of(context)
  //       //     .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  void getDevices() async {
    devices = await printer.getBondedDevices();
    setState(() {});
  }

  //show popup dialog

  @override
  Widget build(BuildContext context) {
    var placeholder = Container(
      width: double.infinity,
      height: 150.0,
      child: Image.asset('././././assets/images/placeholder.jpg'),
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text("Tambah Data"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Scrollbar(
            child: Container(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Visibility(
                      visible: _visible,
                      child: Container(
                          padding: const EdgeInsets.all(0.0),
                          //margin: EdgeInsets.only(bottom: 30),
                          child: CircularProgressIndicator())),
                  DropdownSearch<dynamic>(
                    //you can design textfield here as you want
                    dropdownSearchDecoration: InputDecoration(
                      labelText: "Jenis Kendaraan",
                      hintText: "Pilih Jenis Kendaraan",
                    ),

                    //have two mode: menu mode and dialog mode
                    mode: Mode.MENU,
                    //if you want show search box
                    //showSearchBox: true,

                    //get data from the internet
                    onFind: (text) async {
                      var response = await http.get(Uri.parse(
                          //"http://10.0.2.2/eparkirlogin/widget/listkendaraan.php"));
                          "https://login.schoolmedia.id/yogi/eparkir/widget/listkendaraan.php"));

                      if (response.statusCode == 200) {
                        final data = jsonDecode(response.body);

                        setState(() {
                          _get = data['kendaraan'];
                        });
                      }

                      return _get as List<dynamic>;
                    },

                    //what do you want anfter item clicked
                    onChanged: (value) {
                      setState(() {
                        jenis_kendaraan = value['jenis_kendaraan'];
                        id_kendaraan = value['id_kendaraan'];
                      });
                    },

                    //this data appear in dropdown after clicked
                    itemAsString: (item) => item['jenis_kendaraan'],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Foto Plat Nomor',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    width: double.infinity,
                    height: 150.0,
                    child: InkWell(
                      onTap: () {
                        getImage(ImageSource.camera);
                      },
                      onLongPress: () {
                        getImage(ImageSource.gallery);
                      },
                      child: _imageFile == null
                          ? placeholder
                          : Image.file(
                              _imageFile!,
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Plat Nomor',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  TextFormField(
                    textCapitalization: TextCapitalization.characters,
                    controller: plat_nomor,
                    maxLines: 1,
                    
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]'))
                    ],
                    decoration: InputDecoration(
                        hintText: "Tap untuk Scan Plat Nomor",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        fillColor: Colors.white,
                        filled: true),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Plat Nomor is Required!';
                      }
                      return null;
                    },
                  ),
                  // Text(
                  //   '$id_user',
                  //   style: TextStyle(
                  //     color: Colors.black,
                  //     fontSize: 16,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  SizedBox(height: 20),
                  Text(
                    'Status',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  SizedBox(
                    width: double.infinity,
                    child: DropdownButton<String>(
                      value: statusValue,
                      items: items
                          .map((item) => DropdownMenuItem<String>(
                              value: item, child: Text(item)))
                          .toList(),
                      onChanged: (item) => setState(() => statusValue = item),
                    ),
                  ),
                  SizedBox(height: 15),
                  DropdownButton<BluetoothDevice>(
                      value: selectedDevice,
                      hint: const Text('Select Thermal Printer'),
                      onChanged: (devices) {
                        setState(() {
                          selectedDevice = devices;
                        });
                      },
                      items: devices
                          .map((e) => DropdownMenuItem(
                                child: Text(e.name!),
                                value: e,
                              ))
                          .toList()),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {
                            printer.connect(selectedDevice!);
                          },
                          child: const Text('Connect')),
                      SizedBox(height: 5),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          "Submit & Print",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          //validate
                          if (_formKey.currentState!.validate()) {
                            //send data to database with this method
                            _onSubmit();
                          }
                        },
                      ),
                    ],
                  ),
                  // ElevatedButton(
                  //     onPressed: () {
                  //       printer.disconnect();
                  //     },
                  //     child: const Text('Disconnect')),
                  // ElevatedButton(
                  //     onPressed: () {
                  //       printer.connect(selectedDevice!);

                  //       printer.printNewLine();
                  //       printer.printNewLine();
                  //       printer.printCustom('e_parkir_02', 3, 1);
                  //       printer.printNewLine();
                  //       printer.printNewLine();
                  //       printer.printCustom(plat_nomor.text, 2, 1);
                  //       printer.printNewLine();
                  //       printer.printCustom(jenis_kendaraan, 2, 1);
                  //       printer.printNewLine();
                  //       printer.printNewLine();
                  //       printer.printQRcode(
                  //           id_kendaraan.toString(), 200, 200, 1);
                  //       printer.printNewLine();
                  //       printer.printNewLine();
                  //       printer.printNewLine();
                  //     },
                  //     child: const Text('Print'))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
