import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/auth_service.dart';

class FarmerDashboardPage extends StatelessWidget {
  const FarmerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Dashboard'),
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
            title: 'Post Job',
            icon: Icons.add_circle,
            onTap: () {
              // TODO: Implement job posting
            },
          ),
          _DashboardCard(
            title: 'Active Jobs',
            icon: Icons.work,
            onTap: () {
              // TODO: Implement active jobs view
            },
          ),
          _DashboardCard(
            title: 'Find Workers',
            icon: Icons.person_search,
            onTap: () {
              // TODO: Implement worker search
            },
          ),
          _DashboardCard(
            title: 'Transport',
            icon: Icons.local_shipping,
            onTap: () {
              // TODO: Implement transport booking
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
