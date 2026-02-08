import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/api_service.dart';

class CreateBudgetRequestPage extends StatefulWidget {
  const CreateBudgetRequestPage({super.key});

  @override
  State<CreateBudgetRequestPage> createState() => _CreateBudgetRequestPageState();
}

class _CreateBudgetRequestPageState extends State<CreateBudgetRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _specificationController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');

  // Request type: 'lumpsum' or 'shopping_list'
  String _requestType = 'lumpsum';

  // Lumpsum items from API
  List<Map<String, dynamic>> _lumpsumItems = [];
  Map<String, dynamic>? _selectedLumpsumItem;

  // Shopping List items from API
  List<Map<String, dynamic>> _shoppingListItems = [];
  Map<String, dynamic>? _selectedShoppingItem;

  // Cart items (multiple items before submission)
  List<Map<String, dynamic>> _cartItems = [];

  bool _isLoading = false;
  bool _isLoadingData = true;


  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _specificationController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoadingData = true);
    await Future.wait([
      _loadLumpsumItems(),
      _loadShoppingListItems(),
    ]);
    setState(() => _isLoadingData = false);
  }

  Future<void> _loadLumpsumItems() async {
    try {
      final result = await ApiService.get('/lumpsum-items');
      if (!mounted) return;

      if (!result['error']) {
        final List<dynamic> itemsData = result['data']['data'] ?? [];
        setState(() {
          _lumpsumItems = itemsData.map((item) => Map<String, dynamic>.from(item)).toList();
        });
      } else {
        debugPrint('Error loading lumpsum items: ${result['message']}');
      }
    } catch (e) {
      debugPrint('Exception loading lumpsum items: $e');
    }
  }

  Future<void> _loadShoppingListItems() async {
    try {
      final result = await ApiService.get('/shopping-list-items');
      if (!mounted) return;

      if (!result['error']) {
        final List<dynamic> itemsData = result['data']['data'] ?? [];
        setState(() {
          _shoppingListItems = itemsData.map((item) => Map<String, dynamic>.from(item)).toList();
        });
      } else {
        debugPrint('Error loading shopping list items: ${result['message']}');
      }
    } catch (e) {
      debugPrint('Exception loading shopping list items: $e');
    }
  }

  void _addToCart() {
    if (!_formKey.currentState!.validate()) return;

    // Validation based on request type
    if (_requestType == 'lumpsum' && _selectedLumpsumItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih item lumpsum terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_requestType == 'shopping_list' && _selectedShoppingItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih item shopping list terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Add to cart
    setState(() {
      if (_requestType == 'lumpsum') {
        _cartItems.add({
          'type': 'lumpsum',
          'item_id': _selectedLumpsumItem!['id'],
          'item_name': _selectedLumpsumItem!['description'],
          'regional': _selectedLumpsumItem!['regional'],
          'quantity': int.tryParse(_quantityController.text) ?? 1,
          'specification': _specificationController.text.trim(),
        });
      } else {
        _cartItems.add({
          'type': 'shopping_list',
          'item_id': _selectedShoppingItem!['id'],
          'item_name': '${_selectedShoppingItem!['kode_cor']} - ${_selectedShoppingItem!['deskripsi_pekerjaan']}',
          'regional': _selectedShoppingItem!['regional'],
          'quantity': int.tryParse(_quantityController.text) ?? 1,
          'specification': _specificationController.text.isNotEmpty ? _specificationController.text.trim() : null,
        });
      }

      // Reset form
      _selectedLumpsumItem = null;
      _selectedShoppingItem = null;
      _specificationController.clear();
      _quantityController.text = '1';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item berhasil ditambahkan ke keranjang'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removeFromCart(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  Future<void> _submitRequest() async {
    // Validation: cart must not be empty
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keranjang kosong! Silakan tambahkan item terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      int successCount = 0;
      int failCount = 0;

      // Submit each cart item
      for (var item in _cartItems) {
        late Map<String, dynamic> result;

        if (item['type'] == 'lumpsum') {
          result = await ApiService.createLumpsumBudgetRequest(
            lumpsumItemId: item['item_id'],
            quantity: item['quantity'],
            specification: item['specification'],
            photos: null, // No photos during submission
          );
        } else {
          // shopping_list
          result = await ApiService.createShoppingListBudgetRequest(
            shoppingListItemId: item['item_id'],
            quantity: item['quantity'],
            specification: item['specification'],
            photos: null, // No photos during submission
          );
        }

        if (!result['error']) {
          successCount++;
        } else {
          failCount++;
        }
      }

      if (!mounted) return;

      if (failCount == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil mengajukan $successCount permintaan anggaran'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$successCount berhasil, $failCount gagal'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Buat Permintaan Anggaran'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Request Type Selection
                    _buildRequestTypeSelector(),
                    SizedBox(height: 20.h),

                    // Dynamic form based on request type
                    if (_requestType == 'lumpsum') ..._buildLumpsumForm(),
                    if (_requestType == 'shopping_list') ..._buildShoppingListForm(),

                    SizedBox(height: 24.h),

                    // Add to Cart Button
                    ElevatedButton.icon(
                      onPressed: _addToCart,
                      icon: Icon(Iconsax.shopping_cart, size: 20.sp),
                      label: Text(
                        'Tambah ke Keranjang',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Cart Section
                    if (_cartItems.isNotEmpty) ...[
                      _buildCartSection(),
                      SizedBox(height: 24.h),

                      // Submit All Button
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _submitRequest,
                        icon: Icon(Iconsax.tick_circle, size: 20.sp),
                        label: Text(
                          'Kirim Semua Permintaan (${_cartItems.length})',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildRequestTypeSelector() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tipe Permintaan',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildTypeButton(
                  'lumpsum',
                  'Lumpsum',
                  Iconsax.dollar_circle,
                  Colors.orange,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildTypeButton(
                  'shopping_list',
                  'Shopping List',
                  Iconsax.shopping_cart,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(String type, String label, IconData icon, Color color) {
    final bool isSelected = _requestType == type;

    return InkWell(
      onTap: () {
        setState(() {
          _requestType = type;
          // Reset selections
          _selectedLumpsumItem = null;
          _selectedShoppingItem = null;
          _specificationController.clear();
          _quantityController.text = '1';
        });
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey,
              size: 28.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontFamily: 'Poppins',
                color: isSelected ? color : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }


  List<Widget> _buildLumpsumForm() {
    return [
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih Item Lumpsum',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12.h),
            if (_lumpsumItems.isEmpty)
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.info_circle, color: Colors.orange.shade700, size: 20.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Tidak ada item lumpsum tersedia',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontFamily: 'Poppins',
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              DropdownButtonFormField<Map<String, dynamic>>(
                value: _selectedLumpsumItem,
                isExpanded: true,
                decoration: InputDecoration(
                  hintText: 'Pilih item lumpsum',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                ),
                items: _lumpsumItems.map((item) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: item,
                    child: Text(
                      item['description'] ?? '',
                      style: TextStyle(fontSize: 13.sp, fontFamily: 'Poppins'),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLumpsumItem = value;
                  });
                },
              ),
            if (_selectedLumpsumItem != null) ...[
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Info Item',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: Colors.green.shade900,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Regional: ${_selectedLumpsumItem!['regional']}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: 'Poppins',
                        color: Colors.green.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 20.h),

            // Quantity
            Text(
              'Jumlah/Kuantitas',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 13.sp, fontFamily: 'Poppins'),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: '1',
                hintStyle: TextStyle(fontSize: 13.sp),
                filled: true,
                fillColor: Colors.grey.shade50,
                prefixIcon: Icon(Iconsax.math, color: const Color(0xFF2E7D32), size: 20.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Kuantitas tidak boleh kosong';
                }
                return null;
              },
            ),
            SizedBox(height: 20.h),

            // Specification
            Text(
              'Keterangan/Catatan',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: _specificationController,
              maxLines: 4,
              style: TextStyle(fontSize: 13.sp, fontFamily: 'Poppins'),
              decoration: InputDecoration(
                hintText: 'Keterangan tambahan...',
                hintStyle: TextStyle(fontSize: 13.sp),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                ),
                contentPadding: EdgeInsets.all(16.w),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Keterangan tidak boleh kosong';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildShoppingListForm() {
    return [
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih Item Shopping List',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12.h),
            if (_shoppingListItems.isEmpty)
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.info_circle, color: Colors.orange.shade700, size: 20.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Tidak ada item shopping list tersedia',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontFamily: 'Poppins',
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              DropdownButtonFormField<Map<String, dynamic>>(
                value: _selectedShoppingItem,
                isExpanded: true,
                decoration: InputDecoration(
                  hintText: 'Pilih item shopping list',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                ),
                items: _shoppingListItems.map((item) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: item,
                    child: Text(
                      '${item['kode_cor']} - ${item['deskripsi_pekerjaan']}',
                      style: TextStyle(fontSize: 13.sp, fontFamily: 'Poppins'),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedShoppingItem = value;
                  });
                },
              ),
            if (_selectedShoppingItem != null) ...[
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Info Item',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: Colors.blue.shade900,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Kode: ${_selectedShoppingItem!['kode_cor']}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: 'Poppins',
                        color: Colors.blue.shade900,
                      ),
                    ),
                    Text(
                      'Regional: ${_selectedShoppingItem!['regional']}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: 'Poppins',
                        color: Colors.blue.shade900,
                      ),
                    ),
                    Text(
                      'Satuan: ${_selectedShoppingItem!['satuan']}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: 'Poppins',
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 20.h),

            // Quantity
            Text(
              'Jumlah/Kuantitas',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 13.sp, fontFamily: 'Poppins'),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: '1',
                hintStyle: TextStyle(fontSize: 13.sp),
                filled: true,
                fillColor: Colors.grey.shade50,
                prefixIcon: Icon(Iconsax.math, color: const Color(0xFF2E7D32), size: 20.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Kuantitas tidak boleh kosong';
                }
                return null;
              },
            ),
            SizedBox(height: 20.h),

            // Specification (optional for shopping list)
            Text(
              'Keterangan/Catatan (Opsional)',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: _specificationController,
              maxLines: 3,
              style: TextStyle(fontSize: 13.sp, fontFamily: 'Poppins'),
              decoration: InputDecoration(
                hintText: 'Keterangan tambahan (opsional)...',
                hintStyle: TextStyle(fontSize: 13.sp),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                ),
                contentPadding: EdgeInsets.all(16.w),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildCartSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Keranjang Permintaan',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '${_cartItems.length} Item',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Cart items list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _cartItems.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final item = _cartItems[index];
              return Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: item['type'] == 'lumpsum' ? Colors.orange.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        item['type'] == 'lumpsum' ? Iconsax.dollar_circle : Iconsax.shopping_cart,
                        color: item['type'] == 'lumpsum' ? Colors.orange : Colors.green,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['item_name'],
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Regional: ${item['regional']}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontFamily: 'Poppins',
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            'Qty: ${item['quantity']}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontFamily: 'Poppins',
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (item['specification'] != null && item['specification'].toString().isNotEmpty)
                            Text(
                              'Ket: ${item['specification']}',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontFamily: 'Poppins',
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    IconButton(
                      icon: Icon(Iconsax.trash, color: Colors.red, size: 20.sp),
                      onPressed: () => _removeFromCart(index),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              );
            },
          ),

          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}
