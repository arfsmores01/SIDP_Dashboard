import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'analysis_page.dart';
import 'about_page.dart';
import '../../widgets/menu_section.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    DashboardPage(),
    AnalysisPage(),
    AboutPage(),
  ];

  void onSelectPage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: MenuSection(onSelect: onSelectPage),
    );
  }
}