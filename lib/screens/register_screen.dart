import 'package:arebbus/service/api_service.dart';
import 'package:flutter/material.dart';

/// Utility class providing form validation methods for user registration.
/// 
/// This class contains static methods for validating different types of
/// user input during the registration process. It ensures data integrity
/// and provides user-friendly error messages for invalid inputs.
/// 
/// All validation methods return null for valid input or an error message
/// string for invalid input, following Flutter's form validation pattern.
class FormValidator {
  /// Validates the user's full name input.
  /// 
  /// Checks that the name is not empty and meets minimum length requirements.
  /// 
  /// Parameter:
  /// - [value]: The name string to validate
  /// 
  /// Returns: null if valid, error message if invalid
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    if (value.length < 2) {
      return 'Full name must be at least 2 characters';
    }
    return null;
  }

  /// Validates the user's email address input.
  /// 
  /// Checks that the email is not empty and follows a valid email format
  /// using regular expression pattern matching.
  /// 
  /// Parameter:
  /// - [value]: The email string to validate
  /// 
  /// Returns: null if valid, error message if invalid
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validates the user's password input for security requirements.
  /// 
  /// Ensures the password meets security standards including minimum length
  /// and complexity requirements (uppercase, lowercase, and numbers).
  /// 
  /// Parameter:
  /// - [value]: The password string to validate
  /// 
  /// Returns: null if valid, error message if invalid
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

  /// Validates that the password confirmation matches the original password.
  /// 
  /// Ensures the user has correctly re-entered their chosen password
  /// to prevent registration with mistyped passwords.
  /// 
  /// Parameters:
  /// - [value]: The confirmation password string to validate
  /// - [password]: The original password to match against
  /// 
  /// Returns: null if passwords match, error message if they don't
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

/// Constants class containing styling and layout values for the register screen.
/// 
/// This class centralizes all the design constants used throughout the
/// registration interface to maintain consistency and make theme updates easier.
/// Includes padding, sizing, and spacing values for various UI elements.
class RegisterScreenConstants {
  /// Standard padding used throughout the screen
  static const double padding = 24.0;
  
  /// Size of the application logo
  static const double logoSize = 50.0;
  
  /// Padding around the logo element
  static const double logoPadding = 20.0;
  
  /// Border radius for rounded elements like buttons and input fields
  static const double borderRadius = 8.0;
  
  /// Large spacing between major screen sections
  static const double spacingLarge = 48.0;
  
  /// Medium spacing between related elements
  static const double spacingMedium = 24.0;
  
  /// Small spacing for minor element separation
  static const double spacingSmall = 16.0;
  
  /// Standard height for buttons and input fields
  static const double buttonHeight = 50.0;
  
  /// Primary green color for the application theme
  static const Color primaryColor = Color(0xFF388E3C); // Green shade 600
  
  /// Background color for the screen
  static const Color backgroundColor = Color(0xFFF5F5F5); // Grey 100
  
  /// Shadow color for elevated elements
  static const Color shadowColor = Color(0x1A000000); // Black with opacity 0.1
  
  /// Blur radius for shadow effects
  static const double shadowBlurRadius = 10.0;
  
  /// Offset for shadow positioning
  static const Offset shadowOffset = Offset(0, 4);
}

/// User registration screen for the Arebbus application.
/// 
/// This screen provides a comprehensive registration interface for new users
/// to create accounts in the Arebbus system. It includes form validation,
/// secure password handling, and integration with the authentication API.
/// 
/// Features include:
/// - Full name, email, and password input with validation
/// - Password strength requirements and confirmation
/// - Secure password fields with toggle visibility
/// - Loading state management during registration
/// - Error handling and user feedback
/// - Navigation to login screen for existing users
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

/// State class for the RegisterScreen widget.
/// 
/// Manages user input, form validation, registration requests, and UI state
/// updates. Handles secure password input, confirmation validation, and
/// provides feedback during the registration process.
class _RegisterScreenState extends State<RegisterScreen> {
  /// Form key for validating registration form inputs
  final _formKey = GlobalKey<FormState>();
  
  /// Text controller for full name input field
  final _nameController = TextEditingController();
  
  /// Text controller for email input field
  final _emailController = TextEditingController();
  
  /// Text controller for password input field
  final _passwordController = TextEditingController();
  
  /// Text controller for password confirmation input field
  final _confirmPasswordController = TextEditingController();
  
  /// Loading state indicator for registration operations
  bool _isLoading = false;
  
  /// Flag controlling password field visibility
  bool _obscurePassword = true;
  
  /// Flag controlling password confirmation field visibility
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
  }

  /// Handles user registration process.
  /// 
  /// This method validates the form inputs, makes an API call to register
  /// the new user, and handles the response. It manages loading states and
  /// provides appropriate feedback based on the registration result.
  /// 
  /// On successful registration, the user is navigated to the login screen.
  /// On failure, error messages are displayed to guide the user.
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final response = await ApiService.instance.registerUser(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (response.success) {
      _showSuccessDialog();
    } else {
      _showErrorDialog(response.message);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Registration Successful'),
            content: const Text(
              'Your account has been created successfully. You can now sign in.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushNamed(context, '/'); // Go back to login screen
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
      builder:
          (context) => AlertDialog(
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
      style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(RegisterScreenConstants.padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          RegisterScreenConstants.borderRadius,
        ),
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
                onPressed:
                    () => setState(() => _obscurePassword = !_obscurePassword),
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
                onPressed:
                    () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    ),
              ),
              validator:
                  (value) => FormValidator.validateConfirmPassword(
                    value,
                    _passwordController.text,
                  ),
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
          borderRadius: BorderRadius.circular(
            RegisterScreenConstants.borderRadius,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            RegisterScreenConstants.borderRadius,
          ),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            RegisterScreenConstants.borderRadius,
          ),
          borderSide: const BorderSide(
            color: RegisterScreenConstants.primaryColor,
          ),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordToggle({
    required bool isObscured,
    required VoidCallback onPressed,
  }) {
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
            borderRadius: BorderRadius.circular(
              RegisterScreenConstants.borderRadius,
            ),
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
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
