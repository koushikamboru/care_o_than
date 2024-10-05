// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../services/api_service.dart';  // Ensure this path is correct

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  RegistrationScreenState createState() => RegistrationScreenState();
}

class RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _aadhaarNumber = '';
  String _mobileNumber = '';
  String _otp = '';
  bool _isAadhaarVerified = false;
  String _transactionId = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aadhaar Verification'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Verify Aadhaar and Mobile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Aadhaar Number',
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (value) => _aadhaarNumber = value!,
                      validator: (value) {
                        if (value == null || value.length != 12) {
                          return 'Enter a valid Aadhaar number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Mobile Number',
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (value) => _mobileNumber = value!,
                      validator: (value) {
                        if (value == null || value.length != 10) {
                          return 'Enter a valid mobile number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          // Call API Service to verify Aadhaar and get transaction ID
                          _transactionId = await ApiService.sendAadhaarOtp(_aadhaarNumber);
                          setState(() {
                            _isAadhaarVerified = true;
                          });
                        }
                      },
                      child: const Text('Verify Aadhaar'),
                    ),
                    if (_isAadhaarVerified)
                      Column(
                        children: [
                          const SizedBox(height: 20),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Enter OTP',
                              border: OutlineInputBorder(),
                            ),
                            onSaved: (value) => _otp = value!,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () async {
                              _formKey.currentState!.save();
                              bool isMobileValid = await ApiService.verifyAadhaarOtp(
                                _transactionId,
                                _mobileNumber,
                                _otp,
                              );

                              if (!mounted) return; // Ensure context is valid

                              if (isMobileValid) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Mobile number verified successfully!')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Mobile number verification failed.')),
                                );
                              }
                            },
                            child: const Text('Verify Mobile Number'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
