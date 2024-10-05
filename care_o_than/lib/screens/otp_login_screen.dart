import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:logging/logging.dart';

class OtpLoginScreen extends StatefulWidget {
  const OtpLoginScreen({super.key});

  @override
  OtpLoginScreenState createState() => OtpLoginScreenState();
}

class OtpLoginScreenState extends State<OtpLoginScreen> {
  final ApiService _apiService = ApiService();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _logger = Logger('OtpLoginScreen');

  void _loginWithOtp() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        //String publicKey = await _apiService.getPublicKey();
       // String encryptedOtp = await _apiService.encryptData(_otpController.text, publicKey);

        // Call the API to verify OTP
        final response = await _apiService.postWithAuth('v3/login/otp/verify', {
          //'otp': encryptedOtp,
          'otpSystem': 'aadhaar'
        });

        if (response.statusCode == 200) {
          _logger.info('Logged in successfully');
        } else {
          _logger.severe('Error: ${response.body}');
        }
      } catch (e) {
        _logger.severe('Exception: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login with OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _otpController,
                decoration: const InputDecoration(labelText: 'Enter OTP'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter the OTP';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loginWithOtp,
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
