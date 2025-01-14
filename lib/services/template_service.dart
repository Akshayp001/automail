// services/template_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/email_template.dart';

class TemplateService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'email_templates';
  final String userId; // Store user ID

  // Constructor requires userId
  TemplateService({required this.userId}) {
    if (userId.isEmpty) {
      throw Exception('User ID cannot be empty');
    }
  }

  // Save template (create or update)
  Future<void> saveTemplate(EmailTemplate template) async {
    try {
      // Add userId to template data
      final templateData = template.toJson();
      templateData['userId'] = userId;
      templateData['createdAt'] = DateTime.now().toIso8601String();

      final docRef = _db.collection(_collection).doc(template.id);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // Verify ownership before update
        final existingData = docSnapshot.data();
        if (existingData?['userId'] != userId) {
          throw Exception('Template belongs to another user');
        }
        await docRef.update(templateData);
      } else {
        await docRef.set(templateData);
      }
    } catch (e) {
      throw Exception('Failed to save template: $e');
    }
  }

  // Get all templates for current user
  Future<List<EmailTemplate>> getAllTemplates() async {
    try {
      final querySnapshot = await _db
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return EmailTemplate.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get templates: $e');
    }
  }

  // Get templates by category for current user
  Future<List<EmailTemplate>> getTemplatesByCategory(String category) async {
    try {
      final querySnapshot = await _db
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('category', isEqualTo: category)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return EmailTemplate.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get templates by category: $e');
    }
  }

  // Get templates by tag for current user
  Future<List<EmailTemplate>> getTemplatesByTag(String tag) async {
    try {
      final querySnapshot = await _db
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('tags', arrayContains: tag)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return EmailTemplate.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get templates by tag: $e');
    }
  }

  // Delete template (with ownership verification)
  Future<void> deleteTemplate(String templateId) async {
    try {
      final docRef = _db.collection(_collection).doc(templateId);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data?['userId'] != userId) {
          throw Exception('Template belongs to another user');
        }
        await docRef.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete template: $e');
    }
  }

  // Stream of all templates for current user
  Stream<List<EmailTemplate>> streamAllTemplates() {
    return _db
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return EmailTemplate.fromJson(data);
      }).toList();
    });
  }

  // Stream templates by category for current user
  Stream<List<EmailTemplate>> streamTemplatesByCategory(String category) {
    return _db
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return EmailTemplate.fromJson(data);
      }).toList();
    });
  }

  // Get a single template by ID (with ownership verification)
  Future<EmailTemplate?> getTemplateById(String templateId) async {
    try {
      final docSnapshot =
          await _db.collection(_collection).doc(templateId).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        // Verify ownership
        if (data['userId'] != userId) {
          throw Exception('Template belongs to another user');
        }
        data['id'] = docSnapshot.id;
        return EmailTemplate.fromJson(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get template by ID: $e');
    }
  }

  // Search templates by title for current user
  Future<List<EmailTemplate>> searchTemplates(String searchTerm) async {
    try {
      final querySnapshot = await _db
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('title', isGreaterThanOrEqualTo: searchTerm)
          .where('title', isLessThanOrEqualTo: '$searchTerm\uf8ff')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return EmailTemplate.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search templates: $e');
    }
  }
}
