import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stock_flow/Data%20Layear/Controller/auth_controller.dart';
import 'package:stock_flow/Comon%20part%20for%20all/premium_theme.dart';

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.find<AuthController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, 
            color: isDark ? Colors.white : PremiumTheme.lightTextPrimary, 
            size: 20
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create Account",
                style: theme.textTheme.displaySmall,
              ),
              const SizedBox(height: 12),
              Text(
                "Join Stock Flow to start managing your business smarter.",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark ? PremiumTheme.darkTextSecondary : PremiumTheme.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 40),
              
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputLabel(context, "First Name"),
                        TextField(
                          controller: controller.regFnameController,
                          decoration: const InputDecoration(
                            hintText: "John",
                            prefixIcon: Icon(Icons.person_outline_rounded, size: 22),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputLabel(context, "Last Name"),
                        TextField(
                          controller: controller.regLnameController,
                          decoration: const InputDecoration(
                            hintText: "Doe",
                            prefixIcon: Icon(Icons.person_outline_rounded, size: 22),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              _buildInputLabel(context, "Email Address"),
              TextField(
                controller: controller.regEmailController,
                decoration: const InputDecoration(
                  hintText: "john.doe@example.com",
                  prefixIcon: Icon(Icons.email_outlined, size: 22),
                ),
              ),
              const SizedBox(height: 24),
              
              _buildInputLabel(context, "Phone Number"),
              TextField(
                controller: controller.regPhonController,
                decoration: const InputDecoration(
                  hintText: "+1 234 567 890",
                  prefixIcon: Icon(Icons.phone_outlined, size: 22),
                ),
              ),
              const SizedBox(height: 24),
              
              _buildInputLabel(context, "Password"),
              TextField(
                controller: controller.regPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: "••••••••",
                  prefixIcon: Icon(Icons.lock_outline_rounded, size: 22),
                ),
              ),
              const SizedBox(height: 48),
              
              Obx(() => ElevatedButton(
                onPressed: controller.isLoginLoading.value ? null : controller.register,
                child: controller.isLoginLoading.value
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Create Account"),
              )),
              
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?", 
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? PremiumTheme.darkTextSecondary : PremiumTheme.lightTextSecondary,
                    )
                  ),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      "Sign In",
                      style: GoogleFonts.inter(
                        color: PremiumTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
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
