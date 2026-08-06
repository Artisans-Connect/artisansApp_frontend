enum NegotiationType { quote, extraCharge, completionAdjustment }

enum NegotiationStatus { open, accepted, rejected, expired, paid }

class NegotiationRound {
  const NegotiationRound({
    required this.id,
    required this.negotiationId,
    required this.roundNumber,
    required this.proposedBy,
    required this.proposedAmount,
    this.note,
    required this.createdAt,
  });

  final String id;
  final String negotiationId;
  final int roundNumber;
  final String proposedBy;
  final double proposedAmount;
  final String? note;
  final DateTime createdAt;

  factory NegotiationRound.fromJson(Map<String, dynamic> json) {
    return NegotiationRound(
      id: json['id'] as String? ?? '',
      negotiationId: json['negotiation_id'] as String? ?? '',
      roundNumber: (json['round_number'] as num?)?.toInt() ?? 0,
      proposedBy: json['proposed_by'] as String? ?? '',
      proposedAmount: (json['proposed_amount'] as num?)?.toDouble() ?? 0.0,
      note: json['note'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
    );
  }
}

class Negotiation {
  const Negotiation({
    required this.id,
    required this.jobId,
    this.applicationId,
    required this.type,
    required this.status,
    required this.initialAmount,
    this.agreedAmount,
    required this.initiatedBy,
    this.acceptedBy,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.rounds = const <NegotiationRound>[],
  });

  final String id;
  final String jobId;
  final String? applicationId;
  final NegotiationType type;
  final NegotiationStatus status;
  final double initialAmount;
  final double? agreedAmount;
  final String initiatedBy;
  final String? acceptedBy;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<NegotiationRound> rounds;

  factory Negotiation.fromJson(Map<String, dynamic> json) {
    final String typeStr = json['type'] as String? ?? 'quote';
    final NegotiationType type = typeStr == 'extra_charge'
        ? NegotiationType.extraCharge
        : typeStr == 'completion_adjustment'
            ? NegotiationType.completionAdjustment
            : NegotiationType.quote;

    final String statusStr = json['status'] as String? ?? 'open';
    final NegotiationStatus status = statusStr == 'accepted'
        ? NegotiationStatus.accepted
        : statusStr == 'rejected'
            ? NegotiationStatus.rejected
            : statusStr == 'expired'
                ? NegotiationStatus.expired
                : statusStr == 'paid'
                    ? NegotiationStatus.paid
                    : NegotiationStatus.open;

    final List<dynamic> roundsRaw = (json['rounds'] as List<dynamic>?) ?? <dynamic>[];
    final List<NegotiationRound> rounds = roundsRaw
        .map((dynamic r) => NegotiationRound.fromJson(r as Map<String, dynamic>))
        .toList()
      ..sort((NegotiationRound a, NegotiationRound b) => a.roundNumber.compareTo(b.roundNumber));

    return Negotiation(
      id: json['id'] as String? ?? '',
      jobId: json['job_id'] as String? ?? '',
      applicationId: json['application_id'] as String?,
      type: type,
      status: status,
      initialAmount: (json['initial_amount'] as num?)?.toDouble() ?? 0.0,
      agreedAmount: (json['agreed_amount'] as num?)?.toDouble(),
      initiatedBy: json['initiated_by'] as String? ?? '',
      acceptedBy: json['accepted_by'] as String?,
      description: json['description'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : DateTime.now(),
      rounds: rounds,
    );
  }
}
