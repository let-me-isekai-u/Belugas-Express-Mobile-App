import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:begulas_express/models/home_model.dart';
import '../profile_screen.dart';
import 'package:begulas_express/screens/Contructor/order_status_screen.dart';

class ContractorHomeScreen extends StatefulWidget {
  const ContractorHomeScreen({Key? key}) : super(key: key);

  @override
  State<ContractorHomeScreen> createState() => _ContractorHomeScreenState();
}

class _ContractorHomeScreenState extends State<ContractorHomeScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<HomeModel>(context, listen: false).loadProfile(context);
    });
    _runFadeIn();
  }

  void _runFadeIn() {
    setState(() => _opacity = 0.0);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted && _selectedIndex == 0) {
        setState(() => _opacity = 1.0);
      }
    });
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
      if (index == 0) _runFadeIn();
    });
  }

  Widget _buildBody(HomeModel model) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: _selectedIndex == 0
          ? _buildWelcome()
          : _selectedIndex == 1
          ? OrderStatusScreen(
        tabBarBack: () {
          setState(() {
            _selectedIndex = 0;
            _runFadeIn();
          });
        },
      )
          : (model.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ProfileScreen(
        fullName: model.fullName ?? "Tên tài khoản",
        email: model.email ?? "N/A",
        phoneNumber: model.phoneNumber ?? "N/A",
      )),
    );
  }

  Widget _buildWelcome() {
    return Center(
      key: const ValueKey('welcome'),
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(seconds: 2),
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.blueGrey.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.flight_takeoff, size: 70, color: Colors.blue[400]),
              const SizedBox(height: 20),
              Text(
                "Welcome to Begulas Express!",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700]),
              ),
              const SizedBox(height: 10),
              Text(
                "Lựa chọn và cập nhật trạng thái đơn hàng khả dụng.",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
                onPressed: () {
                  setState(() => _selectedIndex = 1);
                },
                icon: const Icon(Icons.assignment),
                label: const Text(
                  "Xem đơn khả dụng",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final List<Map<String, dynamic>> _tabs = const [
    {'icon': Icons.home, 'label': 'Trang chủ'},
    {'icon': Icons.assignment, 'label': 'Đơn hàng'},
    {'icon': Icons.person, 'label': 'Tài khoản'},
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeModel>(
      builder: (context, model, _) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.blue[400],
              automaticallyImplyLeading: false,
              title: const Text(
                "Begulas Express",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              centerTitle: true,
            ),
            body: _buildBody(model),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: Colors.blue[400],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue[200]!.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.white70,
                selectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14),
                unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w400, fontSize: 13),
                items: _tabs
                    .map((tab) => BottomNavigationBarItem(
                  icon: Icon(tab['icon']),
                  label: tab['label'],
                ))
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
