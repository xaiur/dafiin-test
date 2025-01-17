import 'package:flutter_application_53/provider/User_provider.dart';
import 'package:get/get.dart';

class ControllerC extends GetxController with StateMixin<Map<String, dynamic>> {
  void getData() {
    try {
      UserProvider().getUser().then(
        (response) {
          if (response.statusCode == 200) {
            final data = response.body["data"] as Map<String, dynamic>;
            change(
            data, 
              status: RxStatus.success(),
            );
          }
        },
        onError: (_) {
          change(null, status: RxStatus.error("Tidak dapat data dari API"));
        },
      );
    } catch (err) {
      change(null, status: RxStatus.error(err.toString()));
    }
  }

  @override
  void onInit() {
    change(null, status: RxStatus.empty());
    super.onInit();
  }
}
