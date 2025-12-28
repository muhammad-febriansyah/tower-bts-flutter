import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Load dari .env file
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:8000';
  static String get apiUrl => dotenv.env['API_URL'] ?? 'http://127.0.0.1:8000/api';

  // Endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String logoutAll = '/logout-all';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // Tickets
  static const String tickets = '/tickets';
  static const String ticketsDashboard = '/tickets/dashboard';
  static String ticketDetail(int id) => '/tickets/$id';
  static String ticketStatus(int id) => '/tickets/$id/status';
  static String ticketPhotos(int id) => '/tickets/$id/photos';
  static String ticketAssign(int id) => '/tickets/$id/assign';

  // Sites
  static const String sites = '/sites';
  static const String sitesAreas = '/sites/areas';
  static const String sitesRegions = '/sites/regions';
  static String siteDetail(int id) => '/sites/$id';

  // Budget Requests
  static const String budgetRequests = '/budget-requests';
  static const String budgetRequestsDashboard = '/budget-requests/dashboard';
  static String budgetRequestDetail(int id) => '/budget-requests/$id';

  // MBP (Mobile Backup Power)
  static const String mbpRequests = '/mbp';
  static const String mbpDashboard = '/mbp/dashboard';
  static String mbpDetail(int id) => '/mbp/$id';
  static String mbpStatus(int id) => '/mbp/$id/status';
  static String mbpDocumentation(int id) => '/mbp/$id/documentation';
  static String mbpAssign(int id) => '/mbp/$id/assign';

  // Notifications
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static const String notificationsRecent = '/notifications/recent';
  static const String notificationsMarkAllRead = '/notifications/mark-all-read';
  static String notificationMarkAsRead(int id) => '/notifications/$id/read';
  static String notificationDelete(int id) => '/notifications/$id';

  // Helper untuk build full URL
  static String fullUrl(String endpoint) => apiUrl + endpoint;

  // Helper untuk build image URL (storage)
  static String imageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return baseUrl + path;
  }
}
