import 'package:get/get.dart';

/// Controller for managing bottom navigation state
class HomeController extends GetxController {
  final RxInt currentIndex = 0.obs;

  /// Change to the specified tab
  void changeTab(int index) {
    currentIndex.value = index;
  }

  /// Convenience methods for navigating to specific tabs
  void goToHome() => changeTab(0);
  void goToCategories() => changeTab(1);
  void goToFavorites() => changeTab(2);

  /// Optional getter if you want to access the value directly
  int get tab => currentIndex.value;
}
