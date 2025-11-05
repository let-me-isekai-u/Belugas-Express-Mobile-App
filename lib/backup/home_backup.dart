import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../screens/create_order_screen.dart';
import '../screens/order_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/trade_screen.dart';

class HomeScreen extends StatefulWidget {
  final String accessToken;
  const HomeScreen({Key? key, required this.accessToken}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  double _opacity = 0.0;

  String? _fullName;
  String? _email;
  String? _phoneNumber;
  double? _wallet;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    _runFadeIn();
  }

  Future<void> _fetchProfile() async {
    try {
      final res = await ApiService.getProfile(accessToken: widget.accessToken);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _fullName = data['fullName'];
          _email = data['email'];
          _phoneNumber = data['phoneNumber'];
          _wallet = (data['wallet'] as num?)?.toDouble();
          _isLoadingProfile = false;
        });
      } else {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    } catch (_) {
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  void _runFadeIn() {
    setState(() {
      _opacity = 0.0;
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted && _selectedIndex == 0) {
        setState(() {
          _opacity = 1.0;
        });
      }
    });
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        _runFadeIn();
      }
    });
  }

  Widget _buildBody() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _selectedIndex == 0
          ? _buildWelcome()
          : _selectedIndex == 1
          ? const CreateOrderScreen()
          : _selectedIndex == 2
          ? const OrderScreen()
          : _selectedIndex == 3
          ? TradeScreen(accessToken: widget.accessToken)
          : (_isLoadingProfile
          ? const Center(child: CircularProgressIndicator())
          : ProfileScreen(
        fullName: _fullName ?? "Tên tài khoản",
        email: _email ?? "N/A",
        phoneNumber: _phoneNumber ?? "N/A",
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
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.15),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_shipping, size: 60, color: Colors.blue[400]),
              const SizedBox(height: 20),
              Text(
                "Welcome to",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue[300],
                  fontFamily: 'Serif',
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Begulas Express",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                  fontFamily: 'Serif',
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "Chào mừng bạn đã đến với ứng dụng giao nhận quốc tế Begulas Express.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> get _tabs => [
    {
      'icon': Icons.home,
      'label': 'Trang chủ',
    },
    {
      'icon': Icons.add_circle,
      'label': 'Tạo đơn',
    },
    {
      'icon': Icons.list_alt,
      'label': 'Đơn hàng',
    },
    {
      'icon': Icons.receipt_long,
      'label': 'Giao dịch',
    },
    {
      'icon': Icons.person,
      'label': 'Tài khoản',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFB3C6E7), Color(0xFFE3F0FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            automaticallyImplyLeading: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _isLoadingProfile
                    ? const SizedBox(height: 28, child: LinearProgressIndicator())
                    : Text(
                  _fullName ?? "Tên tài khoản",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                _isLoadingProfile
                    ? Container()
                    : Text(
                  _wallet != null
                      ? "Ví: ${_wallet!.toStringAsFixed(0)} VND"
                      : "Ví: N/A",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
        body: _buildBody(),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.blue[300],
            boxShadow: [
              BoxShadow(
                color: Colors.blue[200]!.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, -2),
              ),
            ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(22),
              topRight: Radius.circular(22),
            ),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedIconTheme: const IconThemeData(size: 32),
            unselectedIconTheme: const IconThemeData(size: 26),
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
            items: _tabs
                .map(
                  (tab) => BottomNavigationBarItem(
                icon: Icon(tab['icon']),
                label: tab['label'],
              ),
            )
                .toList(),
          ),
        ),
      ),
    );
  }
}
