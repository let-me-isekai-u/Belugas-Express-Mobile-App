import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/home_model.dart';
import '../screens/create_order_screen.dart';
import '../screens/order_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/trade_screen.dart';
import '../screens/recharge_screen.dart';
import '../route_observer.dart';

class HomeScreen extends StatefulWidget {
  final String accessToken;
  final void Function(Locale)? onLocaleChange;

  const HomeScreen({Key? key, required this.accessToken, this.onLocaleChange}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin, RouteAware {
  int _selectedIndex = 0;
  double _opacity = 0.0;
  Locale _locale = const Locale('vi');

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<HomeModel>(context, listen: false).loadProfile(context);
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

  @override
  void didPopNext() {
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
        Provider.of<HomeModel>(context, listen: false).fetchWallet(context: context);
      }
    });
  }

  Widget _buildBody(HomeModel model, AppLocalizations loc) {
    if (_selectedIndex == 0) {
      return Column(
        children: [
          _buildCustomAppBar(model, loc),
          Expanded(child: _buildWelcome(loc)),
        ],
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _selectedIndex == 1
          ? RechargeScreen(accessToken: widget.accessToken)
          : _selectedIndex == 2
          ? const OrderScreen()
          : _selectedIndex == 3
          ? TradeScreen(accessToken: widget.accessToken)
          : _selectedIndex == 4
          ? (model.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Builder(
        builder: (context) => ProfileScreen(
          key: ValueKey(Localizations.localeOf(context)),
          fullName: model.fullName ?? loc.defaultUserName,
          email: model.email ?? "N/A",
          phoneNumber: model.phoneNumber ?? "N/A",
          onLocaleChange: (locale) {
            widget.onLocaleChange?.call(locale);
          },
        ),
      ))
          : const SizedBox.shrink(),
    );
  }

  Widget _buildCustomAppBar(HomeModel model, AppLocalizations loc) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 40, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                model.isLoading
                    ? const SizedBox(height: 28, child: LinearProgressIndicator(color: Colors.white))
                    : Text(
                  model.fullName ?? loc.defaultUserName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                if (!model.isLoading)
                  Text(
                    model.wallet != null ? loc.walletLabel(model.wallet!.toStringAsFixed(0)) : loc.walletLabel('N/A'),
                    style: const TextStyle(fontSize: 15, color: Colors.white70),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcome(AppLocalizations loc) {
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
              BoxShadow(color: Colors.blue.withOpacity(0.15), blurRadius: 18, offset: const Offset(0, 8)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Text(
                loc.welcomeTitle,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.blue[300], fontFamily: 'Serif'),
              ),
              const SizedBox(height: 10),
              Text(
                loc.welcomeAppName,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue[700], fontFamily: 'Serif', letterSpacing: 1.2),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                loc.welcomeMessage,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // Nút được đổi tên:
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => CreateOrderScreen(accessToken: widget.accessToken)));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 3,
                ),
                child: Text(
                  loc.createOrderButton,
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final tabs = [
      {'icon': Icons.home, 'label': loc.homeTabHome},
      {'icon': Icons.account_balance_wallet, 'label': loc.homeTabRecharge},
      // Tab tạo đơn đã bị xoá theo yêu cầu
      // **Sửa lỗi**: không dùng _selectedIndex = 2 để mở màn tạo đơn nữa, thay bằng push để tránh mất trạng thái tab bar.
      {'icon': Icons.list_alt, 'label': loc.homeTabOrders},
      {'icon': Icons.receipt_long, 'label': loc.homeTabTrade},
      {'icon': Icons.person, 'label': loc.homeTabProfile},
    ];

    return Consumer<HomeModel>(builder: (context, model, _) {
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
          appBar: null,
          body: _buildBody(model, loc),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.blue[300],
              boxShadow: [
                BoxShadow(color: Colors.blue[200]!.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, -2)),
              ],
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22)),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedIconTheme: const IconThemeData(size: 32),
              unselectedIconTheme: const IconThemeData(size: 26),
              currentIndex: _selectedIndex >= tabs.length ? tabs.length - 1 : _selectedIndex,
              onTap: _onItemTapped,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white70,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
              items: tabs
                  .map(
                    (tab) => BottomNavigationBarItem(
                  icon: Icon(tab['icon'] as IconData),
                  label: tab['label'] as String,
                ),
              )
                  .toList(),
            ),
          ),
        ),
      );
    });
  }
}
