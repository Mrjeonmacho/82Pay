// =============================================================================
// shared/animated_tx_list.dart
// 거래 내역 애니메이션 리스트 슬리버 — 국가별 타일 위젯을 주입받아 렌더링
// =============================================================================

import 'package:flutter/material.dart';
import '../../../models/bank_model.dart';

/// 각 국가 View에서 타일 빌더를 람다로 넘겨 사용
/// → 리스트 로직은 공유, UI는 각 국가가 커스텀
class AnimatedTxList extends StatelessWidget {
  final List<TransactionHistory> transactions;
  final Widget Function(BuildContext, TransactionHistory, int) itemBuilder;
  final EdgeInsets padding;

  const AnimatedTxList({
    super.key,
    required this.transactions,
    required this.itemBuilder,
    this.padding = const EdgeInsets.fromLTRB(16, 0, 16, 120),
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: padding,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final tx = transactions[index];
          return _FadeSlideItem(
            // historyId를 key로 → 새 항목만 애니메이션 재실행
            key: ValueKey(tx.historyId),
            isNew: index == 0,
            child: itemBuilder(context, tx, index),
          );
        }, childCount: transactions.length),
      ),
    );
  }
}

// ── 개별 아이템 Fade+Slide 진입 애니메이션 ───────────────────────────────────
class _FadeSlideItem extends StatefulWidget {
  final bool isNew;
  final Widget child;

  const _FadeSlideItem({super.key, required this.isNew, required this.child});

  @override
  State<_FadeSlideItem> createState() => _FadeSlideItemState();
}

class _FadeSlideItemState extends State<_FadeSlideItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    if (widget.isNew) {
      // 새로 추가된 항목만 애니메이션
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _ctrl.forward();
      });
    } else {
      _ctrl.value = 1.0; // 기존 항목은 즉시 표시
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
