import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  static const _tokenKey = 'auth_token';

  // Save token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Get token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Delete token
  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Build headers
  static Future<Map<String, String>> _buildHeaders({bool includeAuth = true}) async {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (includeAuth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // GET request
  static Future<Map<String, dynamic>> get(String endpoint, {bool requireAuth = true}) async {
    try {
      final url = Uri.parse(ApiConfig.fullUrl(endpoint));
      final headers = await _buildHeaders(includeAuth: requireAuth);

      final response = await http.get(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      return {'error': true, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // POST request
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requireAuth = true,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.fullUrl(endpoint));
      final headers = await _buildHeaders(includeAuth: requireAuth);

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'error': true, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // PUT request
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool requireAuth = true,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.fullUrl(endpoint));
      final headers = await _buildHeaders(includeAuth: requireAuth);

      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'error': true, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // DELETE request
  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requireAuth = true,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.fullUrl(endpoint));
      final headers = await _buildHeaders(includeAuth: requireAuth);

      final response = await http.delete(
        url,
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      return {'error': true, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Upload file dengan multipart
  static Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    Map<String, File?> files, {
    Map<String, String>? fields,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.fullUrl(endpoint));
      final token = await getToken();

      var request = http.MultipartRequest('POST', url);

      // Add headers
      request.headers['Accept'] = 'application/json';
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add files
      for (var entry in files.entries) {
        if (entry.value != null) {
          request.files.add(
            await http.MultipartFile.fromPath(entry.key, entry.value!.path),
          );
        }
      }

      // Add fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      return {'error': true, 'message': 'Upload error: ${e.toString()}'};
    }
  }

  // Handle response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final body = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'error': false, 'data': body, 'statusCode': response.statusCode};
      } else {
        return {
          'error': true,
          'message': body['message'] ?? 'Request failed',
          'statusCode': response.statusCode,
          'data': body,
        };
      }
    } catch (e) {
      return {
        'error': true,
        'message': 'Failed to parse response: ${e.toString()}',
        'statusCode': response.statusCode,
      };
    }
  }

  // Auth APIs
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final result = await post(
      ApiConfig.login,
      {
        'email': email,
        'password': password,
        'device_name': 'flutter_app',
      },
      requireAuth: false,
    );

    if (!result['error'] && result['data']['token'] != null) {
      await saveToken(result['data']['token']);
    }

    return result;
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String noHp,
    required String role,
  }) async {
    return await post(
      ApiConfig.register,
      {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'no_hp': noHp,
        'role': role,
      },
      requireAuth: false,
    );
  }

  static Future<Map<String, dynamic>> logout() async {
    final result = await post(ApiConfig.logout, {});
    await deleteToken();
    return result;
  }

  static Future<Map<String, dynamic>> logoutAll() async {
    final result = await post(ApiConfig.logoutAll, {});
    await deleteToken();
    return result;
  }

  static Future<Map<String, dynamic>> getProfile() async {
    return await get(ApiConfig.profile);
  }

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    return await put(ApiConfig.profile, data);
  }

  // Settings API
  static Future<Map<String, dynamic>> getSettings() async {
    return await get(ApiConfig.settings, requireAuth: false);
  }

  // Tickets APIs
  static Future<Map<String, dynamic>> getTickets({String? status, String? priority}) async {
    String endpoint = ApiConfig.tickets;
    List<String> params = [];

    if (status != null) params.add('status=$status');
    if (priority != null) params.add('priority=$priority');

    if (params.isNotEmpty) {
      endpoint += '?${params.join('&')}';
    }

    return await get(endpoint);
  }

  static Future<Map<String, dynamic>> createTicket({
    required int siteId,
    required String title,
    required String description,
    required String priority,
    required String type,
    int? engineerId,
    String? workStartTime,
    String? workEndTime,
  }) async {
    return await post(ApiConfig.tickets, {
      'site_id': siteId,
      'judul_masalah': title,
      'deskripsi_masalah': description,
      'priority': priority,
      'jenis_tt': type,
      if (engineerId != null) 'engineer_id': engineerId,
      if (workStartTime != null) 'work_start_time': workStartTime,
      if (workEndTime != null) 'work_end_time': workEndTime,
    });
  }

  static Future<Map<String, dynamic>> assignTicket(
    int ticketId,
    int engineerId,
  ) async {
    return await post(ApiConfig.ticketAssign(ticketId), {
      'engineer_id': engineerId,
    });
  }

  static Future<Map<String, dynamic>> getTicketsDashboard() async {
    return await get(ApiConfig.ticketsDashboard);
  }

  static Future<Map<String, dynamic>> getTicketDetail(int id) async {
    return await get(ApiConfig.ticketDetail(id));
  }

  static Future<Map<String, dynamic>> updateTicketStatus(
    int id,
    String status, {
    String? catatanEngineer,
    String? startedAt,
    String? completedAt,
  }) async {
    return await post(ApiConfig.ticketStatus(id), {
      'status': status,
      if (catatanEngineer != null) 'catatan_engineer': catatanEngineer,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  static Future<Map<String, dynamic>> startTicketWork(int id) async {
    return await post('/tickets/$id/start-work', {});
  }

  static Future<Map<String, dynamic>> uploadTicketPhotos(
    int id, {
    File? fotoBefore,
    File? fotoAfter,
  }) async {
    return await uploadFile(
      ApiConfig.ticketPhotos(id),
      {
        'foto_before': fotoBefore,
        'foto_after': fotoAfter,
      },
    );
  }

  // Sites APIs
  static Future<Map<String, dynamic>> getSites({
    String? search,
    String? area,
    String? region,
    String? status,
  }) async {
    String endpoint = ApiConfig.sites;
    List<String> params = [];

    if (search != null) params.add('search=$search');
    if (area != null) params.add('area=$area');
    if (region != null) params.add('region=$region');
    if (status != null) params.add('status=$status');

    if (params.isNotEmpty) {
      endpoint += '?${params.join('&')}';
    }

    return await get(endpoint);
  }

  static Future<Map<String, dynamic>> getSiteDetail(int id) async {
    return await get(ApiConfig.siteDetail(id));
  }

  static Future<Map<String, dynamic>> getSitesAreas() async {
    return await get(ApiConfig.sitesAreas);
  }

  static Future<Map<String, dynamic>> getSitesRegions() async {
    return await get(ApiConfig.sitesRegions);
  }

  // Budget Requests APIs
  static Future<Map<String, dynamic>> getBudgetRequests({String? status}) async {
    String endpoint = ApiConfig.budgetRequests;
    if (status != null) {
      endpoint += '?status=$status';
    }
    return await get(endpoint);
  }

  static Future<Map<String, dynamic>> getBudgetRequestsDashboard() async {
    return await get(ApiConfig.budgetRequestsDashboard);
  }

  static Future<Map<String, dynamic>> getBudgetRequestDetail(int id) async {
    return await get(ApiConfig.budgetRequestDetail(id));
  }

  static Future<Map<String, dynamic>> createBudgetRequest({
    required int troubleTicketId,
    required String specification,
    required double estimatedCost,
    List<File>? photos,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.fullUrl(ApiConfig.budgetRequests));
      final token = await getToken();

      var request = http.MultipartRequest('POST', url);

      // Add headers
      request.headers['Accept'] = 'application/json';
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add fields
      request.fields['trouble_ticket_id'] = troubleTicketId.toString();
      request.fields['detil_spesifikasi'] = specification;
      request.fields['estimasi_biaya'] = estimatedCost.toString();

      // Add photos
      if (photos != null && photos.isNotEmpty) {
        for (var photo in photos) {
          request.files.add(
            await http.MultipartFile.fromPath('photos[]', photo.path),
          );
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      return {'error': true, 'message': 'Upload error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> createLumpsumBudgetRequest({
    required int lumpsumItemId,
    required int quantity,
    required String specification,
    List<File>? photos,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.fullUrl('${ApiConfig.budgetRequests}/lumpsum'));
      final token = await getToken();

      var request = http.MultipartRequest('POST', url);

      // Add headers
      request.headers['Accept'] = 'application/json';
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add fields
      request.fields['lumpsum_item_id'] = lumpsumItemId.toString();
      request.fields['quantity'] = quantity.toString();
      request.fields['detil_spesifikasi'] = specification;

      // Add photos
      if (photos != null && photos.isNotEmpty) {
        for (var photo in photos) {
          request.files.add(
            await http.MultipartFile.fromPath('photos[]', photo.path),
          );
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      return {'error': true, 'message': 'Upload error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> createShoppingListBudgetRequest({
    required int shoppingListItemId,
    required int quantity,
    String? specification,
    List<File>? photos,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.fullUrl('${ApiConfig.budgetRequests}/shopping-list'));
      final token = await getToken();

      var request = http.MultipartRequest('POST', url);

      // Add headers
      request.headers['Accept'] = 'application/json';
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add fields
      request.fields['shopping_list_item_id'] = shoppingListItemId.toString();
      request.fields['quantity'] = quantity.toString();
      if (specification != null && specification.isNotEmpty) {
        request.fields['detil_spesifikasi'] = specification;
      }

      // Add photos
      if (photos != null && photos.isNotEmpty) {
        for (var photo in photos) {
          request.files.add(
            await http.MultipartFile.fromPath('photos[]', photo.path),
          );
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      return {'error': true, 'message': 'Upload error: ${e.toString()}'};
    }
  }

  // MBP APIs
  static Future<Map<String, dynamic>> getMbpRequests({String? status}) async {
    String endpoint = ApiConfig.mbpRequests;
    if (status != null) {
      endpoint += '?status=$status';
    }
    return await get(endpoint);
  }

  static Future<Map<String, dynamic>> createMbp({
    required int siteId,
    required String startDate,
    required String endDate,
    String? estimatedBudget,
    String? notes,
  }) async {
    return await post(ApiConfig.mbpRequests, {
      'site_id': siteId,
      'start_date': startDate,
      'end_date': endDate,
      if (estimatedBudget != null && estimatedBudget.isNotEmpty) 'estimated_budget': estimatedBudget,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
  }

  static Future<Map<String, dynamic>> assignMbp(
    int mbpId,
    int engineerId,
  ) async {
    return await post(ApiConfig.mbpAssign(mbpId), {
      'engineer_id': engineerId,
    });
  }

  static Future<Map<String, dynamic>> getMbpDashboard() async {
    return await get(ApiConfig.mbpDashboard);
  }

  static Future<Map<String, dynamic>> getMbpDetail(int id) async {
    return await get(ApiConfig.mbpDetail(id));
  }

  static Future<Map<String, dynamic>> updateMbpStatus(
    int id,
    String status, {
    double? latitudeSetup,
    double? longitudeSetup,
    String? catatanEngineer,
    String? setupAt,
    String? completedAt,
  }) async {
    return await post(ApiConfig.mbpStatus(id), {
      'status': status,
      if (latitudeSetup != null) 'latitude_setup': latitudeSetup,
      if (longitudeSetup != null) 'longitude_setup': longitudeSetup,
      if (catatanEngineer != null) 'catatan_engineer': catatanEngineer,
      if (setupAt != null) 'setup_at': setupAt,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  static Future<Map<String, dynamic>> startMbpWork(
    int id, {
    double? latitudeSetup,
    double? longitudeSetup,
  }) async {
    return await post('/mbp/$id/start-work', {
      if (latitudeSetup != null) 'latitude_setup': latitudeSetup,
      if (longitudeSetup != null) 'longitude_setup': longitudeSetup,
    });
  }

  static Future<Map<String, dynamic>> uploadMbpDocumentation(
    int id,
    List<File> photos,
  ) async {
    return await uploadFile(
      ApiConfig.mbpDocumentation(id),
      {
        for (int i = 0; i < photos.length; i++) 'photos[$i]': photos[i],
      },
    );
  }

  // Users APIs (for engineer assignment)
  static Future<Map<String, dynamic>> getEngineers() async {
    return await get('/users/engineers');
  }

  // Ticket Types APIs
  static Future<Map<String, dynamic>> getTicketTypes() async {
    return await get('/ticket-types');
  }

  // Notifications APIs
  static Future<Map<String, dynamic>> getNotifications({int page = 1, int perPage = 20}) async {
    return await get('${ApiConfig.notifications}?page=$page&per_page=$perPage');
  }

  static Future<Map<String, dynamic>> getUnreadNotificationsCount() async {
    return await get(ApiConfig.notificationsUnreadCount);
  }

  static Future<Map<String, dynamic>> getRecentNotifications({int limit = 10}) async {
    return await get('${ApiConfig.notificationsRecent}?limit=$limit');
  }

  static Future<Map<String, dynamic>> markNotificationAsRead(int id) async {
    return await post(ApiConfig.notificationMarkAsRead(id), {});
  }

  static Future<Map<String, dynamic>> markAllNotificationsAsRead() async {
    return await post(ApiConfig.notificationsMarkAllRead, {});
  }

  static Future<Map<String, dynamic>> deleteNotification(int id) async {
    return await delete(ApiConfig.notificationDelete(id));
  }

  // Lumpsum Items APIs
  static Future<Map<String, dynamic>> getLumpsumItems({String? regional}) async {
    String endpoint = '/lumpsum-items';
    if (regional != null && regional.isNotEmpty) {
      endpoint += '?regional=$regional';
    }
    return await get(endpoint);
  }

  static Future<Map<String, dynamic>> getLumpsumItem(int id) async {
    return await get('/lumpsum-items/$id');
  }

  // Shopping List Items APIs
  static Future<Map<String, dynamic>> getShoppingListItems({
    String? regional,
    String? search,
  }) async {
    String endpoint = '/shopping-list-items';
    List<String> params = [];

    if (regional != null && regional.isNotEmpty) {
      params.add('regional=$regional');
    }
    if (search != null && search.isNotEmpty) {
      params.add('search=$search');
    }

    if (params.isNotEmpty) {
      endpoint += '?${params.join('&')}';
    }

    return await get(endpoint);
  }

  static Future<Map<String, dynamic>> getShoppingListItem(int id) async {
    return await get('/shopping-list-items/$id');
  }

  static Future<Map<String, dynamic>> getShoppingListRegionals() async {
    return await get('/shopping-list-items/regionals');
  }
}
