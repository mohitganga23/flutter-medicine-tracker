import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_medicine_tracker/core/constants/assets.dart';
import 'package:flutter_medicine_tracker/core/constants/hero.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/routes.dart';
import '../../../core/utils/navigation_helper.dart';
import '../../../core/utils/validators.dart';
import '../providers/login_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginProvider>(
      builder: (context, loginProvider, child) {
        return Scaffold(
          body: Center(
            child: SingleChildScrollView(
              padding: REdgeInsets.symmetric(horizontal: 18),
              child: Form(
                key: loginProvider.formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Hero(
                          tag: AppHeroTag.splashToLogin,
                          child: Image.asset(
                            AppAssets.appLogo,
                            height: 48.h,
                            width: 48.h,
                          ),
                        ),
                        SizedBox(width: 5.w),
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
                        'Sign In To Your Account',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.25,
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
                      controller: loginProvider.emailController,
                      decoration: InputDecoration(
                        hintText: 'Enter...',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(18.r)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.deepPurple,
                            width: 1.w,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(18.r)),
                        ),
                      ),
                      validator: validateEmail,
                    ),
                    SizedBox(height: 18.h),
                    RPadding(
                      padding: EdgeInsets.only(bottom: 5),
                      child: Text(
                        "Password",
                        style: TextStyle(fontSize: 18.sp),
                      ),
                    ),
                    TextFormField(
                      controller: loginProvider.passwordController,
                      obscureText: !loginProvider.passwordVisible,
                      decoration: InputDecoration(
                        hintText: 'Enter...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(18.r)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.deepPurple,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(18.r)),
                        ),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            loginProvider.passwordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            loginProvider.togglePasswordVisibility();
                          },
                        ),
                      ),
                      validator: validatePassword,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          SystemChannels.textInput.invokeMethod(
                            'TextInput.hide',
                          );
                          NavigationHelper.pushNamed(
                            context,
                            AppRoutes.forgotPassword,
                          );
                        },
                        borderRadius: BorderRadius.circular(8.r),
                        splashColor: Colors.deepPurple.shade500,
                        child: const RPadding(
                          padding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 4,
                          ),
                          child: Text(
                            'Forgot password ?',
                            style: TextStyle(color: Colors.deepPurple),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    ElevatedButton.icon(
                      onPressed: () => loginProvider.onLoginWithEmailClick(
                        context,
                      ),
                      style:
                          Theme.of(context).elevatedButtonTheme.style?.copyWith(
                                backgroundColor: WidgetStatePropertyAll(
                                  Colors.deepPurple,
                                ),
                                shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                minimumSize: WidgetStatePropertyAll(
                                  Size(
                                    MediaQuery.of(context).size.width,
                                    45.h,
                                  ),
                                ),
                              ),
                      label: loginProvider.isLoading
                          ? SpinKitThreeBounce(
                              color: Colors.white,
                              size: 24.spMin,
                            )
                          : const Icon(Icons.login_outlined),
                      icon: loginProvider.isLoading
                          ? null
                          : Text(
                              'Login',
                              style: TextStyle(fontSize: 18.sp),
                            ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account ?"),
                        SizedBox(width: 8.w),
                        InkWell(
                          onTap: () {
                            SystemChannels.textInput.invokeMethod(
                              'TextInput.hide',
                            );
                            NavigationHelper.pushNamed(
                              context,
                              AppRoutes.signUp,
                            );
                          },
                          borderRadius: BorderRadius.circular(8.r),
                          splashColor: Colors.deepPurple.shade500,
                          child: const RPadding(
                            padding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 4,
                            ),
                            child: Text(
                              'Sign-up now',
                              style: TextStyle(color: Colors.deepPurple),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Divider(
                            indent: 5,
                            endIndent: 15,
                            color: Colors.grey.shade300,
                          ),
                        ),
                        const Text("OR"),
                        Expanded(
                          child: Divider(
                            indent: 15,
                            endIndent: 5,
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Center(
                      child: OutlinedButton(
                        onPressed: () => loginProvider.onLoginWithGoogleClick(
                          context,
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                          side: const BorderSide(color: Colors.grey),
                          padding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ).r,
                        ),
                        child: loginProvider.isSignInWithGoogle
                            ? SpinKitThreeBounce(
                                color: Colors.deepPurple,
                                size: 24.spMin,
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/google_icon.png',
                                    height: 24.h,
                                  ),
                                  SizedBox(width: 12.w),
                                  Text(
                                    'Sign in with Google',
                                    style: TextStyle(fontSize: 16.sp),
                                  ),
                                ],
                              ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
