import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/asymmetric/api.dart'; // Import for RSAPublicKey

class ApiService {
  static const String _baseUrl = 'https://abhasbx.abdm.gov.in/abha/api';
  String? _accessToken;
  String? _refreshToken;

  // Set your clientId and clientSecret here
  final String clientId = 'YOUR_CLIENT_ID';
  final String clientSecret = 'YOUR_CLIENT_SECRET';

  Future<void> generateSessionToken() async {
    final url = Uri.parse('https://dev.abdm.gov.in/api/hiecm/gateway/v3/sessions');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'clientId': clientId,
        'clientSecret': clientSecret,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data['accessToken'];
      _refreshToken = data['refreshToken'];
    } else {
      throw Exception('Failed to generate session token');
    }
  }

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  Future<String?> getPublicKey() async {
    final url = Uri.parse('$_baseUrl/v3/profile/public/certificate');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['publicKey'];
    } else {
      throw Exception('Failed to get public key');
    }
  }

  Future<String> encryptData(String data, String publicKey) async {
    final parser = encrypt.RSAKeyParser();
    final rsaPublicKey = parser.parse(publicKey) as RSAPublicKey; // Correct casting using pointycastle RSAPublicKey
    final encrypter = encrypt.Encrypter(encrypt.RSA(publicKey: rsaPublicKey));
    final encrypted = encrypter.encrypt(data);
    return encrypted.base64;
  }

  Future<http.Response> postWithAuth(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    return await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
  }
}

