import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:godare/Values/colors_app.dart';

import '../../Basics/modal_html.dart';

class PrivacyPolicyCheckbox extends StatefulWidget {
  const PrivacyPolicyCheckbox({
    Key? key,
    required this.labelText,
    required this.privacyPolicyUrl,
    this.onChanged,
  }) : super(key: key);

  final String labelText;
  final String privacyPolicyUrl;
  final ValueChanged<bool>? onChanged;

  @override
  State<PrivacyPolicyCheckbox> createState() => PrivacyPolicyCheckboxState();
}

class PrivacyPolicyCheckboxState extends State<PrivacyPolicyCheckbox> {
  bool _isAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: _isAccepted,
          onChanged: (value) {
            setState(() {
              _isAccepted = value!;
            });
            if (widget.onChanged != null) {
              widget.onChanged!(_isAccepted);
            }
          },
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: widget.labelText,
                style: const TextStyle(
                  color: ColorsApp.baseBlackLogo,
                ),
              ),
              TextSpan(
                text: ' Política de privacidad',
                style: const TextStyle(
                  color: ColorsApp.basePink,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ModalHTML(url: widget.privacyPolicyUrl);
                      },
                    );
                  },
              ),
            ],
          ),
          maxLines: 1,
        ),
      ],
    );
  }
}
