import 'package:flutter/material.dart';
import '../../app_color.dart';

class QtyControl extends StatelessWidget {
  final int qty;
  final VoidCallback onAdd, onRemove;
  const QtyControl({
    super.key,
    required this.qty,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.green500),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        GestureDetector(
          onTap: onRemove,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: Icon(Icons.remove, size: 14, color: AppColors.green500),
          ),
        ),
        Text(
          '$qty',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.green500),
        ),
        GestureDetector(
          onTap: onAdd,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: Icon(Icons.add, size: 14, color: AppColors.green500),
          ),
        ),
      ],
    ),
  );
}
