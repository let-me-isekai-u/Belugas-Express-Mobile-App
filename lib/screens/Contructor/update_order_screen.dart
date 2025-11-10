import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:begulas_express/models/contructor_order_model.dart';
import 'package:begulas_express/models/create_order_model.dart';
import 'package:begulas_express/services/api_service.dart';

/// Màn hình chỉnh sửa chi tiết đơn hàng (phiên bản giống CreateOrderScreen)
/// - Phần mặt hàng giống hệt CreateOrderScreen: Dropdown chọn "Loại hàng", chỉ sửa được "Số lượng"
/// - Giá lấy từ pricing table (không edit được)
/// - Nút "Thêm mặt hàng" nằm dưới danh sách (OutlinedButton.icon như CreateOrderScreen)
/// - Khi Xác nhận, sẽ hiển thị popup tóm tắt những thay đổi, hỏi xác nhận:
///   - Nếu chọn "Cập nhật": gọi API 20 (update-order-item) rồi pop trả về payload (không đổi trạng thái).
///   - Nếu chọn "Huỷ": đóng popup thôi.
class UpdateOrderScreen extends StatefulWidget {
  final ContructorOrderModel order;

  const UpdateOrderScreen({Key? key, required this.order}) : super(key: key);

  @override
  State<UpdateOrderScreen> createState() => _UpdateOrderScreenState();
}

class _UpdateOrderScreenState extends State<UpdateOrderScreen> {
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> pricingTable = [];
  bool isLoadingPricing = false;
  String? pricingError;
  bool isSubmitting = false;

  List<OrderItemModel> orderItems = [];

  @override
  void initState() {
    super.initState();
    // Khởi tạo orderItems từ order hiện có
    orderItems = widget.order.items.map((it) {
      return OrderItemModel(
        pricingTableId: it.id,
        name: it.name,
        unit: it.unit,
        weightEstimate: (it.weightEstimate ?? 0).toDouble(),
        price: (it.price ?? 0).toDouble(),
      );
    }).toList();

    // Lấy bảng giá theo countryId của order
    _fetchPricingTable(widget.order.countryId);
  }

