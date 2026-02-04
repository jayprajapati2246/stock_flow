import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_flow/Data%20Layear/Controller/auth_controller.dart';

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.find<AuthController>();
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.only(top: height * 0.09, left: width * 0.02),
                child: Text(
                  "Create Your \nAccount",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: height * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.only(left: width * 0.05),
                child: Text(
                  "Enter Your Full Information \nfor Create Account",
                  style: TextStyle(
                    fontSize: height * 0.03,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: height * 0.10),

              TextField(
                controller: controller.regFnameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  label: const Text("Enter Your First Name"),
                  labelStyle: const TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.white,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.blueAccent,
                      width: 3.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person, color: Colors.white),
                ),
              ),

              SizedBox(height: height * 0.03),

              TextField(
                controller: controller.regLnameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  label: const Text("Enter Your Last Name"),
                  labelStyle: const TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.white,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.blueAccent,
                      width: 3.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person, color: Colors.white),
                ),
              ),

              SizedBox(height: height * 0.03),

              TextField(
                controller: controller.regPhonController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  label: const Text("Enter Your Phone Number"),
                  labelStyle: const TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.white,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.blueAccent,
                      width: 3.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.phone, color: Colors.white),
                ),
              ),

              SizedBox(height: height * 0.03),

              TextField(
                controller: controller.regEmailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  label: const Text("Enter Your Email"),
                  labelStyle: const TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.white,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.blueAccent,
                      width: 3.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.email, color: Colors.white),
                ),
              ),

              SizedBox(height: height * 0.03),

              TextField(
                controller: controller.regPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  label: const Text("Enter Your Password"),
                  labelStyle: const TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.white,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.blueAccent,
                      width: 3.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock, color: Colors.white),
                ),
              ),

              SizedBox(height: height * 0.10),

              Obx(() => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                onPressed: controller.isLoginLoading.value ? null : controller.register,

                child: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: height * 0.07,
                  child: controller.isLoginLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Register",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 27,
                    ),
                  ),
                ),
              )),

              SizedBox(height: height * 0.01),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account ?",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text(
                      "Login ",
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: height * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}