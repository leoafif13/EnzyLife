import 'package:flutter/material.dart';
import '../../app_color.dart';

class MethodTile extends StatelessWidget {
  final IconData icon;
  final String label, desc;
  final bool selected;
  final VoidCallback onTap;
  const MethodTile({
    super.key,
    required this.icon,
    required this.label,
    required this.desc,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: selected ? AppColors.green50 : AppColors.bgPage,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? AppColors.green500 : AppColors.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: selected ? AppColors.green500 : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: selected ? Colors.white : Colors.grey[500]),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selected ? AppColors.green900 : AppColors.text1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            color: selected ? AppColors.green500 : Colors.grey[400],
            size: 20,
          ),
        ],
      ),
    ),
  );
}
