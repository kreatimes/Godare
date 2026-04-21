import 'package:flutter/material.dart';
import 'package:godare/models/auth.dart';
import 'package:godare/models/user.dart';
import 'package:godare/services/auth_service.dart';
import 'package:godare/services/notification_service.dart';
import 'package:godare/services/user_service.dart';

/// Estado global del usuario autenticado.
/// Gestiona la sesión, el perfil y las notificaciones no leídas.
class UserProvider extends ChangeNotifier {

  MyProfile? _profile;
  bool _isLoading = false;
  String? _error;
  int _unreadNotifications = 0;

  MyProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadNotifications => _unreadNotifications;
  bool get isLoggedIn => _profile != null;

  /// Inicia sesión
  Future<bool> login(LoginRequest request) async {
    _setLoading(true);
    try {
      await AuthService.login(request);
      await loadProfile();
      await loadUnreadCount();
      return true;
    } on EmailNotVerifiedException {
      // Re-lanzar para que la página lo capture y muestre el dialog
      rethrow;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Carga el perfil desde la API
  Future<void> loadProfile() async {
    try {
      _profile = await UserService.getMyProfile();
      _error = null;
      notifyListeners();
    } on UserException catch (e) {
      _setError(e.message);
    }
  }

  /// Notificaciones no leidas
  Future<void> loadUnreadCount() async {
    try {
      _unreadNotifications = await NotificationService.getUnreadCount();
      notifyListeners();
    } catch (_) {}
  }

  /// Actualiza perfil
  Future<bool> updateProfile({
    String? nick,
    String? name,
    String? surnames,
    String? userImageUrl,
  }) async {
    _setLoading(true);
    try {
      _profile = await UserService.updateMyProfile(
        nick: nick,
        name: name,
        surnames: surnames,
        userImageUrl: userImageUrl,
      );
      notifyListeners();
      return true;
    } on UserException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Actualiza contador notifs
  void setUnreadNotifications(int count) {
    _unreadNotifications = count;
    notifyListeners();
  }

  /// -1 al leer una notif
  void decrementUnreadNotifications() {
    if (_unreadNotifications > 0) {
      _unreadNotifications--;
      notifyListeners();
    }
  }

  /// Reset contador
  void clearUnreadNotifications() {
    _unreadNotifications = 0;
    notifyListeners();
  }

  /// Logout
  Future<void> logout() async {
    await AuthService.logout();
    _profile = null;
    _unreadNotifications = 0;
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }
}