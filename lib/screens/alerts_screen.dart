import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  // Assumes the Alerts screen is index 2 on your navigation bar
  // int _currentNavIndex = 2;

  // Static mock data to match the design.
  // In Phase 4, this will be replaced with a real stream of notifications.
  final List<Map<String, dynamic>> _alerts = [
    // {
    //   'type': 'danger',
    //   'title': 'Utilities at 92% of cap',
    //   'subtitle': 'EGP 229 of EGP 250 spent — EGP 21 left.',
    //   'time': 'Today · 6:12 PM',
    // },
    // {
    //   'type': 'danger',
    //   'title': 'Food at 91% of cap',
    //   'subtitle': 'EGP 412 of EGP 450 spent — EGP 38 left.',
    //   'time': 'Today · 2:04 PM',
    // },
    // {
    //   'type': 'warning',
    //   'title': '64% of monthly limit used',
    //   'subtitle': 'EGP 715.50 left with 12 days remaining.',
    //   'time': 'Yesterday · 8:00 AM',
    // },
    // {
    //   'type': 'success',
    //   'title': '3 offline entries synced',
    //   'subtitle': 'Saved locally, now synced to your account.',
    //   'time': 'Tue · 9:30 AM',
    // },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: CustomBottomNav(
      //   currentIndex: _currentNavIndex,
      //   onTap: (index) {
      //     setState(() {
      //       _currentNavIndex = index;
      //       // In Phase 3, this is where you will add logic to switch screens
      //     });
      //   },
      //   onAddPressed: () => {},
      // ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Alerts',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'You\'re notified as you near or pass a limit.',
                style: TextStyle(fontSize: 14, color: AppColors.secondaryText),
              ),
              const SizedBox(height: 24),

              // Alerts List

              if (_alerts.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 60.0),
                  child: Center(
                    child: Text(
                      'You have no notifications for now',
                      style: TextStyle(
                        color: AppColors.secondaryText, 
                        fontSize: 16, 
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                )
              else
                ..._alerts.map((alert) => _buildAlertCard(alert)),

              const SizedBox(height: 100), // Padding for the floating nav bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    Color bgColor;
    Color iconColor;
    IconData iconData;

    // Style dynamically based on the alert type
    switch (alert['type']) {
      case 'danger':
        bgColor = Colors.red.withValues(alpha: 0.1);
        iconColor = Colors.redAccent;
        iconData = Icons.warning_amber_rounded;
        break;
      case 'warning':
        bgColor = Colors.amber.withValues(alpha: 0.15);
        iconColor = Colors.orange;
        iconData = Icons.warning_amber_rounded;
        break;
      case 'success':
      default:
        bgColor = AppColors.primaryGreen.withValues(alpha: 0.15);
        iconColor = AppColors.primaryGreen;
        iconData = Icons.check;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Side: Colored Icon Box
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(iconData, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),

          // Right Side: Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert['subtitle'],
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryText,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  alert['time'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
