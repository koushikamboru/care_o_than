import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://dev.abdm.gov.in/api';
  static const String clientId = 'SBXTEST_04';
  static const String clientSecret = 'df5d0805-20e4-4d74-ac07-b52e2beab1fd';

  // Fetch Token
  static Future<String> fetchToken() async {
    final response = await http.post(
      Uri.parse('$baseUrl/hiecm/gateway/v3/sessions'),
      headers: {
        'Content-Type': 'application/json',
        'REQUEST-ID': 'fab678ba-23be-4554-a889-a4cd8b0f40f7',
        'TIMESTAMP': DateTime.now().toIso8601String(),
        'X-CM-ID': 'sbx',
      },
      body: jsonEncode({
        'clientId': clientId,
        'clientSecret': clientSecret,
        'grantType': 'client_credentials',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['accessToken'];
    } else {
      throw Exception('Failed to fetch token');
    }
  }

  // Send Aadhaar OTP
  static Future<String> sendAadhaarOtp(String aadhaarNumber) async {
    String token = await fetchToken();

    final response = await http.post(
      Uri.parse('$baseUrl/v3/enrollment/request/otp'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'aadhaar': aadhaarNumber,  // Encrypt the Aadhaar number before sending
        'purpose': 'verification',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['txnId'];  // Return the transaction ID
    } else {
      throw Exception('Failed to send OTP');
    }
  }

  // Verify Aadhaar OTP and Mobile Number
  static Future<bool> verifyAadhaarOtp(String txnId, String mobileNumber, String otp) async {
    String token = await fetchToken();

    final response = await http.post(
      Uri.parse('$baseUrl/v3/enrollment/enrol/byAadhar'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'otp': otp,  // Encrypt the OTP before sending
        'txnId': txnId,
        'mobile': mobileNumber,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['status'] == 'success';
    } else {
      return false;
    }
  }
}
