import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/navigation_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../data/providers/sign_up_provider.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SignUpProvider>(
      builder: (context, signUpProvider, child) {
        return Scaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.r),
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: signUpProvider.formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FlutterLogo(size: 36.spMin),
                          SizedBox(width: 10.w),
                          Text(
                            'MediTrack',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Create Your New Account',
                          style: TextStyle(
                            fontSize: 24.h,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      RPadding(
                        padding: EdgeInsets.only(bottom: 5),
                        child: Text(
                          "Email Address",
                          style: TextStyle(fontSize: 18.sp),
                        ),
                      ),
                      TextFormField(
                        controller: signUpProvider.emailController,
                        decoration: InputDecoration(
                          hintText: 'Enter...',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(12.r),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.deepPurple,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(12.r),
                            ),
                          ),
                        ),
                        validator: validateEmail,
                      ),
                      const SizedBox(height: 20),
                      RPadding(
                        padding: EdgeInsets.only(bottom: 5),
                        child: Text(
                          "Password",
                          style: TextStyle(fontSize: 18.sp),
                        ),
                      ),
                      TextFormField(
                        controller: signUpProvider.passwordController,
                        obscureText: !signUpProvider.passwordVisible,
                        decoration: InputDecoration(
                          hintText: 'Enter...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(12.r),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.deepPurple,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(12.r),
                            ),
                          ),
                          prefixIcon: const Icon(Icons.lock_outline),
                          errorMaxLines: 10,
                          suffixIcon: IconButton(
                            icon: Icon(
                              signUpProvider.passwordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              signUpProvider.togglePasswordVisibility();
                            },
                          ),
                        ),
                        validator: validatePasswordStrength,
                      ),
                      SizedBox(height: 20.h),
                      RPadding(
                        padding: EdgeInsets.only(bottom: 5),
                        child: Text(
                          "Confirm Password",
                          style: TextStyle(fontSize: 18.sp),
                        ),
                      ),
                      TextFormField(
                        controller: signUpProvider.confirmPasswordController,
                        obscureText: !signUpProvider.confirmPasswordVisible,
                        decoration: InputDecoration(
                          hintText: 'Enter...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(12.r),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.deepPurple,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(12.r),
                            ),
                          ),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              signUpProvider.confirmPasswordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              signUpProvider.toggleConfirmPasswordVisibility();
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != signUpProvider.passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20.h),
                      // Error Message if Sign-Up fails
                      if (signUpProvider.errorMessage != null)
                        RPadding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            signUpProvider.errorMessage!,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ElevatedButton(
                        onPressed: () => signUpProvider.onSignUpClick(context),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: Size(
                            MediaQuery.of(context).size.width,
                            45.h,
                          ),
                        ),
                        child: signUpProvider.isSigningUp
                            ? SpinKitThreeBounce(
                                color: Colors.white,
                                size: 24.spMin,
                              )
                            : Text(
                                'Sign-Up',
                                style: TextStyle(fontSize: 18.sp),
                              ),
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account ?"),
                          SizedBox(width: 8.w),
                          InkWell(
                            onTap: () => NavigationHelper.pop(context),
                            borderRadius: BorderRadius.circular(8.r),
                            splashColor: Colors.deepPurple.shade500,
                            child: const RPadding(
                              padding: EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 4,
                              ),
                              child: Text(
                                'Login here',
                                style: TextStyle(color: Colors.deepPurple),
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
          ),
        );
      },
    );
  }
}
