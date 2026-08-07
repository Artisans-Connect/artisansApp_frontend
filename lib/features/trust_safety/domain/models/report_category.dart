import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

enum ReportCategory {
  harassment(
    key: 'HARASSMENT',
    label: 'Harassment or Bullying',
    description: 'Offensive messages, threats, stalking, or inappropriate language.',
    icon: PhosphorIcons.chatTeardropWarning,
  ),
  scamFraud(
    key: 'SCAM_FRAUD',
    label: 'Scam or Fraud',
    description: 'Demanding payment before work, fake quotes, or dishonesty.',
    icon: PhosphorIcons.warning,
  ),
  fakeIdentity(
    key: 'FAKE_IDENTITY',
    label: 'Fake Identity or Impersonation',
    description: 'Artisan or client using a fake name, photo, or unverified identity.',
    icon: PhosphorIcons.userMinus,
  ),
  paymentOutsideApp(
    key: 'PAYMENT_OUTSIDE_APP',
    label: 'Payment Outside App',
    description: 'Asking to settle cash/transfer off the platform to bypass security.',
    icon: PhosphorIcons.currencyDollarSimple,
  ),
  poorWorkmanship(
    key: 'POOR_WORKMANSHIP',
    label: 'Substandard Work or Damage',
    description: 'Job left incomplete, severe property damage, or unsafe execution.',
    icon: PhosphorIcons.wrench,
  ),
  safetyConcern(
    key: 'SAFETY_CONCERN',
    label: 'Personal Safety Concern',
    description: 'Threatening behavior, reckless conduct, or unsafe home situation.',
    icon: PhosphorIcons.shieldWarning,
  ),
  violenceThreat(
    key: 'VIOLENCE_THREAT',
    label: 'Physical Violence or Threats',
    description: 'Aggressive physical confrontation or imminent bodily harm.',
    icon: PhosphorIcons.warningCircle,
  ),
  propertyDamage(
    key: 'PROPERTY_DAMAGE',
    label: 'Property Damage or Theft',
    description: 'Stolen goods, damaged appliances, or home property destruction.',
    icon: PhosphorIcons.houseLine,
  ),
  noShow(
    key: 'NO_SHOW',
    label: 'No-Show or Abandonment',
    description: 'Failing to arrive without notice or leaving mid-job.',
    icon: PhosphorIcons.clockAfternoon,
  ),
  unprofessionalBehavior(
    key: 'UNPROFESSIONAL_BEHAVIOR',
    label: 'Unprofessional Conduct',
    description: 'Arriving intoxicated, excessive tardiness, or rude demeanor.',
    icon: PhosphorIcons.userFocus,
  ),
  other(
    key: 'OTHER',
    label: 'Other Issue',
    description: 'Any other safety, privacy, or policy violation.',
    icon: PhosphorIcons.dotsThreeCircle,
  );

  const ReportCategory({
    required this.key,
    required this.label,
    required this.description,
    required this.icon,
  });

  final String key;
  final String label;
  final String description;
  final IconData icon;

  static ReportCategory fromKey(String key) {
    return ReportCategory.values.firstWhere(
      (e) => e.key == key,
      orElse: () => ReportCategory.other,
    );
  }
}
