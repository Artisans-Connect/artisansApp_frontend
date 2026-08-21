import 'package:flutter/material.dart';

import 'package:artisans_app/shared/presentation/navigation/legal_navigation.dart';

class LegalAgreementText extends StatelessWidget {
  const LegalAgreementText({
    super.key,
    required this.prefix,
    required this.textStyle,
    this.includePrivacyPolicy = true,
    this.suffix = '.',
    this.linkColor,
  });

  final String prefix;
  final TextStyle textStyle;
  final bool includePrivacyPolicy;
  final String suffix;
  final Color? linkColor;

  @override
  Widget build(BuildContext context) {
    final TextStyle linkStyle = textStyle.copyWith(
      color: linkColor ?? Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
    );

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Text(prefix, style: textStyle),
        InkWell(
          onTap: () => LegalNavigation.openTermsOfService(context),
          child: Text('Terms of Service', style: linkStyle),
        ),
        if (includePrivacyPolicy) ...<Widget>[
          Text(' and ', style: textStyle),
          InkWell(
            onTap: () => LegalNavigation.openPrivacyPolicy(context),
            child: Text('Privacy Policy', style: linkStyle),
          ),
        ],
        Text(suffix, style: textStyle),
      ],
    );
  }
}
