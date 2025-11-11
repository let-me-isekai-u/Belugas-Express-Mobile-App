import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:begulas_express/models/contructor_order_model.dart';
import 'package:begulas_express/services/api_service.dart';
import 'package:begulas_express/screens/Contructor/update_order_screen.dart';
import '../../l10n/app_localizations.dart';

// Use localization for status labels and tabs
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

  int selectedStatus = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          selectedStatus = _tabController.index;
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
    final loc = AppLocalizations.of(context)!;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("accessToken");
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.orderSnackSessionExpired)),
        );
        return;
      }

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
              SnackBar(content: Text(loc.orderSnackUpdateFailed)),
            );
            return;
          }
        } else if (updRes.statusCode == 401) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.orderSnackSessionExpired)),
          );
          return;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("${loc.orderSnackUpdateFailed}: ${updRes.body}")),
          );
          return;
        }
      }

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
            SnackBar(content: Text(loc.orderSnackUpdateSuccess)),
          );
          await fetchOrders();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data["message"] ?? loc.orderSnackUpdateFailed)),
          );
        }
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.orderSnackSessionExpired)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${loc.orderSnackUpdateFailed}: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${loc.orderSnackUpdateFailed}: $e")),
      );
    }
  }

  Future<void> _handleUpdateOrderItems(ContructorOrderModel order) async {
    final loc = AppLocalizations.of(context)!;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("accessToken");
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.orderSnackSessionExpired)),
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
            SnackBar(content: Text(loc.orderSnackUpdateSuccess)),
          );
          await fetchOrders();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.orderSnackUpdateFailed)),
          );
        }
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.orderSnackSessionExpired)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${loc.orderSnackUpdateFailed}: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${loc.orderSnackUpdateFailed}: $e")),
      );
    }
  }

  Future<void> _openUpdateOrderScreen(ContructorOrderModel order) async {
    final result = await Navigator.of(context).push<List<Map<String, dynamic>>>(
      MaterialPageRoute(
        builder: (_) => UpdateOrderScreen(order: order),
      ),
    );

    if (result != null) {
      updatedOrderItemsMap[order.id] = result;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.orderSnackUpdateSuccess)),
      );
      await fetchOrders();
      setState(() {});
    }
  }

  Widget buildOrderCard(ContructorOrderModel order) {
    final loc = AppLocalizations.of(context)!;
    final s = order.status;
    final statusMap = [
      loc.orderStatusTabAll,
      loc.orderStatusTabPickup,
      loc.orderStatusTabInTransit,
      loc.orderStatusTabAtHub,
      loc.orderStatusTabAwaitingPayment,
      loc.orderStatusTabAwaitingShipment,
      loc.orderStatusTabShipping,
      loc.orderStatusTabDelivered,
      loc.orderStatusTabCancelled,
    ];
    final statusStr = s >= 0 && s < statusMap.length ? statusMap[s] : 'Unknown';

    final showGreenAction = {2, 5, 6}.contains(s);
    final showUpdate = s == 3;
    if (s == 7) return _buildOrderInfoOnly(order, statusStr, loc);

    // Action labels for green status button
    final actionLabels = {
      2: loc.orderActionChangeStatus,
      5: loc.orderActionChangeStatus,
      6: loc.orderActionChangeStatus,
    };

    // Transitions for immediate status changes
    final transitions = {
      2: 3,
      5: 6,
      6: 7,
    };

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
                  Text("Order code: ${order.orderCode}",
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(loc.orderReceiverLabel(order.receiverName)),
                  Text(loc.orderStatusLabel(statusStr), style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              children: [_buildOrderDetails(order, statusStr, loc)],
            ),
            const Divider(height: 1),
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
                    label: Text(actionLabels[s] ?? loc.orderActionChangeStatus, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  ),
                ),
              ),
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
                  label: Text(loc.orderActionUpdateOrder, style: const TextStyle(fontWeight: FontWeight.w500)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfoOnly(ContructorOrderModel o, String statusStr, AppLocalizations loc) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 2,
      child: ExpansionTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Order code: ${o.orderCode}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(loc.orderReceiverLabel(o.receiverName)),
            Text(loc.orderStatusLabel(statusStr), style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        children: [_buildOrderDetails(o, statusStr, loc)],
      ),
    );
  }

  Widget _buildOrderDetails(ContructorOrderModel order, String statusStr, AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(loc.orderAddressLabel(order.receiverAddress)),
          Text(loc.orderPhoneLabel(order.receiverPhone)),
          Text(loc.orderStatusLabel(statusStr), style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(loc.orderDownPaymentLabel(order.downPayment.toStringAsFixed(0))),
          Text(loc.orderBalancePaymentLabel(order.payWithBalance.toStringAsFixed(0))),
          Text(loc.orderCreatedDateLabel(order.createDate.toString().substring(0, 19))),
          const SizedBox(height: 8),
          Text(loc.orderItemListLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
          ...order.items.map(
                (item) => ListTile(
              dense: true,
              title: Text(item.name),
              subtitle: Text("Estimated qty: ${item.weightEstimate} ${item.unit}${item.weightReal != null ? ' · Actual: ${item.weightReal}' : ''}"),
              trailing: Text("Amount: ${item.amount.toStringAsFixed(0)}"),
            ),
          ),
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
                      Text(loc.orderUpdatedDetailsLabel, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 8),
                      ..._buildUpdatedDetails(order, loc),
                      const SizedBox(height: 6),
                      Text(loc.orderUpdatedNotice, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildUpdatedDetails(ContructorOrderModel order, AppLocalizations loc) {
    final updated = updatedOrderItemsMap[order.id] ?? [];
    final List<Widget> widgets = [];

    for (final up in updated) {
      final int ptId = (up['pricingTableId'] is int) ? up['pricingTableId'] as int : int.tryParse('${up['pricingTableId']}') ?? 0;
      final double newWeight = (up['weightEstimate'] is num) ? (up['weightEstimate'] as num).toDouble() : double.tryParse('${up['weightEstimate']}') ?? 0;
      final double newPrice = (up['price'] is num) ? (up['price'] as num).toDouble() : double.tryParse('${up['price']}') ?? 0;

      final origIndex = order.items.indexWhere((it) => it.id == ptId);
      final orig = origIndex != -1 ? order.items[origIndex] : null;

      final String title = (up['name'] != null && (up['name'] as String).trim().isNotEmpty)
          ? up['name'] as String
          : (orig != null ? orig.name : 'ID: $ptId');
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
                  Text('Qty: ${newWeight.toString()} ${unit}', style: const TextStyle(fontSize: 13)),
                  Text('Price: ${newPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, color: Colors.green)),
                  if (orig != null)
                    Text('Prev: Qty ${oldWeight.toString()} · Price ${oldPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final statusTabs = [
      {"id": 0, "name": loc.orderStatusTabAll},
      {"id": 1, "name": loc.orderStatusTabPickup},
      {"id": 2, "name": loc.orderStatusTabInTransit},
      {"id": 3, "name": loc.orderStatusTabAtHub},
      {"id": 4, "name": loc.orderStatusTabAwaitingPayment},
      {"id": 5, "name": loc.orderStatusTabAwaitingShipment},
      {"id": 6, "name": loc.orderStatusTabShipping},
      {"id": 7, "name": loc.orderStatusTabDelivered},
      {"id": 8, "name": loc.orderStatusTabCancelled},
    ];

    final filteredOrders = selectedStatus == 0 ? orders : orders.where((o) => o.status == selectedStatus).toList();

    return DefaultTabController(
      length: statusTabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.orderStatusScreenTitle),
          backgroundColor: Colors.blue[400],
          leading: widget.tabBarBack != null ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.tabBarBack) : null,
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: Colors.orange,
            labelColor: Colors.orange,
            unselectedLabelColor: Colors.white,
            tabs: statusTabs.map((s) => Tab(child: Text(s["name"]?.toString() ?? '', style: const TextStyle(fontSize: 13)))).toList(),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Center(child: Text(errorMessage!))
            : filteredOrders.isEmpty
            ? Center(child: Text(loc.orderNoOrders ?? "No orders found."))
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