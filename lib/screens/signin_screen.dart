import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterapk/reusable_widget/reusable_widget.dart';
import 'package:flutterapk/screens/choose_user.dart';
import 'package:flutterapk/screens/reset_screen.dart';
import 'package:flutterapk/screens/signup_screen.dart';
import 'package:flutterapk/screens/utils/color_utils.dart';
import 'package:flutterapk/services/app_state.dart';

class SignInScreen extends StatefulWidget {
  final String? prefilledEmail;

  const SignInScreen({super.key, this.prefilledEmail});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late final TextEditingController _emailTextController;
  final TextEditingController _passwordTextController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final initialEmail = widget.prefilledEmail?.trim() ?? AppState.instance.rememberedEmail.trim();
    _emailTextController = TextEditingController(text: initialEmail);
  }

  @override
  void dispose() {
    _emailTextController.dispose();
    _passwordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hexStringToColor("CB2B93"),
              hexStringToColor("9546C4"),
              hexStringToColor("5E61F4"),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                      24, MediaQuery.of(context).size.height * 0.08, 24, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                      logoWidget("assets/images/logo1.png"),
                      const SizedBox(height: 10),
                      const Text(
                        "WeFeed Food Donation",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Sign in to your account to continue",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 30),
                      reusableTextField(
                        "Enter Email",
                        Icons.email_outlined,
                        false,
                        _emailTextController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter your registered email";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      reusableTextField(
                        "Enter Password",
                        Icons.lock_outline,
                        _obscurePassword,
                        _passwordTextController,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter your password";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 6),
                      forgetPassword(context),
                      const SizedBox(height: 10),
                      firebaseButton(
                        context,
                        "Sign In",
                        _signIn,
                        icon: Icons.login_rounded,
                      ),
                      const SizedBox(height: 16),
                      signUpOption(),
                      const SizedBox(height: 35),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.palette_outlined,
                                color: Colors.white, size: 16),
                            SizedBox(width: 8),
                            Text(
                              "Designed by Ganesh Kothule",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
            if (_isLoading)
              Container(
                color: Colors.black45,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final email = _emailTextController.text.trim();
      final password = _passwordTextController.text.trim();

      // Check if user is registered in AppState or Firebase
      final appState = AppState.instance;
      final isRegisteredLocally = appState.isUserRegistered(email);

      bool isAuthenticated = false;
      String userName = "";
      String userRole = "donor";

      if (isRegisteredLocally) {
        if (appState.validateCredentials(email, password)) {
          isAuthenticated = true;
          final user = appState.getUserByEmail(email);
          userName = user?.name ?? "User";
          userRole = user?.defaultRole ?? "donor";
        } else {
          setState(() => _isLoading = false);
          _showPasswordError("Incorrect password entered for '$email'.");
          return;
        }
      } else {
        // Try Firebase if connected
        try {
          final userCredential =
              await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          if (userCredential.user != null) {
            isAuthenticated = true;
            userName = userCredential.user!.displayName ?? email.split('@').first;
          }
        } catch (e) {
          debugPrint("Firebase Auth notice: $e");
        }
      }

      setState(() => _isLoading = false);

      if (isAuthenticated) {
        await appState.setUserSession(
          email: email,
          role: userRole,
          name: userName,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("✅ Login successful! Welcome $userName"),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          // Direct authenticated user to Choose Role screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const chooseUser()),
          );
        }
      } else {
        _showUnregisteredError("No registered account found for '$email'. Please sign up first.");
      }
    }
  }

  void _showPasswordError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: "Reset Password",
          textColor: Colors.yellowAccent,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResetPassword(
                  initialEmail: _emailTextController.text.trim(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showUnregisteredError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: "Sign Up",
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignUpScreen()),
            );
          },
        ),
      ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account?",
            style: TextStyle(color: Colors.white70, fontSize: 14)),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignUpScreen()),
            );
          },
          child: const Text(
            " Sign Up",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget forgetPassword(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 35,
      alignment: Alignment.bottomRight,
      child: TextButton(
        child: const Text(
          "Forgot Password?",
          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
          textAlign: TextAlign.right,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPassword(
                initialEmail: _emailTextController.text.trim(),
              ),
            ),
          );
        },
      ),
    );
  }
}