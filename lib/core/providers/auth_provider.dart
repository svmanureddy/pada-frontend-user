import 'package:flutter/material.dart';

import '../errors/exceptions.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  String phoneNumber = '';
  String otpReceived = '';
  String deviceToken = '';
  BuildContext? parentCtx;
  setPhoneNumber({required String phone}) {
    phoneNumber = phone;
    notifyListeners();
  }

  setOtp({required String otp}) {
    otpReceived = otp;
    notifyListeners();
  }

  setDeviceToken({required String deviceTokenFromResponse}) {
    deviceToken = deviceTokenFromResponse;
    notifyListeners();
    debugPrint("device tok:: $deviceToken");
  }

  setCtx(context) {
    parentCtx = context;
    notifyListeners();
  }

  clearLoginCredentials() {
    phoneNumber = '';
    otpReceived = '';
    deviceToken = '';
    authToken = '';
    storageService.clearBox();
    notifyListeners();
  }

  String authToken = '';
  Future<bool> checkAuthState() async {
    try {
      String? token = await storageService.getAuthToken();
      if (token != null && token.trim() != '') {
        apiService.setAuthorisation(token);
        authToken = token;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future getOtp({required String phoneNumber}) async {
    try {
      var response = await apiService.getOtp(mobileNumber: phoneNumber);
      // debugPrint(response.toString());
      return response;
    } catch (e) {
      debugPrint("msg::msg:: $e");
      debugPrint(e is AppException ? e.message : e.toString());
      rethrow;
    }
  }

  Future mobileSignIn({required String otp}) async {
    try {
      // Provide a stable fallback for simulators where FCM token may be null/empty
      if (deviceToken.trim().isEmpty) {
        deviceToken = 'simulator-${DateTime.now().millisecondsSinceEpoch}';
      }
      var response = await apiService.mobileSignIn(
          verificationCode: otp,
          mobileNumber: phoneNumber,
          deviceToken: deviceToken);
      // debugPrint(response.toString());
      return response;
    } catch (e) {
      // debugPrint(e is AppException ? e.message : e.toString());
      rethrow;
    }
  }
}
