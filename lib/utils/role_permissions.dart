class RolePermissions {
  // Define role constants
  static const String engineer = 'engineer';
  static const String mitra = 'mitra';
  static const String rss = 'rss';
  static const String managerOperasional = 'manager_operasional_rss';
  static const String hdRss = 'hd_rss';
  static const String admin = 'admin';

  // Field roles (engineer & mitra)
  static const List<String> fieldRoles = [engineer, mitra];

  // Management roles (rss, manager, hd, admin)
  static const List<String> managementRoles = [rss, managerOperasional, hdRss, admin];

  // Check if user can access tickets page
  static bool canAccessTickets(String? role) {
    if (role == null) return false;
    // All users can access tickets (but will see filtered data)
    return true;
  }

  // Check if user can access sites page
  static bool canAccessSites(String? role) {
    if (role == null) return false;
    // All users can access sites
    return true;
  }

  // Check if user can access budget requests page
  static bool canAccessBudgetRequests(String? role) {
    if (role == null) return false;
    // Only field roles (engineer & mitra) can access budget requests
    return fieldRoles.contains(role);
  }

  // Check if user can create tickets
  static bool canCreateTickets(String? role) {
    if (role == null) return false;
    // Only HD RSS can create tickets
    return role == hdRss;
  }

  // Check if user can update ticket status
  static bool canUpdateTicketStatus(String? role) {
    if (role == null) return false;
    // Only field roles can update tickets
    return fieldRoles.contains(role);
  }

  // Check if user can create budget requests
  static bool canCreateBudgetRequests(String? role) {
    if (role == null) return false;
    // Only field roles can create budget requests
    return fieldRoles.contains(role);
  }

  // Check if user can approve budget requests
  static bool canApproveBudgetRequests(String? role) {
    if (role == null) return false;
    // Only management roles can approve
    return managementRoles.contains(role);
  }

  // Check if user can access MBP
  static bool canAccessMbp(String? role) {
    if (role == null) return false;
    // All roles can access MBP (engineers see their assigned MBP, others see all)
    return [engineer, mitra, hdRss, rss, managerOperasional, admin].contains(role);
  }

  // Check if user can create MBP
  static bool canCreateMbp(String? role) {
    if (role == null) return false;
    // Only HD RSS can create MBP (based on role_features_summary.md)
    return role == hdRss;
  }

  // Check if user can assign tickets
  static bool canAssignTickets(String? role) {
    if (role == null) return false;
    // RSS, Manager Ops, and HD RSS can assign tickets
    return [rss, managerOperasional, hdRss].contains(role);
  }

  // Check if user can assign MBP
  static bool canAssignMbp(String? role) {
    if (role == null) return false;
    // Only HD RSS can assign MBP
    return role == hdRss;
  }

  // Check if user can review/approve budget requests
  static bool canReviewBudgetRequests(String? role) {
    if (role == null) return false;
    // RSS and Manager Ops can review budget
    return [rss, managerOperasional].contains(role);
  }

  // Check if user can transfer budget
  static bool canTransferBudget(String? role) {
    if (role == null) return false;
    // RSS and Manager Ops can transfer budget
    return [rss, managerOperasional].contains(role);
  }

  // Check if user can manage special teams
  static bool canManageSpecialTeams(String? role) {
    if (role == null) return false;
    // Only Manager Operasional can manage special teams
    return role == managerOperasional;
  }

  // Check if user can access Aset Lumpsum (Preventive Maintenance)
  static bool canAccessAsetLumpsum(String? role) {
    if (role == null) return false;
    // Only field workers can access asset documentation
    return fieldRoles.contains(role);
  }

  // Check if user can access Budget Operasional
  static bool canAccessBudgetOperasional(String? role) {
    if (role == null) return false;
    // Only field workers can view their operational budget
    return fieldRoles.contains(role);
  }

  // Check if user can access Budget Realisasi
  static bool canAccessBudgetRealisasi(String? role) {
    if (role == null) return false;
    // Only field workers can record budget realization
    return fieldRoles.contains(role);
  }

  // Check if user can view all tickets (management view)
  static bool canViewAllTickets(String? role) {
    if (role == null) return false;
    // Management roles can view all tickets
    return managementRoles.contains(role);
  }

  // Check if user can view all budget requests (management view)
  static bool canViewAllBudgetRequests(String? role) {
    if (role == null) return false;
    // RSS and Manager Ops can view all budget requests
    return [rss, managerOperasional].contains(role);
  }

  // Check if user is field worker
  static bool isFieldWorker(String? role) {
    if (role == null) return false;
    return fieldRoles.contains(role);
  }

  // Check if user is management
  static bool isManagement(String? role) {
    if (role == null) return false;
    return managementRoles.contains(role);
  }

  // Get visible menu items for role
  static List<String> getVisibleMenus(String? role) {
    if (role == null) return [];

    List<String> menus = ['dashboard', 'tickets', 'sites'];

    // Add budget menu only for field roles
    if (canAccessBudgetRequests(role)) {
      menus.add('budget');
    }

    // Add MBP menu for all authorized roles
    if (canAccessMbp(role)) {
      menus.add('mbp');
    }

    menus.add('profile');

    return menus;
  }

  // Get menu index mapping for role
  static Map<String, int> getMenuIndexMapping(String? role) {
    final visibleMenus = getVisibleMenus(role);
    Map<String, int> mapping = {};

    for (int i = 0; i < visibleMenus.length; i++) {
      mapping[visibleMenus[i]] = i;
    }

    return mapping;
  }
}