  Future<void> _fetchPricingTable(int countryId) async {
    setState(() {
      isLoadingPricing = true;
      pricingError = null;
    });
    try {
      final res = await ApiService.getPricingTable(countryId: countryId);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is List) {
          pricingTable = List<Map<String, dynamic>>.from(data);
          // Nếu orderItems rỗng thì thêm 1 mục mặc định
          if (orderItems.isEmpty && pricingTable.isNotEmpty) {
            orderItems.add(OrderItemModel(
              pricingTableId: pricingTable.first['id'],
              name: pricingTable.first['name'] ?? '',
              unit: pricingTable.first['unit'] ?? '',
              weightEstimate: 0,
              price: (pricingTable.first['pricePerKilogram'] as num?)?.toDouble() ?? 0,
            ));
          } else {
            // Đồng bộ giá/unit cho các item hiện có nếu tìm được trong pricingTable
            for (var it in orderItems) {
              final found = pricingTable.firstWhere((p) => p['id'] == it.pricingTableId, orElse: () => {});
              if (found.isNotEmpty) {
                it.name = found['name'] ?? it.name;
                it.unit = found['unit'] ?? it.unit;
                it.price = (found['pricePerKilogram'] is num)
                    ? (found['pricePerKilogram'] as num).toDouble()
                    : it.price;
              }
            }
          }
        }
      } else if (res.statusCode == 100) {
        pricingTable = [];
        pricingError = "Không có danh sách bảng giá";
      } else {
        pricingError = "Lỗi khi lấy bảng giá: ${res.statusCode}";
      }
    } catch (e) {
      pricingError = "Lỗi khi lấy bảng giá: $e";
    } finally {
      setState(() {
        isLoadingPricing = false;
      });
    }
  }

  // Trả về danh sách pricing không trùng id (giữ thứ tự)
  List<Map<String, dynamic>> _uniquePricingTable() {
    final seen = <dynamic>{};
    final unique = <Map<String, dynamic>>[];
    for (final p in pricingTable) {
      final id = p['id'];
      if (id == null) continue;
      if (!seen.contains(id)) {
        seen.add(id);
        unique.add(p);
      }
    }
    return unique;
  }

  Widget _buildItemRow(int index) {
    final item = orderItems[index];
    final options = _uniquePricingTable(); // deduplicated options

    // xác định giá trị hiện tại cho dropdown: nếu không có trong options thì fallback null hoặc first
    final hasMatch = options.any((p) => p['id'] == item.pricingTableId);
    final dropdownValue = hasMatch ? item.pricingTableId : (options.isNotEmpty ? options.first['id'] : null);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Dropdown loại hàng (giống CreateOrderScreen)
            Flexible(
              flex: 3,
              child: options.isNotEmpty
                  ? DropdownButtonFormField<int>(
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: "Loại hàng",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                ),
                value: dropdownValue,
                items: options
                    .map((e) => DropdownMenuItem<int>(
                  value: e['id'] as int,
                  child: Text(e['name'] ?? ""),
                ))
                    .toList(),
                onChanged: (v) {
                  final found = pricingTable.firstWhere((f) => f['id'] == v, orElse: () => {});
                  setState(() {
                    if (found.isNotEmpty) {
                      item.pricingTableId = found['id'];
                      item.name = found['name'] ?? item.name;
                      item.unit = found['unit'] ?? item.unit;
                      item.price = (found['pricePerKilogram'] is num)
                          ? (found['pricePerKilogram'] as num).toDouble()
                          : item.price;
                    } else {
                      item.pricingTableId = v ?? item.pricingTableId;
                    }
                  });
                },
              )
                  : TextFormField(
                initialValue: item.name,
                decoration: const InputDecoration(
                  labelText: 'Tên hàng',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                ),
                onChanged: (v) => item.name = v,
              ),
            ),
            const SizedBox(width: 10),

            // Số lượng (chỉ edit)
            Flexible(
              flex: 2,
              child: TextFormField(
                initialValue: item.weightEstimate > 0 ? item.weightEstimate.toString() : "",
                decoration: InputDecoration(
                  labelText: item.unit == "kg" ? "Kg" : (item.unit),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (v) {
                  final val = double.tryParse(v) ?? 0;
                  setState(() => item.weightEstimate = val);
                },
                validator: (v) {
                  final val = double.tryParse(v ?? "");
                  if (val == null || val <= 0) return "Nhập số lượng hợp lệ";
                  return null;
                },
              ),
            ),
            const SizedBox(width: 10),

            // Giá (không edit, chỉ hiển thị)
            SizedBox(
              width: 96,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${item.price.toStringAsFixed(0)}đ/${item.unit}",
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red, size: 20),
                    onPressed: orderItems.length > 1 ? () => setState(() => orderItems.removeAt(index)) : null,
                    tooltip: "Xoá mặt hàng",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addItemFromPricing(Map<String, dynamic> p) {
    setState(() {
      orderItems.add(OrderItemModel(
        pricingTableId: p['id'],
        name: p['name'] ?? '',
        unit: p['unit'] ?? '',
        weightEstimate: 0,
        price: (p['pricePerKilogram'] is num) ? (p['pricePerKilogram'] as num).toDouble() : 0,
      ));
    });
  }

  void _addEmptyItem() {
    setState(() {
      orderItems.add(OrderItemModel(
        pricingTableId: 0,
        name: '',
        unit: '',
        weightEstimate: 0,
        price: 0,
      ));
    });
  }

  // Gọi API 20 (chỉ cập nhật chi tiết đơn hàng), KHÔNG đổi trạng thái
  Future<void> _performUpdateOnly(List<Map<String, dynamic>> payload) async {
    setState(() => isSubmitting = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bạn chưa đăng nhập.")));
        setState(() => isSubmitting = false);
        return;
      }

      final updRes = await ApiService.updateOrderItems(
        accessToken: token,
        orderId: widget.order.id,
        orderItems: payload,
      );

      if (updRes.statusCode == 200) {
        final parsed = jsonDecode(updRes.body);
        if (parsed['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(parsed['message'] ?? "Cập nhật đơn hàng thành công")));
          // Trả về payload cho màn hình trước để cập nhật tạm (OrderStatusScreen sẽ refresh/hiển thị)
          Navigator.of(context).pop(payload);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(parsed['message'] ?? "Cập nhật đơn hàng thất bại")));
        }
      } else if (updRes.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Phiên đăng nhập hết hạn.")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi khi cập nhật đơn hàng: ${updRes.body}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  void _onConfirm() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập số lượng hợp lệ cho mỗi mặt hàng")));
      return;
    }

    final result = orderItems.map((e) => e.toJson()).toList();

    // Hiển thị popup xác nhận với tóm tắt chi tiết đã chỉnh
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx2, setStateDialog) {
          return AlertDialog(
            title: const Text("Xác nhận cập nhật đơn hàng"),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Chi tiết thay đổi:"),
                  const SizedBox(height: 8),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: result.map<Widget>((it) {
                          final pid = it['pricingTableId'] ?? 0;
                          final weight = (it['weightEstimate'] ?? 0).toString();
                          final priceVal = it['price'];
                          final priceStr = (priceVal is num) ? priceVal.toStringAsFixed(0) : priceVal.toString();
                          // Try to find name/unit from local pricingTable or original items
                          String title = 'Mã: $pid';
                          String unit = '';
                          final foundPrice = pricingTable.firstWhere((p) => p['id'] == pid, orElse: () => {});
                          if (foundPrice.isNotEmpty) {
                            title = foundPrice['name'] ?? title;
                            unit = foundPrice['unit'] ?? '';
                          } else {
                            final origIndex = widget.order.items.indexWhere((o) => o.id == pid);
                            if (origIndex != -1) {
                              title = widget.order.items[origIndex].name;
                              unit = widget.order.items[origIndex].unit ?? '';
                            }
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('SL: $weight $unit'),
                                    Text('Giá: $priceStr', style: const TextStyle(color: Colors.green)),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () => Navigator.of(ctx).pop(),
                child: const Text('Huỷ'),
              ),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                  // Đóng dialog trước khi perform request để tránh multiple dialogs stacking.
                  Navigator.of(ctx).pop();
                  await _performUpdateOnly(List<Map<String, dynamic>>.from(result));
                },
                child: isSubmitting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Cập nhật'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cập nhật đơn hàng'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            if (isLoadingPricing)
              const LinearProgressIndicator()
            else if (pricingError != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(pricingError!, style: const TextStyle(color: Colors.red)),
              )
            else if (pricingTable.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text('Đã tải ${_uniquePricingTable().length} mục trong bảng giá', style: const TextStyle(color: Colors.grey)),
                ),
            Expanded(
              child: orderItems.isEmpty
                  ? const Center(child: Text('Chưa có hàng hóa. Nhấn Thêm để thêm.'))
                  : ListView.builder(
                padding: const EdgeInsets.only(bottom: 8),
                itemCount: orderItems.length,
                itemBuilder: (context, index) => _buildItemRow(index),
              ),
            ),
            // Nút "Thêm mặt hàng"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: pricingTable.isNotEmpty
                      ? () {
                    setState(() {
                      final first = _uniquePricingTable().isNotEmpty ? _uniquePricingTable().first : null;
                      if (first != null) {
                        orderItems.add(OrderItemModel(
                          pricingTableId: first['id'],
                          name: first['name'],
                          unit: first['unit'],
                          weightEstimate: 0,
                          price: (first['pricePerKilogram'] as num).toDouble(),
                        ));
                      } else {
                        orderItems.add(OrderItemModel(
                          pricingTableId: 0,
                          name: '',
                          unit: '',
                          weightEstimate: 0,
                          price: 0,
                        ));
                      }
                    });
                  }
                      : null,
                  icon: const Icon(Icons.add_box, color: Colors.blue),
                  label: const Text("Thêm mặt hàng"),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Huỷ'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _onConfirm,
                        child: const Text('Xác nhận'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}