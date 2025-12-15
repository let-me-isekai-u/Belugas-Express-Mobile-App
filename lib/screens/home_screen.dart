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

  // Trong _HomeScreenState
  Widget _buildCustomAppBar(HomeModel model, AppLocalizations loc) {
    // Thay đổi gradient nhẹ nhàng và thêm hiệu ứng bo góc phía dưới
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue[700], // Giữ màu nền đậm
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20), // Padding trên lớn hơn
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // THÔNG TIN CHÀO MỪNG VÀ VÍ
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  loc.welcomeTitle,
                  style: const TextStyle(fontSize: 15, color: Colors.white70),
                ),
                Text(
                  "Beluga Express", 
                  style: const TextStyle(fontSize: 15, color: Colors.white70),
                ),
                const SizedBox(height: 4),

                // Tên người dùng
                model.isLoading
                    ? const SizedBox(
                  height: 28,
                  child: LinearProgressIndicator(color: Colors.white),
                )
                    : Text(
                  model.fullName ?? loc.defaultUserName,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 15),

                // Ví tiền (Được làm nổi bật hơn)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.account_balance_wallet, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        model.wallet != null
                            ? loc.walletLabel(model.wallet!.toStringAsFixed(0))
                            : loc.walletLabel('0'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Trong _HomeScreenState
  Widget _buildWelcome(AppLocalizations loc) {
    return Center(
      key: const ValueKey('welcome'),
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(seconds: 1), // Giảm thời gian animation cho mượt
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề Dashboard
              Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 15),
                child: Text(
                  loc.quickActionsTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),

              // Lưới các nút hành động nhanh
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.2, // Tỷ lệ chiều rộng/chiều cao
                  children: [
                    // 1. TẠO ĐƠN (Nút chính)
                    _buildActionButton(
                      context,
                      loc.createOrderButton,
                      Icons.add_location_alt_rounded,
                      Colors.blue.shade600,
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => CreateOrderScreen(accessToken: widget.accessToken)),
                        );
                      },
                    ),

                    // 2. NẠP TIỀN (Liên kết đến Tab 1)
                    _buildActionButton(
                      context,
                      loc.homeTabRecharge,
                      Icons.payments_rounded,
                      Colors.green.shade600,
                          () => _onItemTapped(1),
                    ),

                    // 3. ĐƠN HÀNG CỦA TÔI (Liên kết đến Tab 2)
                    _buildActionButton(
                      context,
                      loc.homeTabOrders,
                      Icons.list_alt,
                      Colors.orange.shade600,
                          () => _onItemTapped(2),
                    ),

                    // 4. LỊCH SỬ GIAO DỊCH (Liên kết đến Tab 3)
                    _buildActionButton(
                      context,
                      loc.homeTabTrade,
                      Icons.history,
                      Colors.purple.shade600,
                          () => _onItemTapped(3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Hàm mới: Widget cho các nút hành động nhanh
  Widget _buildActionButton(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }


  // Trong _HomeScreenState
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final tabs = [
      {'icon': Icons.home, 'label': loc.homeTabHome},
      {'icon': Icons.account_balance_wallet, 'label': loc.homeTabRecharge},
      {'icon': Icons.list_alt, 'label': loc.homeTabOrders},
      {'icon': Icons.receipt_long, 'label': loc.homeTabTrade},
      {'icon': Icons.person, 'label': loc.homeTabProfile},
    ];

    return Consumer<HomeModel>(builder: (context, model, _) {
      return Container(
        decoration: const BoxDecoration(
          // Giữ gradient nền cho toàn màn hình
          gradient: LinearGradient(
            colors: [Color(0xFFE3F0FF), Color(0xFFB3C6E7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent, // Nền trong suốt để thấy gradient
          appBar: null,
          body: _buildBody(model, loc),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2)),
              ],
              // Bỏ bo góc ở BottomNav để giao diện trông mượt mà hơn
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent, // Quan trọng: làm cho nó trong suốt
              elevation: 0,
              currentIndex: _selectedIndex >= tabs.length ? tabs.length - 1 : _selectedIndex,
              onTap: _onItemTapped,

              // Tối ưu màu sắc để hiện đại hơn
              selectedItemColor: theme.colorScheme.primary, // Màu chủ đạo (Xanh đậm)
              unselectedItemColor: Colors.grey.shade500,

              selectedIconTheme: const IconThemeData(size: 28),
              unselectedIconTheme: const IconThemeData(size: 24),

              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
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
