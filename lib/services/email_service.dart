// lib/services/email_service.dart
import 'dart:io';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

class EmailService {
  Future<void> sendEmail({
    required String to,
    required String subject,
    required String body,
    List<PlatformFile>? attachments,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final password = prefs.getString('password');

    if (email == null || password == null) {
      throw Exception('Email credentials not found. Please check settings.');
    }

    final smtpServer = gmail(email, password);

    final message = Message()
      ..from = Address(email)
      ..recipients.addAll(to.split(',').toList())
      ..subject = subject
      ..text = body;

    if (attachments != null) {
      for (var file in attachments) {
        message.attachments.add(
          FileAttachment(File(file.path!))
            ..location = Location.attachment
            ..cid = '<${file.name}>',
        );
      }
    }

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } catch (e) {
      print('Error sending email: $e');
      rethrow;
    }
  }
}

// To Send Email Throgh GoogleAPIs 

// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:file_picker/file_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class EmailService {
//   Future<void> sendEmail({
//     required String to,
//     required String subject,
//     required String body,
//     List<PlatformFile>? attachments,
//   }) async {
//     final prefs = await SharedPreferences.getInstance();
//     final email = prefs.getString('email');
//     final accessToken = prefs.getString('accessToken');

//     if (email == null || accessToken == null) {
//       throw Exception('Email credentials not found. Please check settings.');
//     }

//     // Create the email message
//     final message = createMessage(email, to, subject, body, attachments);

//     // Send the email via Gmail API
//     try {
//       final url =
//           'https://www.googleapis.com/upload/gmail/v1/users/me/messages/send?uploadType=multipart';
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {
//           'Authorization': 'Bearer $accessToken',
//           'Content-Type': 'application/json',
//         },
//         body: json.encode({
//           'raw': message,
//         }),
//       );

//       if (response.statusCode == 200) {
//         print('Email sent successfully!');
//       } else {
//         print('Failed to send email. Status code: ${response.statusCode}');
//         print('Response body: ${response.body}');
//       }
//     } catch (e) {
//       print('Error sending email: $e');
//       rethrow;
//     }
//   }

//   // Helper function to create the raw email message
//   String createMessage(String from, String to, String subject, String body,
//       List<PlatformFile>? attachments) {
//     // Create the email headers and body
//     String message = 'From: $from\nTo: $to\nSubject: $subject\n\n$body';

//     // Attach any files if necessary
//     if (attachments != null && attachments.isNotEmpty) {
//       for (var file in attachments) {
//         // Include the attachment logic here if needed
//       }
//     }

//     // Base64url encode the message
//     final base64Message =
//         base64Url.encode(Uint8List.fromList(utf8.encode(message)));
//     return base64Message;
//   }
// }
