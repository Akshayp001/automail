// lib/models/email_template.dart
import 'dart:convert';

class EmailTemplate {
  final String id;
  final String name;
  final String subject;
  final String body;
  final List<String> attachmentPaths;
  final List<String> tags;
  final String category;
  final String extra1;
  final String extra2;
  final DateTime createdAt;
  final DateTime updatedAt;

  EmailTemplate({
    required this.id,
    required this.name,
    required this.subject,
    required this.body,
    this.attachmentPaths = const [],
    this.tags = const [],
    this.category = '',
    this.extra1 = '',
    this.extra2 = '',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subject': subject,
      'body': body,
      'attachmentPaths': attachmentPaths,
      'tags': tags,
      'category': category,
      'extra1': extra1,
      'extra2': extra2,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory EmailTemplate.fromJson(Map<String, dynamic> json) {
    return EmailTemplate(
      id: json['id'],
      name: json['name'],
      subject: json['subject'],
      body: json['body'],
      attachmentPaths: List<String>.from(json['attachmentPaths']),
      tags: List<String>.from(json['tags']),
      category: json['category'],
      extra1: json['extra1'],
      extra2: json['extra2'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Create a copy of the template with updated fields
  EmailTemplate copyWith({
    String? name,
    String? subject,
    String? body,
    List<String>? attachmentPaths,
    List<String>? tags,
    String? category,
    String? extra1,
    String? extra2,
  }) {
    return EmailTemplate(
      id: id,
      name: name ?? this.name,
      subject: subject ?? this.subject,
      body: body ?? this.body,
      attachmentPaths: attachmentPaths ?? this.attachmentPaths,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      extra1: extra1 ?? this.extra1,
      extra2: extra2 ?? this.extra2,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}