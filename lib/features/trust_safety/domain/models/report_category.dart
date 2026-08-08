import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

enum ReportCategory {
  harassment(
    key: 'HARASSMENT',
    label: 'Harassment or Bullying',
    description: 'Offensive messages, threats, stalking, or inappropriate language.',
  ),
  scamFraud(
    key: 'SCAM_FRAUD',
    label: 'Scam or Fraud',
    description: 'Demanding payment before work, fake quotes, or dishonesty.',
  ),
  fakeIdentity(
    key: 'FAKE_IDENTITY',
    label: 'Fake Identity or Impersonation',
    description: 'Artisan or client using a fake name, photo, or unverified identity.',
  ),
  paymentOutsideApp(
    key: 'PAYMENT_OUTSIDE_APP',
    label: 'Payment Outside App',
    description: 'Asking to settle cash/transfer off the platform to bypass security.',
  ),
  poorWorkmanship(
    key: 'POOR_WORKMANSHIP',
    label: 'Substandard Work or Damage',
    description: 'Job left incomplete, severe property damage, or unsafe execution.',
  ),
  safetyConcern(
    key: 'SAFETY_CONCERN',
    label: 'Personal Safety Concern',
    description: 'Threatening behavior, reckless conduct, or unsafe home situation.',
  ),
  violenceThreat(
    key: 'VIOLENCE_THREAT',
    label: 'Physical Violence or Threats',
    description: 'Aggressive physical confrontation or imminent bodily harm.',
  ),
  propertyDamage(
    key: 'PROPERTY_DAMAGE',
    label: 'Property Damage or Theft',
    description: 'Stolen goods, damaged appliances, or home property destruction.',
  ),
  noShow(
    key: 'NO_SHOW',
    label: 'No-Show or Abandonment',
    description: 'Failing to arrive without notice or leaving mid-job.',
  ),
  unprofessionalBehavior(
    key: 'UNPROFESSIONAL_BEHAVIOR',
    label: 'Unprofessional Conduct',
    description: 'Arriving intoxicated, excessive tardiness, or rude demeanor.',
  ),
  other(
    key: 'OTHER',
    label: 'Other Issue',
    description: 'Any other safety, privacy, or policy violation.',
  );

  const ReportCategory({
    required this.key,
    required this.label,
    required this.description,
  });

  final String key;
  final String label;
  final String description;

  IconData get icon {
    switch (this) {
      case ReportCategory.harassment:
        return PhosphorIcons.chatTeardropText;
      case ReportCategory.scamFraud:
        return PhosphorIcons.warning;
      case ReportCategory.fakeIdentity:
        return PhosphorIcons.userMinus;
      case ReportCategory.paymentOutsideApp:
        return PhosphorIcons.currencyDollarSimple;
      case ReportCategory.poorWorkmanship:
        return PhosphorIcons.wrench;
      case ReportCategory.safetyConcern:
        return PhosphorIcons.shieldWarning;
      case ReportCategory.violenceThreat:
        return PhosphorIcons.warningCircle;
      case ReportCategory.propertyDamage:
        return PhosphorIcons.houseLine;
      case ReportCategory.noShow:
        return PhosphorIcons.clockAfternoon;
      case ReportCategory.unprofessionalBehavior:
        return PhosphorIcons.userFocus;
      case ReportCategory.other:
        return PhosphorIcons.dotsThreeCircle;
    }
  }

  static ReportCategory fromKey(String key) {
    return ReportCategory.values.firstWhere(
      (e) => e.key == key,
      orElse: () => ReportCategory.other,
    );
  }
}
