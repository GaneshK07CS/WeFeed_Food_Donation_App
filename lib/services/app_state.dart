import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';

class AppUser {
  final String email;
  final String password;
  final String name;
  final String defaultRole; // 'donor' or 'ngo'

  AppUser({
    required this.email,
    required this.password,
    required this.name,
    this.defaultRole = 'donor',
  });

  AppUser copyWith({
    String? email,
    String? password,
    String? name,
    String? defaultRole,
  }) {
    return AppUser(
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      defaultRole: defaultRole ?? this.defaultRole,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'defaultRole': defaultRole,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      name: map['name'] ?? '',
      defaultRole: map['defaultRole'] ?? 'donor',
    );
  }
}

class FoodDonationItem {
  final String id;
  final String title;
  final String desc;
  final String qty;
  final String expiry;
  final String address;
  final String pincode;
  final String foodType;
  final String status; // 'Available', 'Approved', 'Picked Up', 'Rejected'
  final bool pickup;
  final DateTime createdAt;
  final String? donorName;
  final String? donorPhone;

  FoodDonationItem({
    required this.id,
    required this.title,
    required this.desc,
    required this.qty,
    required this.expiry,
    required this.address,
    required this.pincode,
    this.foodType = 'Cooked Food',
    this.status = 'Available',
    this.pickup = false,
    DateTime? createdAt,
    this.donorName = 'Ganesh Kothule (Donor)',
    this.donorPhone = '+91 9699468358',
  }) : createdAt = createdAt ?? DateTime.now();

  FoodDonationItem copyWith({
    String? title,
    String? desc,
    String? qty,
    String? expiry,
    String? address,
    String? pincode,
    String? foodType,
    String? status,
    bool? pickup,
    String? donorName,
    String? donorPhone,
  }) {
    return FoodDonationItem(
      id: id,
      title: title ?? this.title,
      desc: desc ?? this.desc,
      qty: qty ?? this.qty,
      expiry: expiry ?? this.expiry,
      address: address ?? this.address,
      pincode: pincode ?? this.pincode,
      foodType: foodType ?? this.foodType,
      status: status ?? this.status,
      pickup: pickup ?? this.pickup,
      createdAt: createdAt,
      donorName: donorName ?? this.donorName,
      donorPhone: donorPhone ?? this.donorPhone,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'desc': desc,
      'qty': qty,
      'expiry': expiry,
      'address': address,
      'pincode': pincode,
      'foodType': foodType,
      'status': status,
      'pickup': pickup,
      'createdAt': createdAt.toIso8601String(),
      'donorName': donorName,
      'donorPhone': donorPhone,
    };
  }

  factory FoodDonationItem.fromMap(Map<String, dynamic> map) {
    return FoodDonationItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      desc: map['desc'] ?? '',
      qty: map['qty'] ?? '',
      expiry: map['expiry'] ?? '',
      address: map['address'] ?? '',
      pincode: map['pincode'] ?? '',
      foodType: map['foodType'] ?? 'Cooked Food',
      status: map['status'] ?? 'Available',
      pickup: map['pickup'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      donorName: map['donorName'] ?? 'Ganesh Kothule',
      donorPhone: map['donorPhone'] ?? '+91 9699468358',
    );
  }
}

class NgoPartner {
  final String id;
  final String name;
  final String registrationNo;
  final String contactPerson;
  final String phone;
  final String email;
  final String address;
  final String pincode;
  final int mealsServed;

  NgoPartner({
    required this.id,
    required this.name,
    required this.registrationNo,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.address,
    required this.pincode,
    this.mealsServed = 500,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'reg_no': registrationNo,
      'poc_name': contactPerson,
      'poc_no': phone,
      'email': email,
      'address': address,
      'pincode': pincode,
      'meals_served': mealsServed,
    };
  }
}

class AppState extends ChangeNotifier {
  static final AppState instance = AppState._internal();
  factory AppState() => instance;

  AppState._internal() {
    _loadFromStorage();
    _initSampleData();
  }

  bool _initialized = false;
  bool get isInitialized => _initialized;

  String currentRole = 'donor'; // 'donor' or 'ngo'
  String currentUserEmail = '';
  String currentUserName = '';
  String rememberedEmail = '';
  bool isLoggedIn = false;

