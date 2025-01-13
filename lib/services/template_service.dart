import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/email_template.dart';

class TemplateService {
  static const String _key = 'email_templates';

  Future<void> saveTemplate(EmailTemplate template) async {
    final prefs = await SharedPreferences.getInstance();
    final templates = await getAllTemplates();

    // Check if template already exists before adding
    final existingIndex = templates.indexWhere((t) => t.id == template.id);
    if (existingIndex != -1) {
      // Update existing template
      templates[existingIndex] = template;
    } else {
      // Add new template
      templates.add(template);
    }

    final jsonList = templates.map((t) => t.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  Future<List<EmailTemplate>> getAllTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => EmailTemplate.fromJson(json)).toList();
  }

  Future<List<EmailTemplate>> getTemplatesByCategory(String category) async {
    final templates = await getAllTemplates();
    return templates.where((t) => t.category == category).toList();
  }

  Future<List<EmailTemplate>> getTemplatesByTag(String tag) async {
    final templates = await getAllTemplates();
    return templates.where((t) => t.tags.contains(tag)).toList();
  }

  Future<void> deleteTemplate(String templateId) async {
    final prefs = await SharedPreferences.getInstance();
    final templates = await getAllTemplates();

    final index = templates.indexWhere((t) => t.id == templateId);
    if (index != -1) {
      templates.removeAt(index);
      final jsonList = templates.map((t) => t.toJson()).toList();
      await prefs.setString(_key, jsonEncode(jsonList));
    }
  }

  // // Update template (assuming an update method exists in EmailTemplate)
  // Future<void> updateTemplate(EmailTemplate updatedTemplate) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final templates = await getAllTemplates();

  //   final index = templates.indexWhere((t) => t.id == updatedTemplate.id);
  //   if (index != -1) {
  //     templates[index] = updatedTemplate.update(updatedTemplate); // Call update method from EmailTemplate
  //     final jsonList = templates.map((t) => t.toJson()).toList();
  //     await prefs.setString(_key, jsonEncode(jsonList));
  //   }
  // }
}