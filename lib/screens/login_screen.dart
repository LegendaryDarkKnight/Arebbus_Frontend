import 'package:arebbus/service/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  late Dio dio;

  @override
  void initState() {
    super.initState();
    _initializeDio();
  }

  void _initializeDio() {
    dio = Dio();

    const String baseUrl = String.fromEnvironment(
      "BASE_URL",
      defaultValue: "http://localhost:6996",
    );
    debugPrint(baseUrl);
    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(seconds: 3);

    if (kIsWeb) {
      dio.options.extra['withCredentials'] = true;
    }
    debugPrint(
      'Dio initialized for ${kIsWeb ? 'web' : 'mobile/desktop'} platform',
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await dio.post(
        '/auth/login', // Your login endpoint
        data: {
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          extra:
              kIsWeb
                  ? {'withCredentials': true}
                  : null, 
        ),
      );

      if (response.statusCode == 200) {
        dynamic responseData = response.data;
        String? extractedIdString;

        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('id')) {
            extractedIdString = responseData['id']?.toString();
          } else if (responseData.containsKey('userId')) {
            // Another common key
            extractedIdString = responseData['userId']?.toString();
          } else if (responseData.containsKey('user_id')) {
            // Snake case
            extractedIdString = responseData['user_id']?.toString();
          }
        } else if (responseData is int) {
          extractedIdString = responseData.toString();
        } else if (responseData is String) {
          extractedIdString = responseData;
        }

        if (extractedIdString != null && extractedIdString.isNotEmpty) {
          debugPrint("Login successful. Extracted User ID: $extractedIdString");
          await Provider.of<AuthService>(
            context,
            listen: false,
          ).login(extractedIdString);

          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else {
          debugPrint(
            "Login successful, but User ID was not found or was invalid in the server response. Response data: $responseData",
          );
          if (mounted) {
            _showErrorDialog(
              'Login successful, but could not retrieve user session. Please try again.',
            );
          }
        }
      } else {
        final String apiErrorMessage =
            response.data?['message']?.toString() ??
            response.statusMessage ??
            'Unknown login error';
        _showErrorDialog(
          'Login attempt failed: $apiErrorMessage (Status: ${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Login failed';
      if (e.response != null) {
        debugPrint('DioException Response Status: ${e.response!.statusCode}');
        debugPrint('DioException Response Data: ${e.response!.data}');
        var responseData = e.response!.data;
        String detailMessage = "";
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          detailMessage = responseData['message'].toString();
        } else if (responseData is String && responseData.isNotEmpty) {
          detailMessage = responseData;
        }

        switch (e.response!.statusCode) {
          case 400:
            errorMessage = 'Invalid request. ${detailMessage}'.trim();
            break;
          case 401:
            errorMessage =
                'Unauthorized - Invalid credentials. ${detailMessage}'.trim();
            break;
          case 403:
            errorMessage = 'Forbidden. ${detailMessage}'.trim();
            break;
          case 404:
            errorMessage =
                'User or login endpoint not found. ${detailMessage}'.trim();
            break;
          case 500:
            errorMessage = 'Server error - Please try again later.';
            break;
          default:
            errorMessage =
                detailMessage.isNotEmpty
                    ? detailMessage
                    : 'Login failed - ${e.response!.statusMessage ?? "Service unavailable"}';
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage =
            'Connection timeout - Please check your network and try again.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Network error - Unable to connect to the server.';
      } else {
        errorMessage =
            'An unexpected network error occurred. Please try again.';
      }
      debugPrint("Login DioException: ${e.message}");
      if (mounted) {
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      debugPrint("Login generic error: $e");
      if (mounted) {
        _showErrorDialog('An unexpected error occurred: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Login Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Title
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.directions_bus,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),

                const Text(
                  'Welcome to Arebbus ',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Sign in to your account',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 48),

                // Login Form
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.blue.shade600,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.blue.shade600,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                            ),
                            child:
                                _isLoading
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                    : const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.blue.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
