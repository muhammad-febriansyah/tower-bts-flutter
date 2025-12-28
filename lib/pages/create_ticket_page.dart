import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../services/api_service.dart';
import '../models/site.dart';
import '../config/app_colors.dart';

class CreateTicketPage extends StatefulWidget {
  const CreateTicketPage({super.key});

  @override
  State<CreateTicketPage> createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends State<CreateTicketPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingSites = true;
  bool _isLoadingTypes = true;

  List<Site> _sites = [];
  List<Map<String, dynamic>> _engineers = [];
  List<Map<String, dynamic>> _ticketTypes = [];
  Site? _selectedSite;
  int? _selectedEngineerId;
  String _selectedPriority = 'medium';
  String? _selectedType;
  TimeOfDay? _workStartTime;
  TimeOfDay? _workEndTime;

  final List<Map<String, dynamic>> _priorities = [
    {
      'value': 'low',
      'label': 'Rendah',
      'color': Color(0xFF4CAF50),
      'icon': Iconsax.arrow_down_1,
    },
    {
      'value': 'medium',
      'label': 'Sedang',
      'color': Color(0xFFFF9800),
      'icon': Iconsax.minus,
    },
    {
      'value': 'high',
      'label': 'Tinggi',
      'color': Color(0xFFF44336),
      'icon': Iconsax.arrow_up_1,
    },
    {
      'value': 'critical',
      'label': 'Kritis',
      'color': Color(0xFFB71C1C),
      'icon': Iconsax.danger,
    },
  ];

  // Icon mapping untuk ticket types
  final Map<String, IconData> _typeIcons = {
    'kebersihan': Iconsax.broom,
    'perbaikan_lumpsum': Iconsax.dollar_circle,
    'corrective': Iconsax.setting_2,
    'corrective_cme': Iconsax.cpu,
    'jasa': Iconsax.people,
    'imbas_petir': Iconsax.flash,
    'pengisian_bbm': Iconsax.gas_station,
    'mbp': Iconsax.battery_charging,
  };

