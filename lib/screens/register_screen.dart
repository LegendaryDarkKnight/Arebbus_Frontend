import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

// Utility class for API configuration
class ApiConfig {
  static Dio initializeDio() {
    const String baseUrl = String.fromEnvironment(
      "BASE_URL",
      defaultValue: "http://localhost:6996",
    );
    
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
        headers: {'Content-Type': 'application/json'},
        extra: kIsWeb ? {'withCredentials': true} : null,
      ),
    );
    
    debugPrint('Dio initialized for ${kIsWeb ? 'web' : 'mobile/desktop'} platform');
    return dio;
  }
}

// Utility class for form validation
class FormValidator {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    if (value.length < 2) {
      return 'Full name must be at least 2 characters';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, and number';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}

// Constants for styling
class RegisterScreenConstants {
  static const double padding = 24.0;
  static const double logoSize = 50.0;
  static const double logoPadding = 20.0;
  static const double borderRadius = 8.0;
  static const double spacingLarge = 48.0;
  static const double spacingMedium = 24.0;
  static const double spacingSmall = 16.0;
  static const double buttonHeight = 50.0;
  static const Color primaryColor = Color(0xFF388E3C); // Green shade 600
  static const Color backgroundColor = Color(0xFFF5F5F5); // Grey 100
  static const Color shadowColor = Color(0x1A000000); // Black with opacity 0.1
  static const double shadowBlurRadius = 10.0;
  static const Offset shadowOffset = Offset(0, 4);
}

// RegisterScreen widget
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late final Dio _dio;

  @override
  void initState() {
    super.initState();
    _dio = ApiConfig.initializeDio();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          _showSuccessDialog();
        }
      }
    } on DioException catch (e) {
      String errorMessage = _getErrorMessage(e);
      if (mounted) {
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('An unexpected error occurred');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getErrorMessage(DioException e) {
    if (e.response == null) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          return 'Connection timeout - Please check your network';
        case DioExceptionType.connectionError:
          return 'Cannot connect to server';
        default:
          return 'Registration failed';
      }
    }

    final response = e.response!;
    String errorMessage = 'Registration failed';
    
    switch (response.statusCode) {
      case 400:
        errorMessage = 'Invalid registration data';
        break;
      case 409:
        errorMessage = 'User already exists with this email';
        break;
      case 422:
        errorMessage = 'Invalid input data';
        break;
      case 500:
        errorMessage = 'Server error - Please try again later';
        break;
      default:
        errorMessage = 'Registration failed - ${response.statusMessage}';
    }

    if (response.data is Map && response.data.containsKey('message')) {
      errorMessage = response.data['message'].toString();
    } else if (response.data is Map && response.data.containsKey('error')) {
      errorMessage = response.data['error'].toString();
    }

    return errorMessage;
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Registration Successful'),
        content: const Text('Your account has been created successfully. You can now sign in.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to login screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registration Error'),
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RegisterScreenConstants.backgroundColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(RegisterScreenConstants.padding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                const SizedBox(height: RegisterScreenConstants.spacingMedium),
                _buildTitle(),
                const SizedBox(height: 8),
                _buildSubtitle(),
                const SizedBox(height: RegisterScreenConstants.spacingLarge),
                _buildForm(),
                const SizedBox(height: RegisterScreenConstants.spacingMedium),
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(RegisterScreenConstants.logoPadding),
      decoration: const BoxDecoration(
        color: RegisterScreenConstants.primaryColor,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.person_add,
        size: RegisterScreenConstants.logoSize,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Create Account',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Join Arebbus today',
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey.shade600,
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(RegisterScreenConstants.padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(RegisterScreenConstants.borderRadius),
        boxShadow: const [
          BoxShadow(
            color: RegisterScreenConstants.shadowColor,
            blurRadius: RegisterScreenConstants.shadowBlurRadius,
            offset: RegisterScreenConstants.shadowOffset,
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person_outlined,
              validator: FormValidator.validateName,
            ),
            const SizedBox(height: RegisterScreenConstants.spacingSmall),
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: FormValidator.validateEmail,
            ),
            const SizedBox(height: RegisterScreenConstants.spacingSmall),
            _buildTextField(
              controller: _passwordController,
              label: 'Password',
              icon: Icons.lock_outlined,
              obscureText: _obscurePassword,
              suffixIcon: _buildPasswordToggle(
                isObscured: _obscurePassword,
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: FormValidator.validatePassword,
            ),
            const SizedBox(height: RegisterScreenConstants.spacingSmall),
            _buildTextField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              icon: Icons.lock_outlined,
              obscureText: _obscureConfirmPassword,
              suffixIcon: _buildPasswordToggle(
                isObscured: _obscureConfirmPassword,
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
              validator: (value) => FormValidator.validateConfirmPassword(value, _passwordController.text),
            ),
            const SizedBox(height: RegisterScreenConstants.spacingMedium),
            _buildRegisterButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RegisterScreenConstants.borderRadius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RegisterScreenConstants.borderRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RegisterScreenConstants.borderRadius),
          borderSide: const BorderSide(color: RegisterScreenConstants.primaryColor),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordToggle({required bool isObscured, required VoidCallback onPressed}) {
    return IconButton(
      icon: Icon(isObscured ? Icons.visibility : Icons.visibility_off),
      onPressed: onPressed,
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: RegisterScreenConstants.buttonHeight,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: RegisterScreenConstants.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RegisterScreenConstants.borderRadius),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: TextStyle(color: Colors.grey.shade600),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Text(
            'Sign In',
            style: TextStyle(
              color: RegisterScreenConstants.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}