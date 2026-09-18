import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/school_model.dart';

/// Manages the student's saved/favorite schools.
///
/// Favorites are stored as full school snapshots in the Firestore
/// `favorites` collection (keyed by userId) so they keep working even
/// when the school came from the external API and has no schools/ doc id.
class FavoritesProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<SchoolModel> _favorites = [];
  // school key (name|country, lowercased) -> Firestore doc id
  Map<String, String> _docIdByKey = {};
  bool _isLoading = false;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _favSub;
  String? _subscribedUid;

  List<SchoolModel> get favorites => _favorites;
  bool get isLoading => _isLoading;
  bool get hasFavorites => _favorites.isNotEmpty;

  static String _keyFor(SchoolModel school) =>
      '${school.name.toLowerCase()}|${school.country.toLowerCase()}';

  bool isFavorite(SchoolModel school) =>
      _docIdByKey.containsKey(_keyFor(school));

  // Subscribe to real-time favorites updates.
  void subscribeToFavorites() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      _favSub?.cancel();
      _favSub = null;
      _subscribedUid = null;
      _favorites = [];
      _docIdByKey = {};
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (_subscribedUid == uid) return;

    _favSub?.cancel();
    _subscribedUid = uid;
    _isLoading = true;
    notifyListeners();

    // Favorites data is the same schema as a schools/ document, so
    // SchoolModel.fromFirestore reads it directly.
    _favSub = _firestore
        .collection('favorites')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
      final list = <SchoolModel>[];
      final docIds = <String, String>{};
      for (final doc in snapshot.docs) {
        final school = SchoolModel.fromFirestore(doc.data());
        list.add(school);
        docIds[_keyFor(school)] = doc.id;
      }
      _favorites = list;
      _docIdByKey = docIds;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint('[FavoritesProvider] subscribeToFavorites onError: $e');
      _favSub?.cancel();
      _favSub = null;
      _subscribedUid = null;
      _favorites = [];
      _docIdByKey = {};
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> toggleFavorite(SchoolModel school) async {
    if (_docIdByKey.containsKey(_keyFor(school))) {
      await removeFavorite(school);
    } else {
      await addFavorite(school);
    }
  }

  Future<bool> addFavorite(SchoolModel school) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    final key = _keyFor(school);
    if (_docIdByKey.containsKey(key)) return true;

    final docRef = _firestore.collection('favorites').doc();
    try {
      await docRef.set({
        ...school.toMap(),
        'userId': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Optimistic local update so the heart flips immediately.
      _favorites = [..._favorites, school];
      _docIdByKey[key] = docRef.id;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[FavoritesProvider] addFavorite error: $e');
      return false;
    }
  }

  Future<bool> removeFavorite(SchoolModel school) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    final key = _keyFor(school);
    final docId = _docIdByKey[key];
    if (docId == null) return false;

    try {
      await _firestore.collection('favorites').doc(docId).delete();

      _favorites.removeWhere((s) => _keyFor(s) == key);
      _docIdByKey.remove(key);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[FavoritesProvider] removeFavorite error: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _favSub?.cancel();
    super.dispose();
  }
}