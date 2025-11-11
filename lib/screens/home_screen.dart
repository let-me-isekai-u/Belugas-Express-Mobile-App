import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/home_model.dart';
import '../screens/create_order_screen.dart';
import '../screens/order_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/trade_screen.dart';
import '../screens/recharge_screen.dart';
import '../route_observer.dart';

class HomeScreen extends StatefulWidget {
  final String accessToken;
  const HomeScreen({Key? key, required this.accessToken}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, RouteAware {
  int _selectedIndex = 0;
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Load profile (keeps previous behavior)
    Future.microtask(() {
      Provider.of<HomeModel>(context, listen: false).loadProfile(context);
      // Ensure wallet is refreshed right after entering Home (e.g. just after login)
      Provider.of<HomeModel>(context, listen: false).fetchWallet(context: context);
    });
    _runFadeIn();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute != null) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // Called when returning to this route (another route was popped)
  @override
  void didPopNext() {
    // Refresh profile and wallet whenever user comes back to Home
    Provider.of<HomeModel>(context, listen: false).loadProfile(context);
    Provider.of<HomeModel>(context, listen: false).fetchWallet(context: context);
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

  void _onItemTapped(int index) async {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        _runFadeIn();
        Provider.of<HomeModel>(context, listen: false).loadProfile(context);
        // Refresh wallet when user taps Home tab
        Provider.of<HomeModel>(context, listen: false).fetchWallet(context: context);
      }
    });
  }

  Widget _buildBody(HomeModel model) {
    if (_selectedIndex == 0) {
      return Column(
        children: [
          _buildCustomAppBar(model),
          Expanded(child: _buildWelcome()),
        ],
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _selectedIndex == 1
          ? RechargeScreen(accessToken: widget.accessToken) // màn hình nạp tiền
          : _selectedIndex == 2
          ? const CreateOrderScreen()
          : _selectedIndex == 3
          ? const OrderScreen()
          : _selectedIndex == 4
          ? TradeScreen(accessToken: widget.accessToken)
          : _selectedIndex == 5
          ? (model.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ProfileScreen(
        fullName: model.fullName ?? "Tên tài khoản",
        email: model.email ?? "N/A",
        phoneNumber: model.phoneNumber ?? "N/A",
      ))
          : const SizedBox.shrink(),
    );
  }

  Widget _buildCustomAppBar(HomeModel model) {
    return Container(
      width: double.infinity, // Kéo ngang hết màn hình
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 40, bottom: 16),
      child: Align(
        alignment: Alignment.centerLeft, // Căn hết về bên trái
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            model.isLoading
                ? const SizedBox(
              height: 28,
              child: LinearProgressIndicator(color: Colors.white),
            )
                : Text(
              model.fullName ?? "Tên tài khoản",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            if (!model.isLoading)
              Text(
                model.wallet != null
                    ? "Ví: ${model.wallet!.toStringAsFixed(0)} VND"
                    : "Ví: N/A",
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white70,
                ),
              ),
          ],
        ),
      ),
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
                "Beluga Express",
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
                "Chào mừng bạn đã đến với ứng dụng giao nhận quốc tế Beluga Express.",
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
    {'icon': Icons.home, 'label': 'Trang chủ'},
    {'icon': Icons.account_balance_wallet, 'label': 'Nạp tiền'},
    {'icon': Icons.add_circle, 'label': 'Tạo đơn'},
    {'icon': Icons.list_alt, 'label': 'Đơn hàng'},
    {'icon': Icons.receipt_long, 'label': 'Giao dịch'},
    {'icon': Icons.person, 'label': 'Tài khoản'},
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeModel>(
      builder: (context, model, _) {
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
            // Ẩn AppBar mặc định, chỉ dùng AppBar custom ở Home tab
            appBar: null,
            body: _buildBody(model),
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
                selectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.bold),
                unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.w400),
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