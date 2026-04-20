import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:godare/Values/colors_app.dart';
import '../../../Common/my_routers.dart'; // Import for TapGestureRecognizer

class MyTextLink extends StatelessWidget {
  final String firstText;
  final String linkText;
  final String navigateToRoute;

  const MyTextLink({
    Key? key,
    required this.firstText,
    required this.linkText,
    required this.navigateToRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: firstText, style: TextStyle(color: ColorsApp.baseBlackLogo)),
          _buildLinkText(linkText, navigateToRoute, context),
          // Pass context explicitly
        ],
      ),
      maxLines: 1,
    );
  }

  TextSpan _buildLinkText(
      String linkText, String navigateToRoute, BuildContext context) {
    return TextSpan(
      text: linkText,
      style: const TextStyle(
        color: ColorsApp.basePink,
        decoration: TextDecoration.underline,
      ),
      recognizer: TapGestureRecognizer()
        ..onTap = () => Navigator.of(context).push(
              // Use context passed to the method
              MyRouters.generateRoute(RouteSettings(name: navigateToRoute)),
            ),
    );
  }
}
