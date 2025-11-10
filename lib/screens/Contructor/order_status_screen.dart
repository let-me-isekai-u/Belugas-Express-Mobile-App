import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:begulas_express/models/contructor_order_model.dart';
import 'package:begulas_express/services/api_service.dart';
import 'package:begulas_express/screens/Contructor/update_order_screen.dart';

const Map<int, String> statusLabels = {
  1: 'Đang đến lấy hàng',
  2: 'Đang trên đường đến kho trung chuyển',
  3: 'Đã đến kho',
  4: 'Chờ thanh toán',
  5: 'Chờ gửi hàng',
  6: 'Đang vận chuyển',
  7: 'Giao hàng thành công',
  8: 'Đã hủy',
};

const Map<int, String> statusOptions = {
  3: 'Đã đến kho',
  4: 'Chờ thanh toán',
  5: 'Chờ gửi hàng',
  6: 'Đang vận chuyển',
  7: 'Giao hàng thành công',
};

class OrderStatusScreen extends StatefulWidget {
  final VoidCallback? tabBarBack;
  const OrderStatusScreen({Key? key, this.tabBarBack}) : super(key: key);

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen>
    with SingleTickerProviderStateMixin {
  List<ContructorOrderModel> orders = [];
  bool isLoading = true;
  String? errorMessage;
  Map<int, int?> selectedStatusMap = {};
  final Map<int, List<Map<String, dynamic>>> updatedOrderItemsMap = {};
  late TabController _tabController;

  final List<Map<String, dynamic>> statusTabs = [
    {"id": 0, "name": "Tất cả"},
    {"id": 1, "name": "Đang đến lấy hàng"},
    {"id": 2, "name": "Đang trên đường đến kho"},
    {"id": 3, "name": "Đã đến kho"},
    {"id": 4, "name": "Chờ thanh toán"},
    {"id": 5, "name": "Chờ gửi hàng"},
    {"id": 6, "name": "Đang vận chuyển"},
    {"id": 7, "name": "Giao thành công"},
    {"id": 8, "name": "Đã hủy"},
  ];
  int selectedStatus = 0;

  // action labels for the green status button when visible
  final Map<int, String> actionLabels = {
    2: 'Đã đến kho',
    5: 'Đang vận chuyển',
    6: 'Giao hàng thành công',
  };

  // transitions for immediate status changes
  final Map<int, int> transitions = {
    2: 3,
    5: 6,
    6: 7,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: statusTabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          selectedStatus = statusTabs[_tabController.index]["id"];
        });
      }
    });
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString("accessToken");
      if (accessToken == null) {
        setState(() {
          errorMessage = "Bạn chưa đăng nhập.";
          isLoading = false;
        });
        return;
      }
      final response =
      await ApiService.getContractorOrders(accessToken: accessToken);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        orders = data.map((e) => ContructorOrderModel.fromJson(e)).toList();
        selectedStatusMap.clear();
      } else if (response.statusCode == 401) {
        setState(() {
          errorMessage = "Phiên đăng nhập hết hạn.";
        });
      } else if (response.statusCode == 404) {
        orders = [];
      } else {
        setState(() {
          errorMessage = "Lỗi tải đơn hàng: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Đã xảy ra lỗi: $e";
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _handleChangeStatus(int orderId, int newStatus) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("accessToken");
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bạn chưa đăng nhập.")),
        );
        return;
      }

      // If there are updated items cached for this order, send them first
      if (updatedOrderItemsMap.containsKey(orderId) &&
          (updatedOrderItemsMap[orderId]?.isNotEmpty ?? false)) {
        final itemsToSend = updatedOrderItemsMap[orderId]!;
        final updRes = await ApiService.updateOrderItems(
          accessToken: token,
          orderId: orderId,
          orderItems: itemsToSend,
        );
        if (updRes.statusCode == 200) {
          final parsed = jsonDecode(updRes.body);
          if (parsed["success"] != true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(parsed["message"] ?? "Cập nhật đơn hàng thất bại")),
            );
            return;
          }
        } else if (updRes.statusCode == 401) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Phiên đăng nhập hết hạn.")),
          );
          return;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Lỗi khi cập nhật đơn hàng: ${updRes.body}")),
          );
          return;
        }
      }

      // Call change status API (PUT)
      final response = await ApiService.changeOrderStatus(
        accessToken: token,
        orderId: orderId,
        newStatus: newStatus,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true) {
          updatedOrderItemsMap.remove(orderId);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data["message"] ?? "Cập nhật trạng thái thành công")),
          );
          await fetchOrders();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data["message"] ?? "Không thể cập nhật trạng thái")),
          );
        }
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Phiên đăng nhập hết hạn.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi khi cập nhật trạng thái: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi cập nhật trạng thái: $e")),
      );
    }
  }

  Future<void> _handleUpdateOrderItems(ContructorOrderModel order) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("accessToken");
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bạn chưa đăng nhập.")),
        );
        return;
      }

      final itemsToSend = (updatedOrderItemsMap[order.id] != null &&
          (updatedOrderItemsMap[order.id]?.isNotEmpty ?? false))
          ? updatedOrderItemsMap[order.id]!
          : order.items.map((it) {
        return {
          "pricingTableId": it.id,
          "weightEstimate": it.weightEstimate ?? 0,
          "price": it.price ?? 0,
        };
      }).toList();

      final response = await ApiService.updateOrderItems(
        accessToken: token,
        orderId: order.id,
        orderItems: itemsToSend,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true) {
          updatedOrderItemsMap.remove(order.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data["message"] ?? "Cập nhật đơn hàng thành công")),
          );
          await fetchOrders();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data["message"] ?? "Cập nhật đơn hàng thất bại")),
          );
        }
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Phiên đăng nhập hết hạn.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi khi cập nhật đơn hàng: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi cập nhật đơn hàng: $e")),
      );
    }
  }

  Future<void> _openUpdateOrderScreen(ContructorOrderModel order) async {
    // Open UpdateOrderScreen and wait for result.
    // UpdateOrderScreen should call API20 by itself and pop with payload on success.
    final result = await Navigator.of(context).push<List<Map<String, dynamic>>>(
      MaterialPageRoute(
        builder: (_) => UpdateOrderScreen(order: order),
      ),
    );

    if (result != null) {
      // If UpdateOrderScreen returned a payload, it means the update was successful (API20).
      // Immediately refresh the orders list so the UI reflects the server state.
      updatedOrderItemsMap[order.id] = result;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật chi tiết đơn hàng thành công. Đang cập nhật danh sách...')),
      );
      await fetchOrders(); // <-- ensures list is refreshed right after returning
      setState(() {}); // ensure UI updated (though fetchOrders calls setState)
    }
  }

  Widget buildOrderCard(ContructorOrderModel order) {
    final s = order.status;
    final statusStr = statusLabels[s] ?? 'Không xác định';
    final showGreenAction = transitions.keys.contains(s); // only 2,5,6
    final showUpdate = s == 3; // purple edit button remains for status 3
    if (s == 7) return _buildOrderInfoOnly(order, statusStr);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExpansionTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Mã đơn hàng: ${order.orderCode}",
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text("Người nhận: ${order.receiverName}"),
                  Text("Trạng thái: $statusStr", style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              children: [_buildOrderDetails(order, statusStr)],
            ),
            const Divider(height: 1),
            // Green action button: only for statuses 2,5,6
            if (showGreenAction)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12, top: 4, bottom: 6),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      minimumSize: const Size(20, 36),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      final nextStatus = transitions[s]!;
                      await _handleChangeStatus(order.id, nextStatus);
                    },
                    icon: const Icon(Icons.swap_horiz, size: 16),
                    label: Text(actionLabels[s] ?? "Đổi trạng thái", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  ),
                ),
              ),
            // Purple edit button stays for status 3 so contractor can edit details before sending
            if (showUpdate)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _openUpdateOrderScreen(order),
                  icon: const Icon(Icons.edit_note),
                  label: const Text("Cập nhật đơn hàng", style: TextStyle(fontWeight: FontWeight.w500)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfoOnly(ContructorOrderModel o, String s) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 2,
      child: ExpansionTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Mã đơn hàng: ${o.orderCode}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text("Người nhận: ${o.receiverName}"),
            Text("Trạng thái: $s", style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        children: [_buildOrderDetails(o, s)],
      ),
    );
  }

  Widget _buildOrderDetails(ContructorOrderModel order, String statusStr) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Địa chỉ: ${order.receiverAddress}"),
          Text("SĐT: ${order.receiverPhone}"),
          Text("Trạng thái: $statusStr", style: const TextStyle(fontWeight: FontWeight.w500)),
          Text("Đặt cọc: ${order.downPayment.toStringAsFixed(0)}"),
          Text("Thanh toán số dư: ${order.payWithBalance.toStringAsFixed(0)}"),
          Text("Ngày tạo: ${order.createDate.toString().substring(0, 19)}"),
          const SizedBox(height: 8),
          const Text("Danh sách hàng hóa:", style: TextStyle(fontWeight: FontWeight.bold)),
          ...order.items.map(
                (item) => ListTile(
              dense: true,
              title: Text(item.name),
              subtitle: Text("SL ước tính: ${item.weightEstimate} ${item.unit}${item.weightReal != null ? ' · Thực tế: ${item.weightReal}' : ''}"),
              trailing: Text("Tiền: ${item.amount.toStringAsFixed(0)}"),
            ),
          ),

          // NEW: Hiển thị "Chi tiết đơn hàng sau cập nhật" nếu có dữ liệu sửa trong updatedOrderItemsMap
          if (updatedOrderItemsMap.containsKey(order.id) && (updatedOrderItemsMap[order.id]?.isNotEmpty ?? false))
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Card(
                color: Colors.yellow[50],
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Chi tiết sau cập nhật", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 8),
                      ..._buildUpdatedDetails(order),
                      const SizedBox(height: 6),
                      const Text(
                        "Lưu ý: Đây là nội dung đã chỉnh trong màn hình 'Cập nhật đơn hàng' (chưa gửi nếu bạn chưa bấm nút hành động màu xanh).",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Tạo widget list hiển thị chi tiết đã chỉnh (so sánh với order.items nếu có)
  List<Widget> _buildUpdatedDetails(ContructorOrderModel order) {
    final updated = updatedOrderItemsMap[order.id] ?? [];
    final List<Widget> widgets = [];

    for (final up in updated) {
      final int ptId = (up['pricingTableId'] is int) ? up['pricingTableId'] as int : int.tryParse('${up['pricingTableId']}') ?? 0;
      final double newWeight = (up['weightEstimate'] is num) ? (up['weightEstimate'] as num).toDouble() : double.tryParse('${up['weightEstimate']}') ?? 0;
      final double newPrice = (up['price'] is num) ? (up['price'] as num).toDouble() : double.tryParse('${up['price']}') ?? 0;

      final origIndex = order.items.indexWhere((it) => it.id == ptId);
      final orig = origIndex != -1 ? order.items[origIndex] : null;

      // Prefer name/unit from payload, then original item, then fallback to id label
      final String title = (up['name'] != null && (up['name'] as String).trim().isNotEmpty)
          ? up['name'] as String
          : (orig != null ? orig.name : 'Mã sản phẩm: $ptId');

      final String unit = (up['unit'] != null && (up['unit'] as String).trim().isNotEmpty)
          ? up['unit'] as String
          : (orig != null ? (orig.unit ?? '') : '');

      final double oldWeight = orig != null ? (orig.weightEstimate ?? 0).toDouble() : 0;
      final double oldPrice = orig != null ? (orig.price ?? 0).toDouble() : 0;

      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('SL: ${newWeight.toString()} ${unit}', style: const TextStyle(fontSize: 13)),
                  Text('Giá: ${newPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, color: Colors.green)),
                  if (orig != null)
                    Text('Trước: SL ${oldWeight.toString()} · Giá ${oldPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ],
          ),
        ),
      );
      widgets.add(const Divider(height: 8));
    }

    return widgets;
  }

  Widget buildStatusSelector(ContructorOrderModel order) {
    final id = order.id;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: statusOptions.entries
            .map(
              (e) => ListTile(
            title: Text(e.value),
            onTap: () async {
              Navigator.of(context).pop();
              await _handleChangeStatus(id, e.key);
            },
          ),
        )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = selectedStatus == 0 ? orders : orders.where((o) => o.status == selectedStatus).toList();

    return DefaultTabController(
      length: statusTabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Danh sách đơn hàng'),
          backgroundColor: Colors.blue[400],
          leading: widget.tabBarBack != null ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.tabBarBack) : null,
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: Colors.orange,
            labelColor: Colors.orange,
            unselectedLabelColor: Colors.white,
            tabs: statusTabs.map((s) => Tab(child: Text(s["name"], style: const TextStyle(fontSize: 13)))).toList(),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Center(child: Text(errorMessage!))
            : filteredOrders.isEmpty
            ? const Center(child: Text("Không có đơn hàng nào."))
            : RefreshIndicator(
          onRefresh: fetchOrders,
          child: ListView.builder(
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) => buildOrderCard(filteredOrders[index]),
          ),
        ),
      ),
    );
  }
}
