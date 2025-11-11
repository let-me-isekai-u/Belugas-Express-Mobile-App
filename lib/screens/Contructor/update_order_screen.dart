  import 'dart:convert';
  import 'package:flutter/material.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import 'package:begulas_express/models/contructor_order_model.dart';
  import 'package:begulas_express/models/create_order_model.dart';
  import 'package:begulas_express/services/api_service.dart';
  import '../../l10n/app_localizations.dart';

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
            if (orderItems.isEmpty && pricingTable.isNotEmpty) {
              orderItems.add(OrderItemModel(
                pricingTableId: pricingTable.first['id'],
                name: pricingTable.first['name'] ?? '',
                unit: pricingTable.first['unit'] ?? '',
                weightEstimate: 0,
                price: (pricingTable.first['pricePerKilogram'] as num?)?.toDouble() ?? 0,
              ));
            } else {
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
          pricingError = AppLocalizations.of(context)!.updateOrderNoItemsMessage;
        } else {
          pricingError = "${AppLocalizations.of(context)!.updateOrderPricingErrorMessage}: ${res.statusCode}";
        }
      } catch (e) {
        pricingError = "${AppLocalizations.of(context)!.updateOrderPricingErrorMessage}: $e";
      } finally {
        setState(() {
          isLoadingPricing = false;
        });
      }
    }

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
      final options = _uniquePricingTable();
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
              Flexible(
                flex: 3,
                child: options.isNotEmpty
                    ? DropdownButtonFormField<int>(
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.updateOrderItemTypeLabel,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.createOrderItemType,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  ),
                  onChanged: (v) => item.name = v,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                flex: 2,
                child: TextFormField(
                  initialValue: item.weightEstimate > 0 ? item.weightEstimate.toString() : "",
                  decoration: InputDecoration(
                    labelText: item.unit == "kg"
                        ? AppLocalizations.of(context)!.updateOrderQuantityLabelKg
                        : AppLocalizations.of(context)!.updateOrderQuantityLabelUnit(item.unit),
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
                    if (val == null || val <= 0) return AppLocalizations.of(context)!.updateOrderInvalidQuantityMessage;
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10),
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
                      tooltip: AppLocalizations.of(context)!.updateOrderDeleteItemTooltip,
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

    Future<void> _performUpdateOnly(List<Map<String, dynamic>> payload) async {
      setState(() => isSubmitting = true);
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('accessToken');
        if (token == null || token.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.loginErrorEmpty)));
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
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(parsed['message'] ?? AppLocalizations.of(context)!.orderSnackUpdateSuccess)));
            Navigator.of(context).pop(payload);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(parsed['message'] ?? AppLocalizations.of(context)!.orderSnackUpdateFailed)));
          }
        } else if (updRes.statusCode == 401) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.orderSnackSessionExpired)));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("${AppLocalizations.of(context)!.orderSnackUpdateFailed}: ${updRes.body}")));
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("${AppLocalizations.of(context)!.orderSnackUpdateFailed}: $e")));
      } finally {
        setState(() => isSubmitting = false);
      }
    }

    void _onConfirm() {
      if (!_formKey.currentState!.validate()) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.updateOrderInvalidQuantityMessage)));
        return;
      }

      final result = orderItems.map((e) => e.toJson()).toList();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return StatefulBuilder(builder: (ctx2, setStateDialog) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.updateOrderConfirmDialogTitle),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(AppLocalizations.of(context)!.updateOrderConfirmDialogChangesLabel),
                    const SizedBox(height: 8),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          children: result.map<Widget>((it) {
                            final pid = it['pricingTableId'] ?? 0;
                            final weight = (it['weightEstimate'] ?? 0).toString();
                            final priceVal = it['price'];
                            final priceStr = (priceVal is num) ? priceVal.toStringAsFixed(0) : priceVal.toString();
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
                                      Text('${AppLocalizations.of(context)!.createOrderItemWeight(unit)}: $weight'),
                                      Text('${AppLocalizations.of(context)!.orderTotalLabel(priceStr)}',
                                          style: const TextStyle(color: Colors.green)),
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
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                    Navigator.of(ctx).pop();
                    await _performUpdateOnly(List<Map<String, dynamic>>.from(result));
                  },
                  child: isSubmitting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(AppLocalizations.of(context)!.update),
                ),
              ],
            );
          });
        },
      );
    }

    @override
    Widget build(BuildContext context) {
      final l10n = AppLocalizations.of(context)!;

      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.updateOrderAppBarTitle),
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
                    child: Text('${l10n.updateOrderPricingLoadedMessage(_uniquePricingTable().length.toString())}',
                        style: const TextStyle(color: Colors.grey)),
                  ),
              Expanded(
                child: orderItems.isEmpty
                    ? Center(child: Text(l10n.updateOrderNoItemsMessage))
                    : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 8),
                  itemCount: orderItems.length,
                  itemBuilder: (context, index) => _buildItemRow(index),
                ),
              ),
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
                          _addEmptyItem();
                        }
                      });
                    }
                        : null,
                    icon: const Icon(Icons.add_box, color: Colors.blue),
                    label: Text(l10n.updateOrderAddItemButton),
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
                          child: Text(l10n.cancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _onConfirm,
                          child: Text(l10n.confirm),
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
