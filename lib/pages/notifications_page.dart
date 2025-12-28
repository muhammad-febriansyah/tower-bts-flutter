import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/notification.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  int _totalPages = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _currentPage < _totalPages) {
        _loadMore();
      }
    }
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);

    try {
      final result = await ApiService.getNotifications(page: 1);

      if (!mounted) return;

      if (!result['error']) {
        final List<dynamic> notificationsData =
            result['data']['notifications'] ?? [];
        final meta = result['data']['meta'];

        setState(() {
          _notifications = notificationsData
              .map((json) => NotificationModel.fromJson(json))
              .toList();
          _currentPage = meta['current_page'] ?? 1;
          _totalPages = meta['last_page'] ?? 1;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    setState(() => _isLoadingMore = true);

    try {
      final result = await ApiService.getNotifications(page: _currentPage + 1);

      if (!mounted) return;

      if (!result['error']) {
        final List<dynamic> notificationsData =
            result['data']['notifications'] ?? [];
        final meta = result['data']['meta'];

        setState(() {
          _notifications.addAll(
            notificationsData
                .map((json) => NotificationModel.fromJson(json))
                .toList(),
          );
          _currentPage = meta['current_page'] ?? _currentPage;
          _totalPages = meta['last_page'] ?? _totalPages;
          _isLoadingMore = false;
        });
      } else {
        setState(() => _isLoadingMore = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _markAsRead(int id, int index) async {
    try {
      final result = await ApiService.markNotificationAsRead(id);

      if (!mounted) return;

      if (!result['error']) {
        setState(() {
          _notifications[index] = NotificationModel(
            id: _notifications[index].id,
            type: _notifications[index].type,
            title: _notifications[index].title,
            message: _notifications[index].message,
            icon: _notifications[index].icon,
            url: _notifications[index].url,
            data: _notifications[index].data,
            isRead: true,
            readAt: DateTime.now().toString(),
            createdAt: _notifications[index].createdAt,
          );
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final result = await ApiService.markAllNotificationsAsRead();

      if (!mounted) return;

      if (!result['error']) {
        setState(() {
          _notifications = _notifications.map((notif) {
            return NotificationModel(
              id: notif.id,
              type: notif.type,
              title: notif.title,
              message: notif.message,
              icon: notif.icon,
              url: notif.url,
              data: notif.data,
              isRead: true,
              readAt: DateTime.now().toString(),
              createdAt: notif.createdAt,
            );
          }).toList();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Semua notifikasi ditandai sudah dibaca'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> _deleteNotification(int id, int index) async {
    try {
      final result = await ApiService.deleteNotification(id);

      if (!mounted) return;

      if (!result['error']) {
        setState(() {
          _notifications.removeAt(index);
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Notifikasi dihapus')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  IconData _getNotificationIcon(String? icon) {
    switch (icon) {
      case 'ticket':
        return Iconsax.ticket;
      case 'money':
        return Iconsax.wallet;
      case 'transfer':
        return Iconsax.card_send;
      case 'mbp':
        return Iconsax.battery_charging;
      default:
        return Iconsax.notification;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'ticket_assigned':
        return Colors.blue;
      case 'budget_request':
        return Colors.orange;
      case 'budget_approved':
        return Colors.green;
      case 'budget_rejected':
        return Colors.red;
      case 'budget_transfer':
        return Colors.purple;
      case 'mbp_assigned':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Tandai Semua',
                style: TextStyle(color: Colors.white),
              ),
            ),
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.notification_bing,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada notifikasi',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _notifications.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _notifications.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final notification = _notifications[index];
                  final notifColor = _getNotificationColor(notification.type);

                  return Dismissible(
                    key: Key(notification.id.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Iconsax.trash, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      _deleteNotification(notification.id, index);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: notification.isRead
                            ? Colors.white
                            : notifColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: notification.isRead
                              ? Colors.grey.withValues(alpha: 0.2)
                              : notifColor.withValues(alpha: 0.3),
                          width: notification.isRead ? 1 : 2,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: notifColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getNotificationIcon(notification.icon),
                            color: notifColor,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: notification.isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              notification.message,
                              style: const TextStyle(fontSize: 13),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              DateFormat(
                                'dd MMM yyyy, HH:mm',
                              ).format(DateTime.parse(notification.createdAt)),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        trailing: !notification.isRead
                            ? Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: notifColor,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : null,
                        onTap: () {
                          if (!notification.isRead) {
                            _markAsRead(notification.id, index);
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
