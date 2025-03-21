import 'package:flutter/material.dart';

import '../../../../../core/constants/routes.dart';
import '../../../../../core/utils/navigation_helper.dart';
import '../../../../auth/services/auth_service.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Account',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                NavigationHelper.pushNamed(context, AppRoutes.profile);
              },
              child: const Text("My Profile"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _authService.deleteUserAccount(context).then((value) {
                  if (!context.mounted) return;
                  NavigationHelper.pushAndRemoveUntilNamed(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                });
              },
              child: const Text("Delete Account"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _authService.signOut().then((value) {
                  if (!context.mounted) return;
                  NavigationHelper.pushAndRemoveUntilNamed(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                });
              },
              child: const Text("Sign Out"),
            ),
          ],
        ),
      ),
    );
  }
}
