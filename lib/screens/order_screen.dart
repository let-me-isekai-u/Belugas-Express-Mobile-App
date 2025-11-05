import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../models/order_model.dart';
import '../services/api_service.dart';
import 'order_detail_screen.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  late Future<List<Order>> _futureOrders;
  Timer? _pollingTimer;
  double _walletBalance = 0.0;
  int _userId = 0;

  @override
  void initState() {
    super.initState();
    _futureOrders = _loadOrders();
    _loadProfileMeta();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadProfileMeta() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("accessToken") ?? "";
    _userId = prefs.getInt("id") ?? 0;
    if (token.isEmpty) return;

    final res = await ApiService.getProfile(accessToken: token);
    if (res.statusCode == 200) {
      final parsed = jsonDecode(res.body);
      setState(() {
        _walletBalance = (parsed['wallet'] is num) ? (parsed['wallet'] as num).toDouble() : 0.0;
      });
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
      throw Exception("Lỗi tải đơn hàng (${response.statusCode})");
    }
  }

  Future<void> _handlePayment(BuildContext context, Order order) async {
    final remaining = order.remainingVsDownPayment;
    if (remaining <= 0) return;

    double extraWalletUsed = 0.0;
    bool useWallet = false;
    await _loadProfileMeta();

    final now = DateTime.now();
    final timestamp = "${now.hour.toString().padLeft(2, '0')}"
        "${now.minute.toString().padLeft(2, '0')}"
        "${now.second.toString().padLeft(2, '0')}";
    final description = "${_userId}${timestamp}";

    void openDialog() {
      _pollingTimer?.cancel();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => StatefulBuilder(
          builder: (context, setStateDialog) {
            final maxWalletCanUse = useWallet ? (_walletBalance < remaining ? _walletBalance : remaining) : 0.0;
            if (extraWalletUsed > maxWalletCanUse) {
              extraWalletUsed = maxWalletCanUse;
            }

            final amountForQr = (remaining - extraWalletUsed);
            final qrUrl =
                "https://img.vietqr.io/image/MB-34567200288888-compact2.png?amount=${amountForQr.toStringAsFixed(0)}&addInfo=${Uri.encodeComponent(description)}&accountName=LY%20NHAT%20ANH";

            if (amountForQr <= 0) {
              Future.microtask(() {
                Navigator.pop(context);
                setState(() {
                  _futureOrders = _loadOrders();
                });
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: order.id)),
                );
              });
            } else {
              _startPolling(description, amountForQr, onMatched: () {
                _pollingTimer?.cancel();
                Navigator.pop(context);
                setState(() {
                  _futureOrders = _loadOrders();
                });
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: order.id)),
                );
              });
            }

            return AlertDialog(
              title: const Text("Thanh toán bổ sung"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: useWallet,
                        onChanged: (v) {
                          setStateDialog(() {
                            useWallet = v ?? false;
                            if (!useWallet) extraWalletUsed = 0.0;
                          });
                        },
                      ),
                      const Text("Dùng ví"),
                      const SizedBox(width: 8),
                      if (useWallet)
                        Text(
                          "Số dư: ${_walletBalance.toStringAsFixed(0)} đ",
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                  if (useWallet)
                    Slider(
                      value: extraWalletUsed,
                      min: 0.0,
                      max: maxWalletCanUse > 0 ? maxWalletCanUse : 0.0,
                      divisions: (maxWalletCanUse > 0 ? maxWalletCanUse : 1).toInt(),
                      label: extraWalletUsed.toStringAsFixed(0),
                      onChanged: (v) {
                        setStateDialog(() {
                          extraWalletUsed = v;
                        });
                      },
                    ),
                  const SizedBox(height: 12),
                  Text("Cần thanh toán: ${amountForQr.toStringAsFixed(0)} đ",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (amountForQr > 0)
                    Image.network(qrUrl, height: 200, fit: BoxFit.contain),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _pollingTimer?.cancel();
                    Navigator.pop(context);
                  },
                  child: const Text("Hủy"),
                ),
              ],
            );
          },
        ),
      );
    }

    openDialog();
  }

  void _startPolling(String description, double amountForQr, {required VoidCallback onMatched}) {
    _pollingTimer?.cancel();
    Future.delayed(const Duration(seconds: 5), () {
      _pollingTimer?.cancel();
      _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
        final res = await http.get(Uri.parse(
            "https://script.google.com/macros/s/AKfycbyB5JISCpIjFJp9ikNS00RP34ywViepMogpyjAXaLgimbYkqSFb2KiY5APofTMW2arP_A/exec"));
        if (res.statusCode == 200) {
          try {
            final body = jsonDecode(res.body);
            final List txs = body["data"] ?? [];
            for (var tx in txs) {
              final double txAmount = (tx["values_0_2"] is num)
                  ? (tx["values_0_2"] as num).toDouble()
                  : double.tryParse(tx["values_0_2"]?.toString() ?? "") ?? 0.0;
              final String txDesc = tx["values_0_9"].toString();

              if (txAmount == amountForQr && txDesc.contains(description)) {
                _pollingTimer?.cancel();
                onMatched();
                return;
              }
            }
          } catch (_) {}
        }
      });
    });
  }

  String _fmtMoney(num v) => "${v.toStringAsFixed(0)} đ";

  void _showStatusNote(BuildContext context, Order order) {
    if (order.statusNote == null) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(order.statusText),
        content: Text(order.statusNote!),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Đóng")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFF),
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
        title: const Text("Danh sách đơn hàng"),
      ),
      body: FutureBuilder<List<Order>>(
        future: _futureOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Không có đơn hàng."));
          }

          final orders = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final o = orders[index];
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
                      Row(children: [
                        Icon(o.statusIcon, color: o.statusColor),
                        const SizedBox(width: 8),
                        Text(o.statusText,
                            style: TextStyle(fontWeight: FontWeight.bold, color: o.statusColor)),
                        if (o.statusNote != null)
                          IconButton(
                            onPressed: () => _showStatusNote(context, o),
                            icon: Icon(Icons.info_outline, color: o.statusColor, size: 18),
                          ),
                      ]),
                      const SizedBox(height: 4),
                      Text("Mã đơn: ${o.orderCode}", style: const TextStyle(fontSize: 15)),
                      const SizedBox(height: 4),
                      Text("Người gửi: ${o.senderName} (${o.senderPhone})"),
                      Text("Người nhận: ${o.receiverName}"),
                      Text("Địa chỉ: ${o.receiverAddress}"),
                      const Divider(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Tổng: ${_fmtMoney(o.total)}"),
                          Text("Cọc: ${_fmtMoney(o.displayedDownPayment)}"),
                        ],
                      ),
                      if (o.canShowPayButton)
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => _handlePayment(context, o),
                            icon: const Icon(Icons.payment),
                            label: Text("Thanh toán ${_fmtMoney(o.remainingVsDownPayment)}"),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
