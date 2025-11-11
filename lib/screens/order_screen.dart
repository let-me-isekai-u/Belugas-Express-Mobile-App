import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/order_model.dart';
import '../services/api_service.dart';
import 'order_detail_screen.dart';
import '../l10n/app_localizations.dart';

// Sử dụng statusTabs có text động từ localization
List<Map<String, dynamic>> getStatusTabs(AppLocalizations loc) => [
  {"id": 0, "name": loc.orderStatusAll},
  {"id": 1, "name": loc.orderStatusPickup},
  {"id": 2, "name": loc.orderStatusInTransitToHub},
  {"id": 3, "name": loc.orderStatusAtHub},
  {"id": 4, "name": loc.orderStatusAwaitingPayment},
  {"id": 5, "name": loc.orderStatusAwaitingShipment},
  {"id": 6, "name": loc.orderStatusShipping},
  {"id": 7, "name": loc.orderStatusDelivered},
  {"id": 8, "name": loc.orderStatusCancelled},
];

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> with SingleTickerProviderStateMixin {
  late Future<List<Order>> _futureOrders;
  Timer? _pollingTimer;
  double _walletBalance = 0.0;
  int _userId = 0;
  String _accessToken = '';
  final Set<int> _processingOrderIds = {};
  late TabController _tabController;
  late List<Map<String, dynamic>> _statusTabs;

  @override
  void initState() {
    super.initState();
    // Khởi tạo mảng _statusTabs với tên rỗng, sẽ fill lại bằng loc trong build
    _statusTabs = [
      {"id": 0, "name": ""},
      {"id": 1, "name": ""},
      {"id": 2, "name": ""},
      {"id": 3, "name": ""},
      {"id": 4, "name": ""},
      {"id": 5, "name": ""},
      {"id": 6, "name": ""},
      {"id": 7, "name": ""},
      {"id": 8, "name": ""},
    ];
    _tabController = TabController(length: _statusTabs.length, vsync: this);
    _futureOrders = _loadOrders();
    _loadProfileMeta();
    _fetchWallet();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileMeta() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("accessToken") ?? "";
    _accessToken = token;
    _userId = prefs.getInt("id") ?? 0;
    if (token.isEmpty) return;

    try {
      final res = await ApiService.getProfile(accessToken: token);
      if (res.statusCode == 200) {
        final parsed = jsonDecode(res.body);
        if (!mounted) return;
        setState(() {
          _walletBalance = (parsed['wallet'] is num) ? (parsed['wallet'] as num).toDouble() : 0.0;
        });
      }
    } catch (e) {
      debugPrint("Lỗi khi load profile meta: $e");
    }
  }

  Future<void> _fetchWallet() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("accessToken") ?? _accessToken;
    if (token.isEmpty) {
      return;
    }
    try {
      final res = await ApiService.getWalletBalance(accessToken: token);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body is Map && (body['success'] == true || body.containsKey('wallet'))) {
          final w = body['wallet'];
          if (w is num) {
            if (!mounted) return;
            setState(() {
              _walletBalance = w.toDouble();
              _accessToken = token;
            });
          } else if (w is String) {
            final parsed = double.tryParse(w);
            if (parsed != null && mounted) {
              setState(() => _walletBalance = parsed);
            }
          }
        } else {
          debugPrint("getWalletBalance unexpected body: ${res.body}");
        }
      } else if (res.statusCode == 401) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.orderExpiredSession)),
          );
        }
      } else {
        debugPrint("getWalletBalance failed: ${res.statusCode} ${res.body}");
      }
    } catch (e) {
      debugPrint("Error fetching wallet: $e");
    }
  }

  Future<List<Order>> _loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("accessToken") ?? "";
    final response = await ApiService.getOrders(accessToken: token);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception("Error loading orders (${response.statusCode})");
    }
  }

  String _fmtMoney(BuildContext context, num v) {
    return "${v.toStringAsFixed(0)} đ";
  }

  void _showStatusNote(BuildContext context, Order order) {
    if (order.statusNote == null) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(order.statusText),
        content: Text(order.statusNote!),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.orderQrCloseButton)),
        ],
      ),
    );
  }

  void _showQrDialog(Order order) {
    final loc = AppLocalizations.of(context)!;
    final total = order.total;
    final downPayment = order.downPayment;
    final toPay = total - downPayment;
    final now = DateTime.now();
    final timestamp =
        "${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}";
    final description = "${_userId}$timestamp";
    final qrUrl =
        "https://img.vietqr.io/image/MB-34567200288888-compact2.png?amount=${toPay.toStringAsFixed(0)}&addInfo=${description}&accountName=LY%20NHAT%20ANH";

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(loc.orderQrTitle,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blue)),
              const SizedBox(height: 16),
              Image.network(qrUrl, height: 240, width: 240, fit: BoxFit.contain, errorBuilder: (ctx, err, st) {
                return const SizedBox(height: 240, width: 240, child: Center(child: Icon(Icons.broken_image)));
              }),
              const SizedBox(height: 10),
              Text(loc.orderQrAmount(toPay.toStringAsFixed(0)),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(loc.orderQrContent(description), style: const TextStyle(color: Colors.orange)),
              const SizedBox(height: 5),
              Text(
                "After transfer, the system will check automatically.\nPlease do not close the screen before confirmation.",
                style: const TextStyle(fontSize: 13, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.red),
                label: Text(loc.orderQrCloseButton, style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _attemptWalletPayment(Order order) async {
    await _fetchWallet();

    final toPay = order.total - order.downPayment;
    final loc = AppLocalizations.of(context)!;

    if (_walletBalance < toPay) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.orderInsufficientWallet), backgroundColor: Colors.red),
        );
      }
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("accessToken") ?? _accessToken;
    if (token.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.orderExpiredSession), backgroundColor: Colors.red),
        );
      }
      return;
    }

    setState(() => _processingOrderIds.add(order.id));
    try {
      final res = await ApiService.confirmOrderPayment(accessToken: token, orderId: order.id);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map && (data['success'] == true || data['newStatus'] != null)) {
          final orderId = data['orderId'] ?? order.id;
          if (mounted) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text(loc.orderPaymentSuccess),
                content: Text(data['message']?.toString() ?? loc.orderPaymentSuccess),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: orderId)),
                      );
                    },
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
          }
          _futureOrders = _loadOrders();
          if (mounted) setState(() {});
          return;
        } else {
          final msg = (data is Map && data['message'] != null)
              ? data['message'].toString()
              : "Order confirmation failed.";
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.orange));
          }
        }
      } else if (res.statusCode == 111) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.orderInsufficientWallet), backgroundColor: Colors.red),
          );
        }
      } else if (res.statusCode == 222) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Order not in status 4"), backgroundColor: Colors.orange),
          );
        }
      } else if (res.statusCode == 401) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.orderExpiredSession), backgroundColor: Colors.red),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error confirming order: ${res.statusCode}"), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      debugPrint("Error confirming order payment: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Connection error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _processingOrderIds.remove(order.id));
    }
  }

  Widget _buildOrderTile(Order o, AppLocalizations loc) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: o.id)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(o.statusIcon, color: o.statusColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(o.statusText,
                      style: TextStyle(fontWeight: FontWeight.bold, color: o.statusColor),
                      overflow: TextOverflow.ellipsis),
                ),
                if (o.statusNote != null)
                  IconButton(
                    onPressed: () => _showStatusNote(context, o),
                    icon: Icon(Icons.info_outline, color: o.statusColor, size: 18),
                    tooltip: loc.orderStatusDetailButton,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(loc.orderCodeLabel(o.orderCode), style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 4),
            Text(loc.orderSenderLabel(o.senderName, o.senderPhone), overflow: TextOverflow.ellipsis),
            Text(loc.orderReceiverLabel(o.receiverName), overflow: TextOverflow.ellipsis),
            Text(loc.orderAddressLabel(o.receiverAddress), overflow: TextOverflow.ellipsis),
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(loc.orderTotalLabel(_fmtMoney(context, o.total)),
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                ),
                Expanded(
                  child: Text(loc.orderDownPaymentLabel(_fmtMoney(context, o.downPayment)),
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (o.status == 4 && o.downPayment < o.total)
              Align(
                alignment: Alignment.centerRight,
                child: _processingOrderIds.contains(o.id)
                    ? const SizedBox(
                  height: 36,
                  width: 36,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => _attemptWalletPayment(o),
                  icon: const Icon(Icons.payment),
                  label: Text(
                    loc.orderPaymentButton(_fmtMoney(context, o.total - o.downPayment)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildListForStatus(int status, List<Order> orders, AppLocalizations loc) {
    final filtered = status == 0 ? orders : orders.where((o) => o.status == status).toList();
    if (filtered.isEmpty) {
      return Center(child: Text(loc.orderNoOrders));
    }

    return RefreshIndicator(
      onRefresh: () async {
        _futureOrders = _loadOrders();
        setState(() {});
        await _futureOrders;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (context, index) => _buildOrderTile(filtered[index], loc),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    // fill lại text tab mỗi lần build (theo locale mới)
    final statusNames = [
      loc.orderStatusAll,
      loc.orderStatusPickup,
      loc.orderStatusInTransitToHub,
      loc.orderStatusAtHub,
      loc.orderStatusAwaitingPayment,
      loc.orderStatusAwaitingShipment,
      loc.orderStatusShipping,
      loc.orderStatusDelivered,
      loc.orderStatusCancelled,
    ];

    for (int i = 0; i < _statusTabs.length; i++) {
      _statusTabs[i]['name'] = statusNames[i];
    }

    return DefaultTabController(
      length: _statusTabs.length,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6FAFF),
        appBar: AppBar(
          backgroundColor: Colors.blue[300],
          title: Text(loc.orderTitle),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: Colors.orange,
            labelColor: Colors.orange,
            unselectedLabelColor: Colors.white,
            tabs: _statusTabs.map((s) => Tab(child: Text(s["name"], style: const TextStyle(fontSize: 13)))).toList(),
          ),
        ),
        body: FutureBuilder<List<Order>>(
          future: _futureOrders,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData) {
              return Center(child: Text(loc.orderNoOrders));
            }
            final orders = snapshot.data!;
            return TabBarView(
              controller: _tabController,
              children: _statusTabs.map((s) {
                final statusId = s["id"] as int;
                return _buildListForStatus(statusId, orders, loc);
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}