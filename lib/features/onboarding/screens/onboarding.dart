import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/routes.dart';
import '../../../core/constants/strings.dart';
import '../../../core/utils/navigation_helper.dart';
import '../../../core/utils/secure_storage/secure_storage_keys.dart';
import '../../../core/utils/secure_storage/secure_storage_util.dart';
import '../widgets/onboarding_page_content.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
  final SecureStorageUtil secureStorageUtil = SecureStorageUtil();

  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<Map<String, dynamic>> onboardingData = [
    {
      "title": AppStrings.pageOneTitle,
      "description": AppStrings.pageOneDescription,
      "icon": "assets/medicine_time.png",
    },
    {
      "title": AppStrings.pageTwoTitle,
      "description": AppStrings.pageTwoDescription,
      "icon": "assets/family_icon.png",
    },
    {
      "title": AppStrings.pageThreeTitle,
      "description": AppStrings.pageThreeDescription,
      "icon": "assets/notification.png",
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Expanded(
            flex: 8,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemCount: onboardingData.length,
              itemBuilder: (context, index) => OnboardingPageContent(
                title: onboardingData[index]['title']!,
                description: onboardingData[index]['description']!,
                image: onboardingData[index]['icon']!,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    onboardingData.length,
                    (index) => buildDot(index),
                  ),
                ),
                SizedBox(height: 20.h),
                _currentPage == onboardingData.length - 1
                    ? ElevatedButton(
                        onPressed: () async {
                          await secureStorageUtil.save(hasOnboarded, "true");

                          if (!context.mounted) return;
                          NavigationHelper.pushAndRemoveUntilNamed(
                            context,
                            AppRoutes.login,
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ).r,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20).r,
                          ),
                        ),
                        child: Text(
                          "Get Started",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : TextButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text(
                          "Next",
                          style: TextStyle(color: Color(0xFF673AB7)),
                        ),
                      ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.only(right: 5).r,
      height: 10.h,
      width: _currentPage == index ? 20.w : 10.w,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? const Color(0xFF673AB7)
            : const Color(0xFFBDBDBD),
        borderRadius: BorderRadius.circular(10).r,
      ),
    );
  }
}
