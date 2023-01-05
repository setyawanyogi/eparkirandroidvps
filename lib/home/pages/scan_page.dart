import 'dart:io';

import 'package:e_parkir_02/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:e_parkir_02/home/home_page.dart';
import 'package:e_parkir_02/home/pages/parkir_page.dart';
import 'package:e_parkir_02/home/pages/crud/add.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class ScanPage extends StatefulWidget {
  ScanPage({Key? key}) : super(key: key);

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage>
    with AutomaticKeepAliveClientMixin {
  BlueThermalPrinter printer = BlueThermalPrinter.instance;
  List<BluetoothDevice> devices = [];
  BluetoothDevice? selectedDevice;
  final qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? barcode;
  QRViewController? controller;

  void getDevices() async {
    devices = await printer.getBondedDevices();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    //in first time, this method will be executed
    _getData();
    getDevices();
    _onUpdate();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() async {
    super.reassemble();

    if (Platform.isAndroid) {
      await controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  Future _getData() async {
    try {
      final response = await http.get(Uri.parse(
          //you have to take the ip address of your computer.
          //because using localhost will cause an error
          //get detail data with id
          //"http://10.0.2.2/eparkirlogin/parkir/detail.php?id_parkir='${barcode!.code}'"));
          "https://login.schoolmedia.id/yogi/eparkir/parkir/detail.php?id_parkir='${barcode!.code}'"));

      // if response successful
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {});
      }
    } catch (e) {
      print(e);
    }
  }

  Future _onUpdate() async {
    try {
      return await http.post(
        //Uri.parse("http://10.0.2.2/eparkirlogin/parkir/update.php"),
        Uri.parse(
            "https://login.schoolmedia.id/yogi/eparkir/parkir/update.php?id_parkir='${barcode!.code}'"),
        body: {
          // "id": widget.id,
          // "title": title.text,
          // "content": content.text,
        },
      ).then((value) {
        //print message after insert to database
        //you can improve this message with alert dialog
        var data = jsonDecode(value.body);
        print(data["message"]);
        // showDialog(
        //     context: context,
        //     builder: (BuildContext context) => AlertDialog(
        //           // title: Text('${data["plat_nomor"]}'),
        //           title: Text(data["plat_nomor"]),
        //           content: Text(data["status"]),
        //         ));

        printer.connect(selectedDevice!);
        printer.printNewLine();
        printer.printNewLine();
        printer.printCustom('E-PARKIR', 3, 1);
        printer.printNewLine();
        printer.printNewLine();
        printer.printCustom(data["plat_nomor"], 2, 1);
        printer.printCustom(data["jenis_kendaraan"], 2, 1);
        printer.printNewLine();
        printer.print3Column("Datang:", data["jam_masuk"], "", 1);
        printer.print3Column("Keluar:", data["jam_keluar"], "", 1);
        printer.print3Column("Tanggal:", data["tgl"], "", 1);
        printer.print3Column("Status:", data["status"], "", 1);
        printer.print3Column("Harga:", data["biaya"], "", 1);

        printer.printNewLine();
        // printer.printNewLine();
        // printer.printQRcode(data["id_parkir"].toString(), 200, 200, 1);
        printer.printNewLine();
        printer.printNewLine();
        printer.paperCut();
        // printer.disconnect();

        Navigator.push(context,
            new MaterialPageRoute(builder: (context) => new HomePage()));

        // Navigator.of(context)
        //   .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
      });
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
        title: Text("Scan QR"),
        backgroundColor: Colors.orange,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          buildQRView(context),
          //Positioned(bottom: 10, child: buildResult()),
          Positioned(top: 10, child: buildControlButtons()),
          Positioned(
            bottom: 50,
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(color: Colors.white24),
              child: DropdownButton<BluetoothDevice>(
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
            ),
          ),
          Positioned(
              bottom: 10,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    printer.connect(selectedDevice!);
                  },
                  child: const Text('Connect & Print'))),
        ],
      ),
      // body: ListView.builder(
      //   itemCount: 500,
      //   itemBuilder:(context, index){
      //     return Card(
      //       color: index % 2 == 0? Colors.purple : null,
      //       child: Padding(
      //         padding: const EdgeInsets.all(16.0),
      //         child: Column(
      //           children: <Widget>[
      //             Text('Title of Parkir ${index+1}',
      //             style:
      //               TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
      //               color: index % 2 == 0? Colors.white : null,),
      //               ),
      //             SizedBox(
      //               height: 10,
      //             ),
      //             Text('Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'),
      //             ],
      //         ),
      //       ),
      //     );
      //   },
      //   ),
    );
  }

  Widget buildControlButtons() => Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: FutureBuilder<bool?>(
                future: controller?.getFlashStatus(),
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    return Icon(
                        snapshot.data! ? Icons.flash_on : Icons.flash_off);
                  } else {
                    return Container();
                  }
                },
              ),
              onPressed: () async {
                await controller?.toggleFlash();
                setState(() {});
              },
            ),
            IconButton(
              icon: FutureBuilder(
                future: controller?.getCameraInfo(),
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    return Icon(Icons.switch_camera);
                  } else {
                    return Container();
                  }
                },
              ),
              onPressed: () async {
                await controller?.flipCamera();
                setState(() {});
              },
            ),
          ],
        ),
      );

  Widget buildResult() => Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white24),
        child: Text(
          barcode != null ? 'Result : ${barcode!.code}' : 'Scan a Code!',
          maxLines: 3,
        ),
      );

  Widget buildQRView(BuildContext context) => QRView(
        key: qrKey,
        onQRViewCreated: onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Colors.orange,
          borderWidth: 10,
          borderRadius: 10,
          borderLength: 20,
          cutOutSize: MediaQuery.of(context).size.width * 0.8,
        ),
      );

  void onQRViewCreated(QRViewController controller) {
    setState(() => this.controller = controller);
    //      setState(() {
    //   _onUpdate(context);
    // });

    controller.scannedDataStream.listen((barcode) {
      setState(() => this.barcode = barcode);
      _onUpdate();
      reassemble();
      printer.paperCut();

      // Navigator.push(context,
      //       new MaterialPageRoute(builder: (context) => new HomePage()));
    });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
