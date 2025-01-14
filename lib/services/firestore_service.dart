// firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create document
  Future<String> createDocument(String collection, Map<String, dynamic> data) async {
    try {
      final docRef = await _db.collection(collection).add(data);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create document: $e');
    }
  }

  // Read document by ID
  Future<Map<String, dynamic>?> getDocument(String collection, String docId) async {
    try {
      final docSnapshot = await _db.collection(collection).doc(docId).get();
      if (docSnapshot.exists) {
        return docSnapshot.data();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get document: $e');
    }
  }

  // Read all documents from collection
  Future<List<Map<String, dynamic>>> getAllDocuments(String collection) async {
    try {
      final querySnapshot = await _db.collection(collection).get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID to the data
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get documents: $e');
    }
  }

  // Update document
  Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) async {
    try {
      await _db.collection(collection).doc(docId).update(data);
    } catch (e) {
      throw Exception('Failed to update document: $e');
    }
  }

  // Delete document
  Future<void> deleteDocument(String collection, String docId) async {
    try {
      await _db.collection(collection).doc(docId).delete();
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }
}