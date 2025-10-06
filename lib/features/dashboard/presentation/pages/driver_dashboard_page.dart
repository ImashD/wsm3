import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/auth_service.dart';

class DriverDashboardPage extends StatelessWidget {
  const DriverDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'switch_role') {
                context.go('/role-selection');
              } else if (value == 'logout') {
                await AuthService().signOut();
                if (context.mounted) {
                  context.go('/signin');
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'switch_role',
                child: Text('Switch Role'),
              ),
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _DashboardCard(
            title: 'Available Jobs',
            icon: Icons.local_shipping,
            onTap: () {
              // TODO: Implement available transport jobs view
            },
          ),
          _DashboardCard(
            title: 'My Deliveries',
            icon: Icons.delivery_dining,
            onTap: () {
              // TODO: Implement active deliveries view
            },
          ),
          _DashboardCard(
            title: 'Earnings',
            icon: Icons.account_balance_wallet,
            onTap: () {
              // TODO: Implement earnings view
            },
          ),
          _DashboardCard(
            title: 'Vehicle Details',
            icon: Icons.directions_car,
            onTap: () {
              // TODO: Implement vehicle management
            },
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
