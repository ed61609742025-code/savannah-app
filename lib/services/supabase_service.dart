import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService extends ChangeNotifier {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  bool _isInitialized = false;
  bool _isDemoMode = true;
  User? _authUser;
  String? _userDisplayName;
  double _cloudBalance = 480.0;

  bool get isInitialized => _isInitialized;
  bool get isDemoMode => _isDemoMode;
  bool get isAuthenticated => _authUser != null;
  User? get authUser => _authUser;
  String get userDisplayName => _userDisplayName ?? (_authUser?.email?.split('@').first ?? 'Savannah Explorer');
  double get cloudBalance => _cloudBalance;

  // Default demo / development credentials
  static const String defaultSupabaseUrl = 'https://demo-savannah-project.supabase.co';
  static const String defaultAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIn0.DEMO_KEY';

  Future<void> initialize({String? url, String? anonKey}) async {
    final supabaseUrl = url ?? defaultSupabaseUrl;
    final supabaseAnonKey = anonKey ?? defaultAnonKey;

    try {
      if (supabaseUrl.contains('demo-savannah-project')) {
        _isDemoMode = true;
        _isInitialized = true;
        debugPrint('[SupabaseService] Running in Local / Demo Cloud Mode');
        notifyListeners();
        return;
      }

      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: supabaseAnonKey,
      );
      _isInitialized = true;
      _isDemoMode = false;
      _authUser = Supabase.instance.client.auth.currentUser;
      debugPrint('[SupabaseService] Successfully connected to live Supabase project!');
      notifyListeners();
    } catch (e) {
      debugPrint('[SupabaseService] Initialization fallback to simulated mode: $e');
      _isDemoMode = true;
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Authentication
  Future<bool> signInWithEmail(String email, String password) async {
    if (_isDemoMode) {
      _userDisplayName = email.split('@').first;
      _cloudBalance = 520.0;
      notifyListeners();
      return true;
    }

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _authUser = response.user;
      _userDisplayName = _authUser?.email?.split('@').first;
      await fetchCloudBalance();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[SupabaseService] SignIn Error: $e');
      return false;
    }
  }

  Future<bool> signUpWithEmail(String email, String password, String displayName) async {
    if (_isDemoMode) {
      _userDisplayName = displayName;
      _cloudBalance = 500.0;
      notifyListeners();
      return true;
    }

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': displayName},
      );
      _authUser = response.user;
      _userDisplayName = displayName;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[SupabaseService] SignUp Error: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    if (!_isDemoMode) {
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (_) {}
    }
    _authUser = null;
    _userDisplayName = null;
    notifyListeners();
  }

  // Wallet Sync
  Future<void> fetchCloudBalance() async {
    if (_isDemoMode || _authUser == null) return;
    try {
      final data = await Supabase.instance.client
          .from('user_wallets')
          .select('balance')
          .eq('user_id', _authUser!.id)
          .maybeSingle();

      if (data != null && data['balance'] != null) {
        _cloudBalance = (data['balance'] as num).toDouble();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[SupabaseService] fetchCloudBalance error: $e');
    }
  }

  Future<void> updateCloudBalance(double newBalance) async {
    _cloudBalance = newBalance;
    notifyListeners();

    if (_isDemoMode || _authUser == null) return;
    try {
      await Supabase.instance.client.from('user_wallets').upsert({
        'user_id': _authUser!.id,
        'balance': newBalance,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('[SupabaseService] updateCloudBalance error: $e');
    }
  }
}
