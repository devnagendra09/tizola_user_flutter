import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/menu_entity.dart';

class ItemCustomizationSelection {
  const ItemCustomizationSelection({
    this.optionId,
    this.addonIds = const [],
  });

  final String? optionId;
  final List<String> addonIds;
}

enum CustomizationRepeatAction { repeat, addNew, cancel }

Future<ItemCustomizationSelection?> showAddonsSelectionSheet(
  BuildContext context,
  MenuItemEntity item,
) {
  return showModalBottomSheet<ItemCustomizationSelection>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddonsSelectionSheet(item: item),
  );
}

Future<CustomizationRepeatAction?> showCustomizationRepeatDialog(
  BuildContext context,
  String itemName,
) {
  return showDialog<CustomizationRepeatAction>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(itemName),
      content: const Text('Repeat last customization or add a new one?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, CustomizationRepeatAction.cancel),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, CustomizationRepeatAction.addNew),
          child: const Text('Add new'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, CustomizationRepeatAction.repeat),
          child: const Text('Repeat'),
        ),
      ],
    ),
  );
}

class _AddonsSelectionSheet extends StatefulWidget {
  const _AddonsSelectionSheet({required this.item});

  final MenuItemEntity item;

  @override
  State<_AddonsSelectionSheet> createState() => _AddonsSelectionSheetState();
}

class _AddonsSelectionSheetState extends State<_AddonsSelectionSheet> {
  String? _selectedOptionId;
  late Set<String> _selectedAddonIds;

  @override
  void initState() {
    super.initState();
    _selectedAddonIds = widget.item.addOns
        .where((addon) => addon.isMandatory)
        .map((addon) => addon.id)
        .toSet();
  }

  void _onSave() {
    if (widget.item.options.isNotEmpty &&
        (_selectedOptionId == null || _selectedOptionId!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select choice of option')),
      );
      return;
    }

    Navigator.of(context).pop(
      ItemCustomizationSelection(
        optionId: _selectedOptionId,
        addonIds: _selectedAddonIds.toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.brandLite,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Text(
                item.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.brand,
                ),
              ),
            ),
            Flexible(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                shrinkWrap: true,
                children: [
                  if (item.options.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Text(
                        'Choice of options',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    ...item.options.map(
                      (option) => RadioListTile<String>(
                        title: Text(option.name),
                        subtitle: _priceSubtitle(
                          option.applicablePrice,
                          option.actualPrice,
                        ),
                        value: option.id,
                        groupValue: _selectedOptionId,
                        activeColor: AppColors.brand,
                        onChanged: (value) {
                          setState(() => _selectedOptionId = value);
                        },
                      ),
                    ),
                  ],
                  if (item.addOns.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text(
                        'Choice of add-ons',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    ...item.addOns.map(
                      (addon) => CheckboxListTile(
                        title: Text(addon.name),
                        subtitle: Text(
                          addon.isMandatory ? '(Required)' : '(Optional)',
                          style: TextStyle(
                            fontSize: 11,
                            color: addon.isMandatory
                                ? Colors.red.shade700
                                : Colors.grey.shade600,
                          ),
                        ),
                        secondary: Text(
                          '₹${addon.price.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        value: _selectedAddonIds.contains(addon.id),
                        activeColor: AppColors.brand,
                        onChanged: addon.isMandatory
                            ? null
                            : (checked) {
                                setState(() {
                                  if (checked == true) {
                                    _selectedAddonIds.add(addon.id);
                                  } else {
                                    _selectedAddonIds.remove(addon.id);
                                  }
                                });
                              },
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brand,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Add'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _priceSubtitle(double applicable, double? actual) {
    if (actual != null && actual != applicable) {
      return Row(
        children: [
          Text(
            '₹${actual.toStringAsFixed(0)}',
            style: TextStyle(
              decoration: TextDecoration.lineThrough,
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 6),
          Text('₹${applicable.toStringAsFixed(0)}'),
        ],
      );
    }
    return Text('₹${applicable.toStringAsFixed(0)}');
  }
}
