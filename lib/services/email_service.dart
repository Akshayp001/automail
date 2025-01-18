// // lib/services/email_service.dart
// import 'dart:io';

// import 'package:mailer/mailer.dart';
// import 'package:mailer/smtp_server.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:file_picker/file_picker.dart';

// class EmailService {
//   Future<void> sendEmail({
//     required String to,
//     required String subject,
//     required String body,
//     List<PlatformFile>? attachments,
//   }) async {
//     final prefs = await SharedPreferences.getInstance();
//     final email = prefs.getString('email');
//     final password = prefs.getString('password');

//     if (email == null || password == null) {
//       throw Exception('Email credentials not found. Please check settings.');
//     }

//     final smtpServer = gmail(email, password);

//     final message = Message()
//       ..from = Address(email)
//       ..recipients.addAll(to.split(',').toList())
//       ..subject = subject
//       ..text = body;

//     if (attachments != null) {
//       for (var file in attachments) {
//         message.attachments.add(
//           FileAttachment(File(file.path!))
//             ..location = Location.attachment
//             ..cid = '<${file.name}>',
//         );
//       }
//     }

//     try {
//       final sendReport = await send(message, smtpServer);
//       print('Message sent: ' + sendReport.toString());
//     } catch (e) {
//       print('Error sending email: $e');
//       rethrow;
//     }
//   }
// }

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

import 'dart:convert';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart' as gmaill;
import 'package:googleapis_auth/auth_io.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class EmailService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://mail.google.com/',
      'https://www.googleapis.com/auth/gmail.send',
    ],
  );

  Future<bool> _isOAuthMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isOAuthMode') ?? false;
  }

  Future<void> sendEmail({
    required String to,
    required String subject,
    required String body,
    List<PlatformFile>? attachments,
  }) async {
    final isOAuth = await _isOAuthMode();

    if (isOAuth) {
      await _sendWithOAuth(
        to: to,
        subject: subject,
        body: body,
        attachments: attachments,
      );
    } else {
      await _sendWithSMTP(
        to: to,
        subject: subject,
        body: body,
        attachments: attachments,
      );
    }
  }

  Future<void> _sendWithSMTP({
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
      ..recipients.addAll(to.split(',').map((e) => e.trim()).toList())
      ..subject = subject
      ..text = body;

    if (attachments != null) {
      for (var file in attachments) {
        if (file.path != null) {
          message.attachments.add(FileAttachment(File(file.path!)));
        }
      }
    }

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent via SMTP: $sendReport');
    } catch (e) {
      print('Error sending email via SMTP: $e');
      rethrow;
    }
  }

  Future<void> _sendWithOAuth({
    required String to,
    required String subject,
    required String body,
    List<PlatformFile>? attachments,
  }) async {
    try {
      final account =
          await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();

      if (account == null) {
        throw Exception('Failed to get Google account. Please sign in again.');
      }

      final headers = await account.authHeaders;
      final authenticatedClient = auth.authenticatedClient(
        http.Client(),
        AccessCredentials(
          AccessToken(
            'Bearer',
            headers['Authorization']!.split(' ')[1],
            DateTime.now().add(Duration(hours: 1)).toUtc(),
          ),
          null,
          [
            'https://mail.google.com/',
            'https://www.googleapis.com/auth/gmail.send',
          ],
        ),
      );

      final gmailApi = gmaill.GmailApi(authenticatedClient);

      final emailMessage = await _createMultipartMessage(
        account.email,
        to,
        subject,
        body,
        attachments,
      );

      final encodedMessage = base64Url.encode(utf8.encode(emailMessage));

      await gmailApi.users.messages.send(
        gmaill.Message(raw: encodedMessage),
        'me',
      );

      print('Message sent via OAuth');
    } catch (e) {
      print('Error sending email via OAuth: $e');
      rethrow;
    }
  }

  Future<String> _createMultipartMessage(
    String from,
    String to,
    String subject,
    String body,
    List<PlatformFile>? attachments,
  ) async {
    final boundary = 'Boundary-${DateTime.now().millisecondsSinceEpoch}';
    final buffer = StringBuffer();

    buffer.writeln('From: $from');
    buffer.writeln('To: $to');
    buffer.writeln('Subject: $subject');
    buffer.writeln('MIME-Version: 1.0');
    buffer.writeln('Content-Type: multipart/mixed; boundary="$boundary"');
    buffer.writeln();

    buffer.writeln('--$boundary');
    buffer.writeln('Content-Type: text/plain; charset=UTF-8');
    buffer.writeln();
    buffer.writeln(body);
    buffer.writeln();

    if (attachments != null) {
      for (var file in attachments) {
        if (file.path != null) {
          final fileData = await File(file.path!).readAsBytes();
          final encodedFile = base64.encode(fileData);

          buffer.writeln('--$boundary');
          buffer.writeln(
              'Content-Type: ${file.extension ?? 'application/octet-stream'}');
          buffer.writeln('Content-Transfer-Encoding: base64');
          buffer.writeln(
              'Content-Disposition: attachment; filename="${file.name}"');
          buffer.writeln();
          buffer.writeln(encodedFile);
          buffer.writeln();
        }
      }
    }

    buffer.writeln('--$boundary--');
    return buffer.toString();
  }
}
