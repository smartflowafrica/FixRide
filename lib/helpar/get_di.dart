import 'package:carlinknew/controller/cardetails_controller.dart';
import 'package:carlinknew/controller/carpurchase_controller.dart';
import 'package:carlinknew/controller/favorite_controller.dart';
import 'package:carlinknew/controller/home_controller.dart';
import 'package:carlinknew/controller/login_controller.dart';
import 'package:carlinknew/controller/signup_controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

init() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  Get.lazyPut(() => sharedPreferences);
  Get.lazyPut(() => LoginController());
  Get.lazyPut(() => SignUpController());
  Get.lazyPut(() => HomeController());
  Get.lazyPut(() => FavoriteController());
  Get.lazyPut(() => CardetailsController());
  Get.lazyPut(() => CarPurchaseController());
  Get.lazyPut(() => ExploreController());
  Get.lazyPut(() => BookdetailController());
}