  final Map<String, AppUser> _registeredUsers = {};
  final Map<String, String> _resetOtps = {};
  final List<FoodDonationItem> _donations = [];
  final List<NgoPartner> _ngos = [];

  List<FoodDonationItem> get donations => List.unmodifiable(_donations);
  List<FoodDonationItem> get availableDonations =>
      _donations.where((d) => d.status != 'Rejected').toList();
  List<FoodDonationItem> get historyDonations =>
      _donations.where((d) => d.pickup || d.status == 'Approved' || d.status == 'Picked Up').toList();
  List<NgoPartner> get ngos => List.unmodifiable(_ngos);

  void _initSampleData() {
    // Default seed users (only added if not already present, preserving user edits)
    if (!_registeredUsers.containsKey('ganesh@wefeed.org')) {
      _registeredUsers['ganesh@wefeed.org'] = AppUser(
        email: 'ganesh@wefeed.org',
        password: 'password123',
        name: 'Ganesh Kothule',
        defaultRole: 'donor',
      );
    }
    if (!_registeredUsers.containsKey('donor@wefeed.org')) {
      _registeredUsers['donor@wefeed.org'] = AppUser(
        email: 'donor@wefeed.org',
        password: 'password123',
        name: 'Ganesh Kothule (Donor)',
        defaultRole: 'donor',
      );
    }
    if (!_registeredUsers.containsKey('ngo@smilefoundation.org')) {
      _registeredUsers['ngo@smilefoundation.org'] = AppUser(
        email: 'ngo@smilefoundation.org',
        password: 'password123',
        name: 'Smile Foundation (NGO)',
        defaultRole: 'ngo',
      );
    }

    // Initial donations if empty
    if (_donations.isEmpty) {
      _donations.addAll([
        FoodDonationItem(
          id: 'don_1',
          title: 'Fresh Veg Meals (Rice & Dal)',
          desc: 'Freshly prepared vegetarian meals surplus from community lunch event.',
          qty: '30 Packets',
          expiry: 'Today by 10:30 PM',
          address: 'Hotel Grand, FC Road, Pune',
          pincode: '411004',
          foodType: 'Cooked Food',
          status: 'Available',
          pickup: false,
          donorName: 'Ganesh Kothule (Lead Donor)',
          donorPhone: '+91 9699468358',
        ),
        FoodDonationItem(
          id: 'don_2',
          title: 'Fresh Bread Loaves & Bakery Items',
          desc: 'Unsold bakery bread loaves, buns, and sandwiches packed cleanly.',
          qty: '40 Loaves',
          expiry: 'Tomorrow 6:00 PM',
          address: 'BakeHouse Cafe, MG Road, Pune',
          pincode: '411001',
          foodType: 'Bakery',
          status: 'Approved',
          pickup: true,
          donorName: 'Ganesh Kothule',
          donorPhone: '+91 9699468358',
        ),
        FoodDonationItem(
          id: 'don_3',
          title: 'Packaged Juice & Fruit Boxes',
          desc: 'Unopened tetra pack juices and seasonal fresh apple/orange boxes.',
          qty: '50 Boxes',
          expiry: '3 Days from today',
          address: 'Green Mart, Kothrud, Pune',
          pincode: '411038',
          foodType: 'Packaged Food',
          status: 'Available',
          pickup: false,
          donorName: 'Rahul Patil',
          donorPhone: '+91 98220 11223',
        ),
      ]);
    }

    // Initial NGOs if empty
    if (_ngos.isEmpty) {
      _ngos.addAll([
        NgoPartner(
          id: 'ngo_1',
          name: 'Smile Foundation',
          registrationNo: 'NGO-MH-2021-9876',
          contactPerson: 'Rahul Sharma',
          phone: '+91 98123 45678',
          email: 'contact@smilefoundation.org',
          address: 'Shivaji Nagar, Pune',
          pincode: '411005',
          mealsServed: 520,
        ),
        NgoPartner(
          id: 'ngo_2',
          name: 'City Food Bank',
          registrationNo: 'NGO-MH-2022-1122',
          contactPerson: 'Pooja Verma',
          phone: '+91 98334 45566',
          email: 'info@cityfoodbank.org',
          address: 'FC Road, Pune',
          pincode: '411004',
          mealsServed: 340,
        ),
        NgoPartner(
          id: 'ngo_3',
          name: 'Feeding India Pune Hub',
          registrationNo: 'NGO-MH-2020-4455',
          contactPerson: 'Amit Deshmukh',
          phone: '+91 98777 88990',
          email: 'pune@feedingindia.org',
          address: 'Hinjewadi Phase 1, Pune',
          pincode: '411057',
          mealsServed: 890,
        ),
      ]);
    }
  }

