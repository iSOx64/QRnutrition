import 'package:flutter/material.dart';

class FilterChips extends StatelessWidget {
  const FilterChips({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  final List<String> items;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isSelected = item == selected;
        return ChoiceChip(
          label: Text(item),
          selected: isSelected,
          onSelected: (_) {
            if (isSelected) {
              onSelected(null);
            } else {
              onSelected(item);
            }
          },
        );
      }).toList(),
    );
  }
}
