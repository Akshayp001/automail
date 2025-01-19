import 'dart:convert';
import 'dart:io';
import 'package:automail/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart' as gmaill;
import 'package:googleapis/vmmigration/v1.dart';
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
    checkAndShowEmailSetupDialog();

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

  static  checkAndShowEmailSetupDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final password = prefs.getString('password');
    final isOauth = prefs.getBool('isOAuthMode') ?? false;

    if (isOauth) {
      return;
    } else {
      if (email != null && email != '' && password != '' && password != null) {
        return;
      }
    }

    Get.dialog(AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      title: Row(
        children: [
          Icon(Icons.email, color: Colors.redAccent),
          SizedBox(width: 8),
          Text("Email Setup Incomplete"),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "You haven't set up your email yet. To send emails, please complete your email configuration.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          Image.asset(
            'assets/icons/appicon.png', // Add an appropriate image in your assets
            height: 100,
            width: 100,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
            // Add functionality to setup email later
          },
          child: Text(
            "Later",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Get.back();
            // Navigate to email setup screen
            Get.toNamed(Routes.settings);
          },
          child: Text("Setup Email Now"),
        ),
      ],
    ));
  }
}
