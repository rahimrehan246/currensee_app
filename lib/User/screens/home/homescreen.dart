import 'package:curreny/User/screens/converter/converter_screen.dart';
import 'package:curreny/User/screens/exchange_rate/app_theme.dart';
import 'package:curreny/User/screens/exchange_rate/exchange_rate_screen.dart';
import 'package:curreny/User/screens/home/drawer.dart';
import 'package:curreny/User/screens/profile/profilescreen.dart';
import 'package:curreny/User/screens/statistics/statistics_screen.dart';
import 'package:flutter/material.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const ConverterScreen(),
    const ExchangeRateScreen(),
    const StatisticsScreen(),
    const ProfileSetupScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: AppColors.kNavBg, // 👈 Add this

  drawer: const PremiumDrawer(),

  body: IndexedStack(
    index: currentIndex,
    children: pages,
  ),

  bottomNavigationBar: PremiumBottomNavBar(
    currentIndex: currentIndex,
    onTap: (index) {
      setState(() {
        currentIndex = index;
      });
    },
  ),
);
   }
}