import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String _accessToken = '';
  final Set<int> _processingOrderIds = {};

  @override
  void initState() {
    super.initState();
    _futureOrders = _loadOrders();
    _loadProfileMeta();
    // Always fetch wallet on entering this screen
    _fetchWallet();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
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
        // Expecting { "success": true, "wallet": 123000 }
        if (body is Map && (body['success'] == true || body.containsKey('wallet'))) {
          final w = body['wallet'];
          if (w is num) {
            setState(() {
              _walletBalance = w.toDouble();
              _accessToken = token;
            });
          } else if (w is String) {
            final parsed = double.tryParse(w);
            if (parsed != null) {
              setState(() => _walletBalance = parsed);
            }
          }
        } else {
          debugPrint("getWalletBalance unexpected body: ${res.body}");
        }
      } else if (res.statusCode == 401) {
        // token expired
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.")),
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
      throw Exception("Lỗi tải đơn hàng (${response.statusCode})");
    }
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

  void _showQrDialog(Order order) {
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
              const Text("Quét mã QR để thanh toán",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blue)),
              const SizedBox(height: 16),
              Image.network(qrUrl, height: 240, width: 240, fit: BoxFit.contain, errorBuilder: (ctx, err, st) {
                return const SizedBox(height: 240, width: 240, child: Center(child: Icon(Icons.broken_image)));
              }),
              const SizedBox(height: 10),
              Text("Số tiền: ${_fmtMoney(toPay)}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("Nội dung: $description", style: const TextStyle(color: Colors.orange)),
              const SizedBox(height: 5),
              const Text(
                "Sau khi chuyển khoản, hệ thống sẽ kiểm tra tự động.\nVui lòng không tắt màn hình khi chưa xác nhận.",
                style: TextStyle(fontSize: 13, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.red),
                label: const Text("Đóng mã QR", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _attemptWalletPayment(Order order) async {
    // Ensure we have the latest wallet balance
    await _fetchWallet();

    final toPay = order.total - order.downPayment;

    if (_walletBalance < toPay) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Số dư ví không đủ. Vui lòng nạp thêm."), backgroundColor: Colors.red),
        );
      }
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("accessToken") ?? _accessToken;
    if (token.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vui lòng đăng nhập."), backgroundColor: Colors.red),
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
          // Payment/confirmation succeeded
          final orderId = data['orderId'] ?? order.id;
          if (mounted) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Thành công"),
                content: Text(data['message']?.toString() ?? "Cập nhật trạng thái đơn thành công."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to detail screen, replace this screen
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
          // Refresh orders in background WITHOUT passing a Future into setState
          _futureOrders = _loadOrders();
          if (mounted) {
            setState(() {}); // synchronous update only
          }
          return;
        } else {
          final msg = (data is Map && data['message'] != null) ? data['message'].toString() : "Không thể xác nhận đơn.";
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.orange));
          }
        }
      } else if (res.statusCode == 111) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Số dư ví không đủ để thanh toán!"), backgroundColor: Colors.red),
          );
        }
      } else if (res.statusCode == 222) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Đơn hàng này đang không ở trạng thái 4"), backgroundColor: Colors.orange),
          );
        }
      } else if (res.statusCode == 401) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại."), backgroundColor: Colors.red),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Lỗi khi xác nhận đơn: ${res.statusCode}"), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      debugPrint("Error confirming order payment: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi kết nối: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _processingOrderIds.remove(order.id));
      }
    }
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
                      // Fix tràn cho dòng trạng thái
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
                              tooltip: "Chi tiết trạng thái",
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text("Mã đơn: ${o.orderCode}", style: const TextStyle(fontSize: 15)),
                      const SizedBox(height: 4),
                      Text("Người gửi: ${o.senderName} (${o.senderPhone})", overflow: TextOverflow.ellipsis),
                      Text("Người nhận: ${o.receiverName}", overflow: TextOverflow.ellipsis),
                      Text("Địa chỉ: ${o.receiverAddress}", overflow: TextOverflow.ellipsis),
                      const Divider(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text("Tổng: ${_fmtMoney(o.total)}",
                                style: const TextStyle(fontWeight: FontWeight.w500)),
                          ),
                          Expanded(
                            child: Text("Cọc: ${_fmtMoney(o.displayedDownPayment)}",
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      // Chỉ hiện nút thanh toán khi status == 4 và tiền cọc < tổng
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
                            // NOTE: Do not use Flexible/Expanded directly inside label.
                            label: Text(
                              "Thanh toán ${_fmtMoney(o.total - o.downPayment)}",
                              overflow: TextOverflow.ellipsis,
                            ),
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