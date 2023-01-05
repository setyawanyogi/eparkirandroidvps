import 'package:e_parkir_02/home/pages/keluar.dart';
import 'package:e_parkir_02/home/pages/selesai.dart';
import 'package:e_parkir_02/home/pages/parkir.dart';
import 'package:e_parkir_02/home/pages/parkir_page.dart';
import 'package:e_parkir_02/home/pages/petugas_page.dart';
import 'package:e_parkir_02/home/pages/scan_page.dart';
import 'package:e_parkir_02/home/pages/tambah_page.dart';
import 'package:e_parkir_02/login/login.dart';
import 'package:e_parkir_02/home/home_page.dart';
import 'package:e_parkir_02/home/home.dart';
import 'package:e_parkir_02/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  //  final String id_user;

  //  const HomePage({Key? key, required this.id_user}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController _pageController = PageController();
  List<Widget> _screens = [Parkir(), ScanPage(), Selesai(), PetugasPage()];
  int _selectedIndex = 0;
  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _itemTapped(int selectedIndex) {
    _pageController.jumpToPage(selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _screens,
        onPageChanged: _onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: _itemTapped,
        selectedItemColor: Colors.orange,
        currentIndex: _selectedIndex,
        backgroundColor: Colors.white,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.local_parking,
            ),
            label: 'Parkir',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.qr_code_scanner,
            ),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.fact_check,
            ),
            label: 'Keluar',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.people_alt,
            ),
            label: 'Petugas',
          ),
        ],
      ),
    );
  }
}