  @override
  void initState() {
    super.initState();
    _loadSites();
    _loadTicketTypes();
    _loadEngineers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _workStartTime = picked;
          _startTimeController.text = picked.format(context);
        } else {
          _workEndTime = picked;
          _endTimeController.text = picked.format(context);
        }
      });
    }
  }

  Future<void> _loadSites() async {
    setState(() => _isLoadingSites = true);

    try {
      final result = await ApiService.getSites();

      if (!mounted) return;

      if (!result['error']) {
        final List<dynamic> sitesData = result['data']['sites'] ?? [];
        setState(() {
          _sites = sitesData.map((json) => Site.fromJson(json)).toList();
          _isLoadingSites = false;
        });
      } else {
        setState(() => _isLoadingSites = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Gagal memuat data site')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSites = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _loadTicketTypes() async {
    setState(() => _isLoadingTypes = true);

    try {
      final result = await ApiService.getTicketTypes();

      if (!mounted) return;

      if (!result['error']) {
        final List<dynamic> typesData = result['data'] ?? [];
        setState(() {
          _ticketTypes = typesData.map((type) => {
            'id': type['id'],
            'name': type['name'],
            'code': type['code'],
            'description': type['description'],
          }).toList();
          // Don't auto-select, let user choose
          _isLoadingTypes = false;
        });
      } else {
        setState(() => _isLoadingTypes = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingTypes = false);
      }
    }
  }

  Future<void> _loadEngineers() async {
    try {
      final result = await ApiService.getEngineers();

      if (!mounted) return;

      if (!result['error']) {
        final List<dynamic> usersData = result['data']['users'] ?? result['data'] ?? [];
        setState(() {
          _engineers = usersData.map((user) => {
            'id': user['id'],
            'name': user['name'],
            'role': user['role'],
          }).toList();
        });
      }
    } catch (e) {
      // Error loading engineers
    }
  }

  Future<void> _createTicket() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSite == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih lokasi site terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? workStartTimeFormatted;
      String? workEndTimeFormatted;

      if (_workStartTime != null) {
        workStartTimeFormatted = '${_workStartTime!.hour.toString().padLeft(2, '0')}:${_workStartTime!.minute.toString().padLeft(2, '0')}';
      }
      if (_workEndTime != null) {
        workEndTimeFormatted = '${_workEndTime!.hour.toString().padLeft(2, '0')}:${_workEndTime!.minute.toString().padLeft(2, '0')}';
      }

      final result = await ApiService.createTicket(
        siteId: _selectedSite!.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _selectedPriority,
        type: _selectedType!,
        engineerId: _selectedEngineerId,
        workStartTime: workStartTimeFormatted,
        workEndTime: workEndTimeFormatted,
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (!result['error']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Iconsax.tick_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Tiket berhasil dibuat!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Iconsax.close_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text(result['message'] ?? 'Gagal membuat tiket')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Buat Tiket Gangguan',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoadingSites || _isLoadingTypes
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                ),
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Site Selection
                      Text(
                        'Lokasi Site',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: Colors.black87,
                        ),
                      ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Site>(
                      decoration: InputDecoration(
                        hintText: 'Pilih lokasi site',
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      items: _sites.map((site) {
                        return DropdownMenuItem<Site>(
                          value: site,
                          child: Text(
                            site.siteName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (site) {
                        setState(() => _selectedSite = site);
                      },
                      validator: (value) {
                        if (value == null) return 'Silakan pilih site';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      'Judul Gangguan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      style: const TextStyle(fontFamily: 'Poppins'),
                      decoration: InputDecoration(
                        hintText: 'Contoh: Alarm Power Supply Menyala',
                        hintStyle: const TextStyle(fontSize: 13),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Judul tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Priority
                    Text(
                      'Prioritas',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _priorities.map((priority) {
                        final isSelected = _selectedPriority == priority['value'];
                        return InkWell(
                          onTap: () {
                            setState(() => _selectedPriority = priority['value'] as String);
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? priority['color'] as Color
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? priority['color'] as Color
                                    : Colors.grey.shade300,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              priority['label'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                fontFamily: 'Poppins',
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Type
                    Text(
                      'Jenis Ticket',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedType,
                      hint: Row(
                        children: [
                          Icon(
                            Iconsax.document,
                            size: 18,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Pilih jenis ticket',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      items: _ticketTypes.map((type) {
                        final code = type['code'] as String;
                        return DropdownMenuItem<String>(
                          value: code,
                          child: Row(
                            children: [
                              Icon(
                                _typeIcons[code] ?? Iconsax.document,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                type['name'] as String,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedType = value);
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Silakan pilih jenis ticket';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Description
                    Text(
                      'Deskripsi Gangguan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 5,
                      style: const TextStyle(fontFamily: 'Poppins'),
                      decoration: InputDecoration(
                        hintText: 'Jelaskan kondisi gangguan secara detail...',
                        hintStyle: const TextStyle(fontSize: 13),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Deskripsi tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Work Time Section
                    Text(
                      'Waktu Pengerjaan (Opsional)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Jam Mulai',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _startTimeController,
                                readOnly: true,
                                style: const TextStyle(fontFamily: 'Poppins'),
                                decoration: InputDecoration(
                                  hintText: 'Pilih jam mulai',
                                  hintStyle: const TextStyle(fontSize: 13),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  suffixIcon: Icon(Iconsax.clock, size: 20, color: AppColors.primary),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                ),
                                onTap: () => _selectTime(context, true),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Jam Selesai',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _endTimeController,
                                readOnly: true,
                                style: const TextStyle(fontFamily: 'Poppins'),
                                decoration: InputDecoration(
                                  hintText: 'Pilih jam selesai',
                                  hintStyle: const TextStyle(fontSize: 13),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  suffixIcon: Icon(Iconsax.clock, size: 20, color: AppColors.primary),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                ),
                                onTap: () => _selectTime(context, false),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Estimasi durasi pekerjaan dalam jam dan menit',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'Poppins',
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Engineer Assignment (Optional)
                    Text(
                      'Assign ke Engineer (Opsional)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        hintText: 'Pilih Engineer (Opsional)',
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      items: _engineers.map((engineer) {
                        return DropdownMenuItem<int>(
                          value: engineer['id'] as int,
                          child: Text(
                            '${engineer['name']} (${(engineer['role'] as String).toUpperCase()})',
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedEngineerId = value);
                      },
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Biarkan kosong jika ingin di-assign nanti oleh RSS/Manager',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'Poppins',
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _createTicket,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Buat Tiket',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                                color: Colors.white,
                              ),
                            ),
                    ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
