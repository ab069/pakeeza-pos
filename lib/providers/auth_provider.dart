import 'package:flutter/foundation.dart';
import 'package:pakeeza_pos/data/models/models.dart';
import 'package:pakeeza_pos/data/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authRepo);

  final AuthRepository _authRepo;

  UserModel? _user;
  bool _loading = true;
  bool _needsSetup = false;

  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get loading => _loading;
  bool get needsSetup => _needsSetup;

  Future<void> init() async {
    _loading = true;
    notifyListeners();

    _needsSetup = !(await _authRepo.hasAnyUser());

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('session_user_id');
    if (userId != null && !_needsSetup) {
      // Session restore: re-login required for security (no password stored).
      // User stays logged out until they sign in again after app restart.
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    _user = await _authRepo.login(username: username, password: password);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('session_user_id', _user!.id);
    await prefs.setString('session_username', _user!.username);
    notifyListeners();
  }

  Future<void> signUp({
    required String username,
    required String password,
    required String displayName,
    String role = 'cashier',
  }) async {
    final isFirst = !(await _authRepo.hasAnyUser());
    _user = await _authRepo.signUp(
      username: username,
      password: password,
      displayName: displayName,
      role: role,
      forceOwner: isFirst,
    );
    _needsSetup = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('session_user_id', _user!.id);
    await prefs.setString('session_username', _user!.username);
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_user_id');
    await prefs.remove('session_username');
    notifyListeners();
  }
}
