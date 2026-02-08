import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/trouble_ticket.dart';
import '../models/user.dart';
import '../config/app_strings.dart';
import '../utils/role_permissions.dart';
import 'ticket_detail_page.dart';
import 'create_ticket_page.dart';

class TicketsPage extends StatefulWidget {
  const TicketsPage({super.key});

  @override
  State<TicketsPage> createState() => TicketsPageState();
}

class TicketsPageState extends State<TicketsPage> {
  List<TroubleTicket> _tickets = [];
  bool _isLoading = true;
  String? _selectedStatus;
  String? _selectedPriority;
  User? _currentUser;

  final List<String> _statuses = [
    'assigned',
    'in_progress',
    'pending',
    'completed',
    'cancelled',
  ];

  final List<String> _priorities = ['low', 'medium', 'high', 'critical'];

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'assigned':
        return 'Ditugaskan';
      case 'in_progress':
        return 'Dalam Proses';
      case 'pending':
        return 'Tertunda';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return 'Rendah';
      case 'medium':
        return 'Sedang';
      case 'high':
        return 'Tinggi';
      case 'critical':
        return 'Kritis';
      default:
        return priority;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadTickets();
  }

  Future<void> _loadUser() async {
    try {
      final result = await ApiService.getProfile();
      if (!mounted) return;
      if (!result['error']) {
        setState(() {
          _currentUser = User.fromJson(result['data']['user']);
        });
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _loadTickets() async {
    setState(() => _isLoading = true);

    try {
      final result = await ApiService.getTickets(
        status: _selectedStatus,
        priority: _selectedPriority,
      );

      if (!mounted) return;

      if (result['error']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? AppStrings.failedToLoad)),
        );
      } else {
        final List<dynamic> ticketsData = result['data']['tickets'] ?? [];
        setState(() {
          _tickets = ticketsData.map((json) => TroubleTicket.fromJson(json)).toList();
        });
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

  void _showFilters() {
    String? tempStatus = _selectedStatus;
    String? tempPriority = _selectedPriority;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.filterTickets,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        IconButton(
                          icon: Icon(Iconsax.close_circle),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Status Filter
                    Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterChip(
                          label: 'Semua',
                          isSelected: tempStatus == null,
                          onTap: () {
                            setModalState(() => tempStatus = null);
                          },
                        ),
                        ..._statuses.map((status) => _buildFilterChip(
                              label: _getStatusLabel(status),
                              isSelected: tempStatus == status,
                              color: _getStatusColor(status),
                              onTap: () {
                                setModalState(() => tempStatus = status);
                              },
                            )),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Priority Filter
                    Text(
                      'Prioritas',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterChip(
                          label: 'Semua',
                          isSelected: tempPriority == null,
                          onTap: () {
                            setModalState(() => tempPriority = null);
                          },
                        ),
                        ..._priorities.map((priority) => _buildFilterChip(
                              label: _getPriorityLabel(priority),
                              isSelected: tempPriority == priority,
                              color: _getPriorityColor(priority),
                              onTap: () {
                                setModalState(() => tempPriority = priority);
                              },
                            )),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setModalState(() {
                                tempStatus = null;
                                tempPriority = null;
                              });
                              setState(() {
                                _selectedStatus = null;
                                _selectedPriority = null;
                              });
                              Navigator.pop(context);
                              _loadTickets();
                            },
                            icon: Icon(Iconsax.refresh),
                            label: const Text('Atur Ulang'),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedStatus = tempStatus;
                                _selectedPriority = tempPriority;
                              });
                              Navigator.pop(context);
                              _loadTickets();
                            },
                            icon: Icon(Iconsax.tick_circle),
                            label: const Text('Terapkan'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? const Color(0xFF2E7D32))
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (color ?? const Color(0xFF2E7D32))
                : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontFamily: 'Poppins',
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow[700]!;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'assigned':
        return Colors.orange;
      case 'pending':
        return Colors.yellow[700]!;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Public method to refresh tickets (can be called from parent)
  void refreshTickets() {
    _loadTickets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: RefreshIndicator(
        onRefresh: _loadTickets,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _tickets.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.box, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.noTicketsFound,
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: _tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = _tickets[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                        ),
                        child: InkWell(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TicketDetailPage(ticketId: ticket.id),
                              ),
                            );
                            _loadTickets();
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: _getPriorityColor(ticket.priority).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Iconsax.receipt,
                                        size: 20,
                                        color: _getPriorityColor(ticket.priority),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ticket.ticketNumber,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          if (ticket.createdAt != null)
                                            Row(
                                              children: [
                                                Icon(Iconsax.clock, size: 12, color: Colors.grey[500]),
                                                const SizedBox(width: 4),
                                                Text(
                                                  DateFormat('dd MMM yyyy').format(
                                                    DateTime.parse(ticket.createdAt!),
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getPriorityColor(ticket.priority),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _getPriorityLabel(ticket.priority),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  ticket.title,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (ticket.site != null) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Iconsax.location, size: 16, color: Colors.grey[600]),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            ticket.site!.siteName,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[700],
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(ticket.status).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(ticket.status),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            _getStatusLabel(ticket.status),
                                            style: TextStyle(
                                              color: _getStatusColor(ticket.status),
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      Iconsax.arrow_right_3,
                                      size: 14,
                                      color: Colors.grey[400],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget? _buildFAB() {
    final canCreate = RolePermissions.canCreateTickets(_currentUser?.role);

    // If can create, show multiple FABs
    if (canCreate) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'filter',
            onPressed: _showFilters,
            child: const Icon(Iconsax.filter),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'create',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateTicketPage(),
                ),
              );
              if (result == true) {
                _loadTickets();
              }
            },
            icon: const Icon(Iconsax.add),
            label: const Text('Buat Ticket'),
          ),
        ],
      );
    }

    // Default: just filter button
    return FloatingActionButton(
      onPressed: _showFilters,
      child: const Icon(Iconsax.filter),
    );
  }
}