  // --- Async Initializer to load persistent data ---

  Future<void> init() async {
    await LocalStorageService.instance.init();
    _loadFromStorage();
    _initSampleData();
    _initialized = true;
    notifyListeners();
  }

  void _loadFromStorage() {
    try {
      final storage = LocalStorageService.instance;
      
      // 1. Load persistent registered users (collection)
      final usersJson = storage.getString('wefeed_registered_users');
      if (usersJson != null && usersJson.isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(usersJson);
        decoded.forEach((key, val) {
          final cleanKey = key.toString().trim().toLowerCase();
          _registeredUsers[cleanKey] =
              AppUser.fromMap(Map<String, dynamic>.from(val));
        });
      }

      // 1b. Load individual user records (failsafe redundancy)
      final individualUsers = storage.getAllPrefixed('wefeed_usr_');
      individualUsers.forEach((k, v) {
        try {
          if (v.isNotEmpty) {
            final userMap = jsonDecode(v);
            final cleanKey = (userMap['email'] ?? k.replaceFirst('wefeed_usr_', '')).toString().trim().toLowerCase();
            if (cleanKey.isNotEmpty) {
              _registeredUsers[cleanKey] = AppUser.fromMap(Map<String, dynamic>.from(userMap));
            }
          }
        } catch (_) {}
      });

      // 2. Load persistent donations
      final donationsJson = storage.getString('wefeed_donations');
      if (donationsJson != null && donationsJson.isNotEmpty) {
        final List<dynamic> list = jsonDecode(donationsJson);
        if (list.isNotEmpty) {
          _donations.clear();
          for (var item in list) {
            _donations.add(
                FoodDonationItem.fromMap(Map<String, dynamic>.from(item)));
          }
        }
      }

      // 3. Load saved user session
      final sessionJson = storage.getString('wefeed_user_session');
      if (sessionJson != null && sessionJson.isNotEmpty) {
        final Map<String, dynamic> session = jsonDecode(sessionJson);
        currentUserEmail = session['email'] ?? '';
        currentRole = session['role'] ?? 'donor';
        currentUserName = session['name'] ?? '';
        isLoggedIn = session['isLoggedIn'] ?? false;
      }

      // 4. Load remembered email
      rememberedEmail = storage.getString('wefeed_remember_email') ?? '';
    } catch (e) {
      debugPrint("Storage load note: $e");
    }
  }

  Future<void> _saveUsersToStorage() async {
    try {
      final storage = LocalStorageService.instance;
      final Map<String, dynamic> data = {};
      for (final entry in _registeredUsers.entries) {
        final cleanKey = entry.key.trim().toLowerCase();
        data[cleanKey] = entry.value.toMap();
        // Save each user individually for fail-safe redundancy
        await storage.setString('wefeed_usr_$cleanKey', jsonEncode(entry.value.toMap()));
      }
      await storage.setString('wefeed_registered_users', jsonEncode(data));
    } catch (e) {
      debugPrint("Storage user save note: $e");
    }
  }

  Future<void> _saveDonationsToStorage() async {
    try {
      final storage = LocalStorageService.instance;
      final list = _donations.map((d) => d.toMap()).toList();
      await storage.setString('wefeed_donations', jsonEncode(list));
    } catch (e) {
      debugPrint("Storage donation save note: $e");
    }
  }

  // --- Authentication & User Management Methods ---

  bool isUserRegistered(String email) {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) return false;

