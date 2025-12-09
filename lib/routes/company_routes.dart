import 'package:get/get.dart';
import '../screen/company/company_login.dart';
import '../screen/company/company_registration.dart';
import '../screen/company/company_dashboard.dart';
import '../screen/company/company_car_list.dart';
import '../screen/company/company_add_car.dart';
import '../screen/company/company_booking_list.dart';
import '../screen/company/company_earnings.dart';
import '../screen/company/company_profile.dart';
import '../controller/company_auth_controller.dart';
import '../controller/company_dashboard_controller.dart';
import '../controller/company_car_controller.dart';
import '../controller/company_payout_controller.dart';
import '../model/company_model.dart';

class CompanyRoutes {
  static const String login = '/company-login';
  static const String register = '/company-register';
  static const String dashboard = '/company-dashboard';
  static const String carList = '/company-cars';
  static const String addCar = '/company-add-car';
  static const String bookings = '/company-bookings';
  static const String earnings = '/company-earnings';
  static const String profile = '/company-profile';

  static List<GetPage> routes = [
    GetPage(
      name: login,
      page: () => const CompanyLoginScreen(),
      binding: CompanyBindings(),
    ),
    GetPage(
      name: register,
      page: () => const CompanyRegistrationScreen(),
      binding: CompanyBindings(),
    ),
    // Dashboard requires company data passed as argument
    GetPage(
      name: dashboard,
      page: () {
        final Company company = Get.arguments as Company;
        return CompanyDashboardScreen(company: company);
      },
      binding: CompanyBindings(),
    ),
    GetPage(
      name: carList,
      page: () {
        final int companyId = Get.arguments as int;
        return CompanyCarListScreen(companyId: companyId);
      },
      binding: CompanyBindings(),
    ),
    GetPage(
      name: addCar,
      page: () {
        final Map<String, dynamic> args = Get.arguments as Map<String, dynamic>;
        return CompanyAddCarScreen(
          companyId: args['companyId'] as int,
          car: args['car'],
        );
      },
      binding: CompanyBindings(),
    ),
    GetPage(
      name: bookings,
      page: () {
        final int companyId = Get.arguments as int;
        return CompanyBookingListScreen(companyId: companyId);
      },
      binding: CompanyBindings(),
    ),
    GetPage(
      name: earnings,
      page: () {
        final int companyId = Get.arguments as int;
        return CompanyEarningsScreen(companyId: companyId);
      },
      binding: CompanyBindings(),
    ),
    GetPage(
      name: profile,
      page: () {
        final Company company = Get.arguments as Company;
        return CompanyProfileScreen(company: company);
      },
      binding: CompanyBindings(),
    ),
  ];
}

class CompanyBindings extends Bindings {
  @override
  void dependencies() {
    // Auth controller - always needed
    Get.lazyPut<CompanyAuthController>(() => CompanyAuthController(), fenix: true);
    
    // Dashboard controller
    Get.lazyPut<CompanyDashboardController>(() => CompanyDashboardController(), fenix: true);
    
    // Car controller
    Get.lazyPut<CompanyCarController>(() => CompanyCarController(), fenix: true);
    
    // Payout controller
    Get.lazyPut<CompanyPayoutController>(() => CompanyPayoutController(), fenix: true);
  }
}

/// Initialize company controllers for app startup
void initCompanyControllers() {
  Get.put<CompanyAuthController>(CompanyAuthController(), permanent: true);
}
