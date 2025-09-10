import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/providers/auth_provider.dart';
import 'package:finance_tracker/providers/transaction_provider.dart';
import 'package:finance_tracker/views/settings_screen.dart';
import 'package:finance_tracker/views/add_transaction_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authRepository = ref.watch(authRepositoryProvider);
    final currentUser = authRepository.currentUser;
    final transactionsAsync = ref.watch(transactionsProvider);
    final summary = ref.watch(transactionsSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${currentUser?.email ?? 'User'}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            
            // Financial Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Financial Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('Total Balance: \$${summary['balance']?.toStringAsFixed(2) ?? '0.00'}'),
                    Text('Income: \$${summary['income']?.toStringAsFixed(2) ?? '0.00'}'),
                    Text('Expenses: \$${summary['expense']?.toStringAsFixed(2) ?? '0.00'}'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            const Text(
              'Recent Transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            // Transactions List
            Expanded(
              child: transactionsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
                data: (transactions) => transactions.isEmpty
                    ? const Center(child: Text('No transactions yet. Tap + to add your first transaction!'))
                    : ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];
                          return ListTile(
                            leading: Icon(
                              transaction.type == 'income'
                                  ? Icons.arrow_circle_up
                                  : Icons.arrow_circle_down,
                              color: transaction.type == 'income'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            title: Text(transaction.title),
                            subtitle: Text(
                                '${transaction.category} • ${transaction.date.day}/${transaction.date.month}/${transaction.date.year}'),
                            trailing: Text(
                              '\$${transaction.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: transaction.type == 'income'
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}