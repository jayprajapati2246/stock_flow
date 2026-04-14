import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stock_flow/Data%20Layear/Controller/auth_controller.dart';
import 'package:stock_flow/Comon%20part%20for%20all/premium_theme.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.find<AuthController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Hero(
                tag: 'app_logo',
                child: Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: PremiumTheme.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: PremiumTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.inventory_2_rounded, color: Colors.white, size: 36),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "Welcome Back",
                style: theme.textTheme.displaySmall,
              ),
              const SizedBox(height: 12),
              Text(
                "Sign in to manage your inventory and sales effortlessly.",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark ? PremiumTheme.darkTextSecondary : PremiumTheme.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 48),
              
              _buildInputLabel(context, "Email Address"),
              TextField(
                controller: controller.emailController,
                decoration: const InputDecoration(
                  hintText: "Enter your email",
                  prefixIcon: Icon(Icons.email_outlined, size: 22),
                ),
              ),
              const SizedBox(height: 24),
              
              _buildInputLabel(context, "Password"),
              TextField(
                controller: controller.passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: "••••••••",
                  prefixIcon: Icon(Icons.lock_outline_rounded, size: 22),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    "Forgot Password?",
                    style: GoogleFonts.inter(
                      color: PremiumTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              Obx(() => ElevatedButton(
                onPressed: (controller.isLoginLoading.value || controller.isGoogleLoading.value) 
                  ? null 
                  : controller.login,
                child: controller.isLoginLoading.value
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Sign In"),
              )),
              
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: Divider(color: theme.dividerColor)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Or continue with", 
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? PremiumTheme.darkTextSecondary : PremiumTheme.lightTextSecondary,
                      )
                    ),
                  ),
                  Expanded(child: Divider(color: theme.dividerColor)),
                ],
              ),
              const SizedBox(height: 32),
              
              Obx(() => OutlinedButton(
                onPressed: (controller.isLoginLoading.value || controller.isGoogleLoading.value)
                    ? null
                    : controller.signInWithGoogle,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: theme.dividerColor),
                ),
                child: controller.isGoogleLoading.value
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: PremiumTheme.primaryColor, strokeWidth: 2))
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network("https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png", height: 22),
                      const SizedBox(width: 12),
                      Text(
                        "Sign in with Google",
                        style: theme.textTheme.titleMedium?.copyWith(fontSize: 15),
                      ),
                    ],
                  ),
              )),
              
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "New here?", 
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? PremiumTheme.darkTextSecondary : PremiumTheme.lightTextSecondary,
                    )
                  ),
                  TextButton(
                    onPressed: controller.goToRegistration,
                    child: Text(
                      "Create an account",
                      style: GoogleFonts.inter(
                        color: PremiumTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
