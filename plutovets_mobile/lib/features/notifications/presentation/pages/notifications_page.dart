import 'package:flutter/material.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../../core/widgets/app_placeholder_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPageScaffold(
      title: 'Notifications',
      child: AppPlaceholderState(
        title: 'Notifications en preparation',
        message: 'Les alertes et rappels apparaitront ici bientot.',
        icon: Icons.notifications_none_rounded,
      ),
    );
  }
}