    // Check in-memory map
    if (_registeredUsers.containsKey(cleanEmail)) {
      return true;
    }
    // Also check storage directly
    final storage = LocalStorageService.instance;
    final usersJson = storage.getString('wefeed_registered_users');
    if (usersJson != null && usersJson.isNotEmpty) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(usersJson);
        if (decoded.containsKey(cleanEmail)) {
          _registeredUsers[cleanEmail] =
              AppUser.fromMap(Map<String, dynamic>.from(decoded[cleanEmail]));
          return true;
        }
      } catch (_) {}
    }
    return false;
  }

  AppUser? getUserByEmail(String email) {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) return null;

    if (_registeredUsers.containsKey(cleanEmail)) {
      return _registeredUsers[cleanEmail];
    }
    // Fallback direct check
    final storage = LocalStorageService.instance;
    final usersJson = storage.getString('wefeed_registered_users');
    if (usersJson != null && usersJson.isNotEmpty) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(usersJson);
        if (decoded.containsKey(cleanEmail)) {
          final user = AppUser.fromMap(Map<String, dynamic>.from(decoded[cleanEmail]));
          _registeredUsers[cleanEmail] = user;
          return user;
        }
      } catch (_) {}
    }
    return null;
  }

  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    String defaultRole = 'donor',
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    if (isUserRegistered(cleanEmail)) {
      return false; // Already registered
    }

    _registeredUsers[cleanEmail] = AppUser(
      email: cleanEmail,
      password: password,
      name: name.trim(),
      defaultRole: defaultRole,
    );

    // Save permanently to storage immediately
    await _saveUsersToStorage();
    
    // Remember last registered email for easy sign in
    rememberedEmail = cleanEmail;
    try {
      await LocalStorageService.instance.setString('wefeed_remember_email', cleanEmail);
    } catch (_) {}

    notifyListeners();

    try {
      FirebaseFirestore.instance.collection('users').doc(cleanEmail).set({
        'name': name.trim(),
        'email': cleanEmail,
        'role': defaultRole,
        'password': password,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Firestore user sync note: $e");
    }

    return true;
  }

  bool validateCredentials(String email, String password) {
    final cleanEmail = email.trim().toLowerCase();
    final user = getUserByEmail(cleanEmail);
    if (user == null) {
      return false;
    }
    return user.password == password;
  }

  // --- Password Reset & OTP Features ---

  String generateResetOtp(String email) {
    final cleanEmail = email.trim().toLowerCase();
    // 4-digit verification code
    final code = (1000 + (DateTime.now().millisecondsSinceEpoch % 8999)).toString();
    _resetOtps[cleanEmail] = code;
    return code;
  }

  bool verifyResetOtp(String email, String inputOtp) {
    final cleanEmail = email.trim().toLowerCase();
    final cleanOtp = inputOtp.trim();
    if (cleanOtp == '1234') return true; // Friendly universal demo OTP
    if (_resetOtps.containsKey(cleanEmail) && _resetOtps[cleanEmail] == cleanOtp) {
      return true;
    }
    return false;
  }

  Future<bool> updateUserPassword(String email, String newPassword) async {
    final cleanEmail = email.trim().toLowerCase();
    AppUser? user = getUserByEmail(cleanEmail);
    
    if (user == null) {
      // Check if it exists as seed or create fallback
      if (cleanEmail.isNotEmpty) {
        user = AppUser(
          email: cleanEmail,
          password: newPassword,
          name: cleanEmail.split('@').first,
          defaultRole: 'donor',
        );
      } else {
        return false;
      }
    }

    // Update password
    _registeredUsers[cleanEmail] = user.copyWith(password: newPassword.trim());
    
    // Immediately persist updated user map to storage
    await _saveUsersToStorage();
    
    // Remember email
    rememberedEmail = cleanEmail;
    try {
      await LocalStorageService.instance.setString('wefeed_remember_email', cleanEmail);
    } catch (_) {}

    notifyListeners();

    try {
      FirebaseFirestore.instance.collection('users').doc(cleanEmail).update({
        'password': newPassword.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Firestore password update note: $e");
    }

    return true;
  }

  Future<void> setUserSession({required String email, required String role, String? name}) async {
    currentUserEmail = email.trim().toLowerCase();
    currentRole = role;
    isLoggedIn = true;
    if (name != null && name.isNotEmpty) {
      currentUserName = name;
    } else {
      final user = getUserByEmail(currentUserEmail);
      currentUserName = user?.name ?? email.split('@').first;
    }
    rememberedEmail = currentUserEmail;

    // Persist session to local storage
    try {
      final storage = LocalStorageService.instance;
      await storage.setString('wefeed_user_session', jsonEncode({
        'email': currentUserEmail,
        'role': currentRole,
        'name': currentUserName,
        'isLoggedIn': true,
      }));
      await storage.setString('wefeed_remember_email', currentUserEmail);
    } catch (_) {}

    notifyListeners();
  }

  Future<void> logout() async {
    isLoggedIn = false;
    currentUserEmail = '';
    currentUserName = '';

    try {
      final storage = LocalStorageService.instance;
      await storage.remove('wefeed_user_session');
    } catch (_) {}

    try {
      FirebaseAuth.instance.signOut();
    } catch (_) {}
    notifyListeners();
  }

  // --- Donation Management & Realtime Editing ---

  Future<void> addDonation({
    required String title,
    required String desc,
    required String qty,
    required String expiry,
    required String address,
    required String pincode,
    String foodType = 'Cooked Food',
    String? donorName,
    String? donorPhone,
  }) async {
    final newId = 'don_${DateTime.now().millisecondsSinceEpoch}';
    final item = FoodDonationItem(
      id: newId,
      title: title,
      desc: desc,
      qty: qty,
      expiry: expiry,
      address: address,
      pincode: pincode,
      foodType: foodType,
      status: 'Available',
      pickup: false,
      donorName: donorName ?? (currentUserName.isNotEmpty ? currentUserName : 'Ganesh Kothule'),
      donorPhone: donorPhone ?? '+91 9699468358',
    );

    _donations.insert(0, item);
    await _saveDonationsToStorage();
    notifyListeners();

    try {
      await FirebaseFirestore.instance.collection('request').doc(newId).set({
        'title': title,
        'desc': desc,
        'qty': qty,
        'expiry': expiry,
        'address': address,
        'pincode': pincode,
        'foodType': foodType,
        'status': 'Available',
        'pickup': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Firestore background sync note: $e");
    }
  }

  Future<void> editDonation({
    required String id,
    required String title,
    required String desc,
    required String qty,
    required String expiry,
    required String address,
    required String pincode,
    required String foodType,
  }) async {
    final index = _donations.indexWhere((d) => d.id == id);
    if (index != -1) {
      _donations[index] = _donations[index].copyWith(
        title: title,
        desc: desc,
        qty: qty,
        expiry: expiry,
        address: address,
        pincode: pincode,
        foodType: foodType,
      );
      await _saveDonationsToStorage();
      notifyListeners();

      try {
        await FirebaseFirestore.instance.collection('request').doc(id).update({
          'title': title,
          'desc': desc,
          'qty': qty,
          'expiry': expiry,
          'address': address,
          'pincode': pincode,
          'foodType': foodType,
        });
      } catch (e) {
        debugPrint("Firestore edit sync note: $e");
      }
    }
  }

  Future<void> deleteDonation(String id) async {
    _donations.removeWhere((d) => d.id == id);
    await _saveDonationsToStorage();
    notifyListeners();

    try {
      await FirebaseFirestore.instance.collection('request').doc(id).delete();
    } catch (e) {
      debugPrint("Firestore delete sync note: $e");
    }
  }

  Future<void> updateDonationStatus(String id, String status, bool pickup) async {
    final index = _donations.indexWhere((d) => d.id == id);
    if (index != -1) {
      _donations[index] = _donations[index].copyWith(
        status: status,
        pickup: pickup,
      );
      await _saveDonationsToStorage();
      notifyListeners();
    }

    try {
      await FirebaseFirestore.instance.collection('request').doc(id).update({
        'status': status,
        'pickup': pickup,
      });
    } catch (e) {
      debugPrint("Firestore update note: $e");
    }
  }

  Future<void> registerNgo({
    required String name,
    required String registrationNo,
    required String contactPerson,
    required String phone,
    required String email,
    required String address,
    required String pincode,
  }) async {
    final newId = 'ngo_${DateTime.now().millisecondsSinceEpoch}';
    final ngo = NgoPartner(
      id: newId,
      name: name,
      registrationNo: registrationNo,
      contactPerson: contactPerson,
      phone: phone,
      email: email,
      address: address,
      pincode: pincode,
    );
    _ngos.insert(0, ngo);
    notifyListeners();

    try {
      await FirebaseFirestore.instance.collection('ngo').doc(newId).set(ngo.toMap());
    } catch (e) {
      debugPrint("Firestore NGO sync note: $e");
    }
  }
}
