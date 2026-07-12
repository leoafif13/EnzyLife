import 'package:flutter/material.dart';
import '../app_color.dart';

/// Widget accordion/expandable yang dipakai bersama untuk FAQ,
/// Bantuan, dan Kebijakan Privasi agar desainnya seragam.
class ExpandableTile extends StatefulWidget {
  final String title;
  final String content;
  final Widget? leading;

  const ExpandableTile({
    super.key,
    required this.title,
    required this.content,
    this.leading,
  });

  @override
  State<ExpandableTile> createState() => _ExpandableTileState();
}

class _ExpandableTileState extends State<ExpandableTile>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final double answerPadLeft = widget.leading != null ? 52 : 16;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.cardShadow,
        border: Border.all(
          color: _expanded ? AppColors.green200 : AppColors.border.withAlpha(80),
          width: _expanded ? 1.2 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: _expanded ? AppColors.green500 : Colors.transparent,
                width: 4.5,
              ),
            ),
          ),
          child: Column(
            children: [
              InkWell(
                onTap: _toggle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  child: Row(
                    children: [
                      if (widget.leading != null) ...[
                        widget.leading!,
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: _expanded ? FontWeight.w700 : FontWeight.w600,
                            color: _expanded ? AppColors.green700 : AppColors.text1,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: _expanded ? AppColors.green500 : Colors.grey[400],
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizeTransition(
                sizeFactor: _anim,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(answerPadLeft, 4, 16, 16),
                  color: AppColors.green50.withAlpha(100),
                  child: Text(
                    widget.content,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.text2,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Badge "Q" yang dipakai sebagai leading pada daftar FAQ/Bantuan.
class QBadge extends StatelessWidget {
  const QBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: AppColors.green50,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          'Q',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.green700,
          ),
        ),
      ),
    );
  }
}
