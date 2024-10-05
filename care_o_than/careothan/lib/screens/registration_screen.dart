import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:logging/logging.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  RegistrationScreenState createState() => RegistrationScreenState();
}

class RegistrationScreenState extends State<RegistrationScreen> {
  final ApiService _apiService = ApiService();
  final _aadhaarController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _logger = Logger('RegistrationScreen');

  void _registerWithAadhaar() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await _apiService.generateSessionToken();
        String publicKey = await _apiService.getPublicKey();
        String encryptedAadhaar = await _apiService.encryptData(_aadhaarController.text, publicKey);

        // Call the API to request OTP for Aadhaar
        final response = await _apiService.postWithAuth('v3/enrollment/request/otp', {
          'loginHint': 'aadhaar',
          'loginId': encryptedAadhaar,
          'otpSystem': 'aadhaar'
        });

        if (response.statusCode == 200) {
          _logger.info('OTP sent successfully');
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
      appBar: AppBar(title: const Text('ABHA Registration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _aadhaarController,
                decoration: const InputDecoration(labelText: 'Enter Aadhaar'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.length != 12) {
                    return 'Enter a valid 12-digit Aadhaar';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registerWithAadhaar,
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
