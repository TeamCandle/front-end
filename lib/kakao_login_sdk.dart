import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class KaKaoLogIn {
  User? user;

  Future<bool> login() async {
    bool isInstalled = await isKakaoTalkInstalled();

    if (isInstalled) {
      try {
        await UserApi.instance.loginWithKakaoTalk();
        return true;
      } catch (e) {
        return false;
      }
    } else {
      try {
        await UserApi.instance.loginWithKakaoAccount();
        return true;
      } catch (e) {
        return false;
      }
    }
  }

  Future<bool> logout() async {
    try {
      await UserApi.instance.unlink();
      return true;
    } catch (error) {
      return false;
    }
  }
}
