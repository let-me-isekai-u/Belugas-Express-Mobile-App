import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:begulas_express/models/contructor_home_model.dart';

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

  Widget _buildBody() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: _selectedIndex == 0
          ? _buildWelcome()
          : _selectedIndex == 1
          ? _buildDeliveryList()
          : _selectedIndex == 2
          ? _buildHistory()
          : _buildProfile(),
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
                color: Colors.blueGrey.withValues(alpha: 0.15),
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
                "Lựa chọn và cập nhận trạng thái đơn hàng khả dụng.",
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
                onPressed: () => setState(() => _selectedIndex = 1),
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

  Widget _buildDeliveryList() {
    final statuses = [
      "Đang đợi lên máy",
      "Đang đợi lấy hàng",
      "Đã đến kho trung chuyển",
      "Đang giao",
      "Đã hoàn thành",
    ];
    return ListView.builder(
      key: const ValueKey('delivery'),
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, i) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            leading: const Icon(Icons.local_shipping, color: Colors.blue),
            title: Text("Đơn hàng #${1000 + i}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(statuses[i]),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[500],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {},
              child: const Text("Đổi trạng thái"),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistory() {
    return Center(
      key: const ValueKey('history'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 70, color: Colors.amber[700]),
          const SizedBox(height: 16),
          const Text(
            "Lịch sử giao hàng",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text("Theo dõi các chuyến giao đã hoàn thành của bạn."),
        ],
      ),
    );
  }

  // 🔗 Hàm mở link hỗ trợ
  Future<void> _launchSupport() async {
    final Uri url = Uri.parse('https://belugas-express.com/support');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildProfile() {
    return Center(
      key: const ValueKey('profile'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(radius: 50, backgroundColor: Colors.blueAccent),
          const SizedBox(height: 16),
          const Text("Lý Nhật Anh",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text("Nhà vận chuyển - Nước: Nhật Bản",
              style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 20),
          const Text("Số điện thoại: 0123 344 5567"),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _launchSupport,
            icon: const Icon(Icons.headset_mic),
            label: const Text("Liên hệ hỗ trợ"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding:
              const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  final List<Map<String, dynamic>> _tabs = const [
    {'icon': Icons.home, 'label': 'Trang chủ'},
    {'icon': Icons.assignment, 'label': 'Đơn hàng'},
    {'icon': Icons.history, 'label': 'Lịch sử'},
    {'icon': Icons.person, 'label': 'Tài khoản'},
  ];

  @override
  Widget build(BuildContext context) {
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
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          title: const Text(
            "Belugas Express - Nhà vận chuyển",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          centerTitle: true,
        ),
        body: _buildBody(),
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
            selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
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
  }
}
