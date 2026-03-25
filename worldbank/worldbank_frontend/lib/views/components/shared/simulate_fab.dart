// =============================================================================
// shared/simulate_fab.dart
// 입금 시뮬레이션 FAB — 모든 국가 View에서 공유
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/bank_provider.dart';

class SimulateDepositFab extends StatefulWidget {
  final Color backgroundColor;
  final Color foregroundColor;
  final String label;

  const SimulateDepositFab({
    super.key,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.label,
  });

  @override
  State<SimulateDepositFab> createState() => _SimulateDepositFabState();
}

class _SimulateDepositFabState extends State<SimulateDepositFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onPressed() async {
    final provider = context.read<BankProvider>();
    if (provider.isDepositing) return;
    await _ctrl.forward();
    await provider.simulateDeposit();
    if (mounted) await _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BankProvider>();

    return ScaleTransition(
      scale: _scaleAnim,
      child: FloatingActionButton.extended(
        onPressed: _onPressed,
        backgroundColor: provider.isDepositing
            ? widget.backgroundColor.withValues(alpha: 0.65)
            : widget.backgroundColor,
        elevation: 5,
        icon: provider.isDepositing
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: widget.foregroundColor,
                ),
              )
            : Icon(Icons.add_rounded, color: widget.foregroundColor, size: 20),
        label: Text(
          widget.label,
          style: TextStyle(
            color: widget.foregroundColor,
            fontWeight: FontWeight.w700,
            fontSize: 13,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
