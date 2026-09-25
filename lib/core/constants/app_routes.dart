class AppRoutes {
  // Public Routes
  static const String home = '/';
  static const String cars = '/cars';
  static const String carDetail = '/car/:id';
  static const String dealers = '/dealers';
  static const String dealerDetail = '/dealer/:id';
  static const String pricing = '/pricing';

  // Auth Routes
  static const String dealerLogin = '/login';
  static const String dealerRegister = '/register';
  static const String adminLogin = '/admin/login';

  // Dealer SaaS Dashboard Routes
  static const String dealerDashboard = '/dealer/dashboard';
  static const String dealerCars = '/dealer/cars';
  static const String dealerAddCar = '/dealer/cars/add';
  static const String dealerEditCar = '/dealer/cars/edit/:id';
  static const String dealerEnquiries = '/dealer/enquiries';
  static const String dealerSubscription = '/dealer/subscription';
  static const String dealerProfile = '/dealer/profile';

  // Super Admin Portal Routes
  static const String adminDashboard = '/admin';
  static const String adminDealers = '/admin/dealers';
  static const String adminCars = '/admin/cars';
  static const String adminSubscriptions = '/admin/subscriptions';
  static const String adminPlans = '/admin/plans';
  static const String adminEnquiries = '/admin/enquiries';
  static const String adminSettings = '/admin/settings';
}
