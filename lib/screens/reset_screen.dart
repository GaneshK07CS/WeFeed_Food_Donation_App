import 'package:flutter/material.dart';
import 'package:flutterapk/reusable_widget/reusable_widget.dart';
import 'package:flutterapk/screens/signin_screen.dart';
import 'package:flutterapk/screens/utils/color_utils.dart';
import 'package:flutterapk/services/app_state.dart';
import 'package:flutterapk/services/email_service.dart';

class ResetPassword extends StatefulWidget {
  final String? initialEmail;

  const ResetPassword({super.key, this.initialEmail});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  late final TextEditingController _emailTextController;
  final TextEditingController _otpTextController = TextEditingController();
  final TextEditingController _newPasswordTextController = TextEditingController();
  final TextEditingController _confirmPasswordTextController = TextEditingController();

  final GlobalKey<FormState> _emailFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _resetFormKey = GlobalKey<FormState>();

  int _step = 1; // 1 = Enter Email & Get Code, 2 = Enter OTP & Set New Password
  String _generatedOtp = "";
  String _userName = "";
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final prefilled = widget.initialEmail?.trim() ?? AppState.instance.rememberedEmail.trim();
    _emailTextController = TextEditingController(text: prefilled);
  }

  @override
  void dispose() {
    _emailTextController.dispose();
    _otpTextController.dispose();
    _newPasswordTextController.dispose();
    _confirmPasswordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _step == 1 ? "Forgot Password" : "Set New Password",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
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
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: _step == 1 ? _buildStepOneEmail() : _buildStepTwoReset(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Step 1: Request Verification Code for Email ---

  Widget _buildStepOneEmail() {
    return Form(
      key: _emailFormKey,
      child: Column(
        children: <Widget>[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_reset, size: 64, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Text(
            "Account Recovery",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Enter your registered email address to verify your identity and reset your password.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 30),
          reusableTextField(
            "Enter Registered Email",
            Icons.email_outlined,
            false,
            _emailTextController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Please enter your registered email";
              }
              if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                  .hasMatch(value.trim())) {
                return "Please enter a valid email address";
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : firebaseButton(
                  context,
                  "Verify & Send Reset Code",
                  _handleGenerateOtp,
                  icon: Icons.send_rounded,
                ),
          const SizedBox(height: 15),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Remember your password? Sign In",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 40),
          _buildBrandingBadge(),
        ],
      ),
    );
  }

  // --- Step 2: Enter OTP & Set New Password ---

  Widget _buildStepTwoReset() {
    return Form(
      key: _resetFormKey,
      child: Column(
        children: <Widget>[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.25),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.greenAccent.shade200, width: 2),
            ),
            child: const Icon(Icons.verified_user_rounded, size: 54, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            _userName.isNotEmpty ? "Hello, $_userName" : "Reset Password",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Account: ${_emailTextController.text.trim()}",
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // --- On-Screen OTP Assistance Banner ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.key, color: Colors.yellowAccent, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      "Your Reset OTP Code:",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _generatedOtp,
                        style: const TextStyle(
                          color: Colors.yellowAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      _otpTextController.text = _generatedOtp;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("⚡ OTP Auto-filled successfully!"),
                        duration: Duration(seconds: 1),
                        backgroundColor: Colors.teal,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt, color: Colors.deepPurple, size: 16),
                        SizedBox(width: 4),
                        Text(
                          "Auto-Fill Code",
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // --- OTP Text Field ---
          reusableTextField(
            "Enter 4-Digit OTP Code",
            Icons.pin_outlined,
            false,
            _otpTextController,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Please enter the verification code";
              }
              if (value.trim() != _generatedOtp && value.trim() != "1234") {
                return "Incorrect OTP. Use '$_generatedOtp' or '1234'";
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          // --- New Password Field with Eye Toggle ---
          reusableTextField(
            "New Password (min 6 chars)",
            Icons.lock_outline,
            _obscureNewPassword,
            _newPasswordTextController,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.white70,
              ),
              onPressed: () {
                setState(() => _obscureNewPassword = !_obscureNewPassword);
              },
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Please enter a new password";
              }
              if (value.trim().length < 6) {
                return "Password must be at least 6 characters";
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          // --- Confirm Password Field with Eye Toggle ---
          reusableTextField(
            "Confirm New Password",
            Icons.lock_reset,
            _obscureConfirmPassword,
            _confirmPasswordTextController,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.white70,
              ),
              onPressed: () {
                setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
              },
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Please confirm your new password";
              }
              if (value.trim() != _newPasswordTextController.text.trim()) {
                return "Passwords do not match";
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : firebaseButton(
                  context,
                  "Update & Save Password",
                  _handleSaveNewPassword,
                  icon: Icons.check_circle_outline,
                  backgroundColor: Colors.white,
                ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: _handleGenerateOtp,
                icon: const Icon(Icons.refresh, color: Colors.yellowAccent, size: 16),
                label: const Text(
                  "Resend Email OTP",
                  style: TextStyle(
                    color: Colors.yellowAccent,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              const Text(" • ", style: TextStyle(color: Colors.white38)),
              TextButton(
                onPressed: () {
                  setState(() {
                    _step = 1;
                  });
                },
                child: const Text(
                  "Change email address",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          _buildBrandingBadge(),
        ],
      ),
    );
  }

  // --- Logic Methods ---

  Future<void> _handleGenerateOtp() async {
    if (!_emailFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailTextController.text.trim().toLowerCase();
    final appState = AppState.instance;

    // Check if user is registered
    final isRegistered = appState.isUserRegistered(email);
    final user = appState.getUserByEmail(email);

    await Future.delayed(const Duration(milliseconds: 300));

    setState(() => _isLoading = false);

    if (!isRegistered && user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No account found for '$email'. Please sign up first."),
          backgroundColor: Colors.redAccent.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final code = appState.generateResetOtp(email);
    final userName = user?.name ?? email.split('@').first;

    // Dispatch real email via EmailService
    EmailService.sendResetOtpEmail(
      toEmail: email,
      userName: userName,
      otpCode: code,
    );

    setState(() {
      _generatedOtp = code;
      _userName = userName;
      _step = 2;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.mark_email_read_outlined, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "📧 OTP email sent to $email! (Code: $code)",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.teal.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> _handleSaveNewPassword() async {
    if (!_resetFormKey.currentState!.validate()) return;

    final email = _emailTextController.text.trim().toLowerCase();
    final otp = _otpTextController.text.trim();
    final newPass = _newPasswordTextController.text.trim();

    final appState = AppState.instance;

    if (!appState.verifyResetOtp(email, otp)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid OTP code. Please enter the correct code."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Save new password in AppState and local storage
    final success = await appState.updateUserPassword(email, newPass);

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✅ Password reset successful for '$email'! Please sign in."),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Redirect directly to Sign In screen with prefilled email
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SignInScreen(prefilledEmail: email),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to update password. Please try again."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Widget _buildBrandingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.palette_outlined, color: Colors.white, size: 16),
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
    );
  }
}