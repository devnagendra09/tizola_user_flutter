import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    required this.onCompleted,
    this.onChanged,
  });

  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;

  @override
  State<OtpInput> createState() => OtpInputState();
}

class OtpInputState extends State<OtpInput> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  void clear() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
    widget.onChanged?.call('');
  }

  void setCode(String code) {
    final digits = code.replaceAll(RegExp(r'\D'), '');
    for (var i = 0; i < _controllers.length; i++) {
      _controllers[i].text =
          i < digits.length ? digits[i] : '';
    }
    if (digits.length >= _controllers.length) {
      widget.onCompleted(digits.substring(0, _controllers.length));
    }
    widget.onChanged?.call(value);
  }

  String get value => _controllers.map((c) => c.text).join();

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Padding(
          padding: EdgeInsets.only(left: index == 0 ? 0 : 8),
          child: SizedBox(
            width: 56,
            height: 52,
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: AppColors.brandLite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.brand),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.brand),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.brand,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (val) {
                if (val.length == 1 && index < 3) {
                  _focusNodes[index + 1].requestFocus();
                }
                if (val.isEmpty && index > 0) {
                  _focusNodes[index - 1].requestFocus();
                }
                final otp = value;
                widget.onChanged?.call(otp);
                if (otp.length == 4) {
                  widget.onCompleted(otp);
                }
              },
            ),
          ),
        );
      }),
    );
  }
}
