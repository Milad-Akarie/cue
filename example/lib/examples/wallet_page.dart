import 'package:cue/cue.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final transactions = [
    (icon: Iconsax.arrow_up, label: 'Spotify', amount: '-\$12.99', time: 'Today, 9:41 AM', color: Colors.red),
    (icon: Iconsax.arrow_down, label: 'Salary', amount: '+\$4,250.00', time: 'Today, 12:00 PM', color: Colors.green),
    (icon: Iconsax.shopping_cart, label: 'Amazon', amount: '-\$89.00', time: 'Yesterday', color: Colors.orange),
    (icon: Iconsax.dollar_square, label: 'Dividend', amount: '+\$156.32', time: 'Mar 5', color: Colors.green),
    (icon: Iconsax.card_add, label: 'Netflix', amount: '-\$15.99', time: 'Mar 4', color: Colors.red),
  ];

  final quickActions = [
    (icon: Iconsax.wallet_3, label: 'Send'),
    (icon: Iconsax.receipt_search, label: 'Request'),
    (icon: Iconsax.refresh, label: 'Top Up'),
    (icon: Iconsax.chart_21, label: 'Invest'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Cue.onMount(
            motion: .bouncy(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(theme),
                const SizedBox(height: 24),
                _buildCreditCard(theme),
                const SizedBox(height: 24),
                _buildQuickActions(theme),
                const SizedBox(height: 24),
                _buildTransactions(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Actor(
          acts: [.slideX(from: -0.5), .fadeIn()],
          child: Text(
            'Wallet',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        const Spacer(),
        Actor(
          acts: [.slideX(from: 0.5), .fadeIn()],
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Iconsax.notification,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreditCard(ThemeData theme) {
    return Actor(
      acts: [.scale(from: 0.8), .fadeIn(), .slideY(from: 0.3)],
      delay: 100.ms,
      child: Container(
        height: 200,
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF667EEA),
              const Color(0xFF764BA2),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667EEA).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Actor(
                  acts: [.fadeIn(), .blur(from: 8)],
                  delay: 200.ms,
                  child: Text(
                    'Current Balance',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ),
                const Spacer(),
                Actor(
                  acts: [.fadeIn(), .blur(from: 8)],
                  delay: 250.ms,
                  child: Icon(
                    Iconsax.wifi,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Actor(
              acts: [.fadeIn(), .blur(from: 8)],
              delay: 300.ms,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 12842.50),
                duration: const Duration(milliseconds: 1500),
                builder: (context, value, child) {
                  return Text(
                    '\$${value.toStringAsFixed(2)}',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  );
                },
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Actor(
                  acts: [.fadeIn(), .slideX(from: -0.3)],
                  delay: 400.ms,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CARD HOLDER',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white54,
                          fontSize: 9,
                        ),
                      ),
                      Text(
                        'ALEXANDER',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Actor(
                  acts: [.fadeIn(), .slideX(from: 0.3)],
                  delay: 450.ms,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VALID THRU',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white54,
                          fontSize: 9,
                        ),
                      ),
                      Text(
                        '12/28',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Actor(
                  acts: [.fadeIn(), .scale(from: 0.5)],
                  delay: 500.ms,
                  child: Container(
                    width: 50,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        'VISA',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Actor(
          acts: [.fadeIn(), .slideY(from: 0.3)],
          delay: 200.ms,
          child: Text(
            'Quick Actions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          spacing: 12,
          children: List.generate(
            quickActions.length,
            (index) {
              final item = quickActions[index];
              return Expanded(
                child: Actor(
                  acts: [
                    .fadeIn(),
                    .slideX(from: index.isEven ? -0.3 : 0.3),
                  ],
                  delay: Duration(milliseconds: 250 + (index * 50)),
                  child: Material(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {},
                      child: Container(
                        width: 70,
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                item.icon,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.label,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransactions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Actor(
          acts: [.fadeIn(), .slideY(from: 0.3)],
          delay: 300.ms,
          child: Row(
            children: [
              Text(
                'Recent Transactions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                'See All',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(transactions.length, (index) {
          final item = transactions[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Actor(
              acts: [
                .fadeIn(),
                .slideX(from: index.isEven ? -0.3 : 0.3),
              ],
              delay: Duration(milliseconds: 350 + (index * 80)),
              child: Material(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item.icon,
                          size: 20,
                          color: item.color,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.label,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              item.time,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        item.amount,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: item.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
