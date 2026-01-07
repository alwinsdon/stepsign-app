import 'package:shared_preferences/shared_preferences.dart';

/// Service for persisting app state locally
class StorageService {
  static SharedPreferences? _prefs;
  
  // Keys
  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyDevicePaired = 'device_paired';
  static const String _keyPairedDeviceId = 'paired_device_id';
  static const String _keyPairedDeviceName = 'paired_device_name';
  static const String _keyBluetoothGranted = 'bluetooth_granted';
  static const String _keyActivityGranted = 'activity_granted';
  static const String _keyNotificationsGranted = 'notifications_granted';
  static const String _keyWalletAddress = 'wallet_address';
  static const String _keyUserName = 'user_name';
  static const String _keyUserAge = 'user_age';
  static const String _keyUserWeight = 'user_weight';
  static const String _keyUserHeight = 'user_height';
  
  /// Initialize the storage service - must be called before using
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  /// Check if prefs is initialized
  static void _ensureInitialized() {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call StorageService.init() first.');
    }
  }
  
  // ========== Onboarding ==========
  
  static bool get hasCompletedOnboarding {
    _ensureInitialized();
    return _prefs!.getBool(_keyOnboardingCompleted) ?? false;
  }
  
  static Future<void> setOnboardingCompleted(bool value) async {
    _ensureInitialized();
    await _prefs!.setBool(_keyOnboardingCompleted, value);
  }
  
  // ========== Device Pairing ==========
  
  static bool get isDevicePaired {
    _ensureInitialized();
    return _prefs!.getBool(_keyDevicePaired) ?? false;
  }
  
  static Future<void> setDevicePaired(bool value) async {
    _ensureInitialized();
    await _prefs!.setBool(_keyDevicePaired, value);
  }
  
  static String? get pairedDeviceId {
    _ensureInitialized();
    return _prefs!.getString(_keyPairedDeviceId);
  }
  
  static Future<void> setPairedDeviceId(String? value) async {
    _ensureInitialized();
    if (value == null) {
      await _prefs!.remove(_keyPairedDeviceId);
    } else {
      await _prefs!.setString(_keyPairedDeviceId, value);
    }
  }
  
  static String? get pairedDeviceName {
    _ensureInitialized();
    return _prefs!.getString(_keyPairedDeviceName);
  }
  
  static Future<void> setPairedDeviceName(String? value) async {
    _ensureInitialized();
    if (value == null) {
      await _prefs!.remove(_keyPairedDeviceName);
    } else {
      await _prefs!.setString(_keyPairedDeviceName, value);
    }
  }
  
  // ========== Permissions ==========
  
  static bool get bluetoothGranted {
    _ensureInitialized();
    return _prefs!.getBool(_keyBluetoothGranted) ?? false;
  }
  
  static Future<void> setBluetoothGranted(bool value) async {
    _ensureInitialized();
    await _prefs!.setBool(_keyBluetoothGranted, value);
  }
  
  static bool get activityGranted {
    _ensureInitialized();
    return _prefs!.getBool(_keyActivityGranted) ?? false;
  }
  
  static Future<void> setActivityGranted(bool value) async {
    _ensureInitialized();
    await _prefs!.setBool(_keyActivityGranted, value);
  }
  
  static bool get notificationsGranted {
    _ensureInitialized();
    return _prefs!.getBool(_keyNotificationsGranted) ?? false;
  }
  
  static Future<void> setNotificationsGranted(bool value) async {
    _ensureInitialized();
    await _prefs!.setBool(_keyNotificationsGranted, value);
  }
  
  static bool get allPermissionsGranted {
    return bluetoothGranted && activityGranted && notificationsGranted;
  }
  
  // ========== User Info ==========
  
  static String? get walletAddress {
    _ensureInitialized();
    return _prefs!.getString(_keyWalletAddress);
  }
  
  static Future<void> setWalletAddress(String? value) async {
    _ensureInitialized();
    if (value == null) {
      await _prefs!.remove(_keyWalletAddress);
    } else {
      await _prefs!.setString(_keyWalletAddress, value);
    }
  }
  
  static String get userName {
    _ensureInitialized();
    return _prefs!.getString(_keyUserName) ?? 'User';
  }
  
  static Future<void> setUserName(String value) async {
    _ensureInitialized();
    await _prefs!.setString(_keyUserName, value);
  }
  
  static int get userAge {
    _ensureInitialized();
    return _prefs!.getInt(_keyUserAge) ?? 0;
  }
  
  static Future<void> setUserAge(int value) async {
    _ensureInitialized();
    await _prefs!.setInt(_keyUserAge, value);
  }
  
  static double get userWeight {
    _ensureInitialized();
    return _prefs!.getDouble(_keyUserWeight) ?? 0.0;
  }
  
  static Future<void> setUserWeight(double value) async {
    _ensureInitialized();
    await _prefs!.setDouble(_keyUserWeight, value);
  }
  
  static double get userHeight {
    _ensureInitialized();
    return _prefs!.getDouble(_keyUserHeight) ?? 0.0;
  }
  
  static Future<void> setUserHeight(double value) async {
    _ensureInitialized();
    await _prefs!.setDouble(_keyUserHeight, value);
  }
  
  // ========== Reset ==========
  
  /// Clear all stored data (for logout/reset)
  static Future<void> clearAll() async {
    _ensureInitialized();
    await _prefs!.clear();
  }
  
  /// Reset just the pairing (keep onboarding and permissions)
  static Future<void> resetPairing() async {
    await setDevicePaired(false);
    await setPairedDeviceId(null);
    await setPairedDeviceName(null);
  }
}
