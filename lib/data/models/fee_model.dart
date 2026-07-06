import 'package:cloud_firestore/cloud_firestore.dart';

enum FeePaymentStatus {
  paid,
  pending,
  overdue,
  partial;

  static FeePaymentStatus fromString(String value) {
    return FeePaymentStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => FeePaymentStatus.pending,
    );
  }
}

enum FeeType {
  tuition,
  exam,
  lab,
  other;

  static FeeType fromString(String value) {
    return FeeType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => FeeType.tuition,
    );
  }
}

class FeePayment {
  final double amount;
  final DateTime date;
  final String? method;
  final String? receiptUrl;
  final String? transactionId;

  const FeePayment({
    required this.amount,
    required this.date,
    this.method,
    this.receiptUrl,
    this.transactionId,
  });

  factory FeePayment.fromJson(Map<String, dynamic> json) {
    return FeePayment(
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: _parseDateTime(json['date']),
      method: json['method'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
      transactionId: json['transactionId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'method': method,
      'receiptUrl': receiptUrl,
      'transactionId': transactionId,
    };
  }

  FeePayment copyWith({
    double? amount,
    DateTime? date,
    String? method,
    String? receiptUrl,
    String? transactionId,
  }) {
    return FeePayment(
      amount: amount ?? this.amount,
      date: date ?? this.date,
      method: method ?? this.method,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      transactionId: transactionId ?? this.transactionId,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }
}

class FeeModel {
  final String id;
  final String studentId;
  final String? batchId;
  final double amount;
  final DateTime dueDate;
  final FeePaymentStatus status;
  final String? term;
  final FeeType type;
  final List<FeePayment> payments;
  final DateTime createdAt;

  const FeeModel({
    required this.id,
    required this.studentId,
    this.batchId,
    required this.amount,
    required this.dueDate,
    this.status = FeePaymentStatus.pending,
    this.term,
    this.type = FeeType.tuition,
    this.payments = const [],
    required this.createdAt,
  });

  factory FeeModel.fromJson(Map<String, dynamic> json) {
    return FeeModel(
      id: json['id'] as String? ?? '',
      studentId: json['studentId'] as String? ?? '',
      batchId: json['batchId'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      dueDate: _parseDateTime(json['dueDate']),
      status: FeePaymentStatus.fromString(
          json['status'] as String? ?? 'pending'),
      term: json['term'] as String?,
      type: FeeType.fromString(json['type'] as String? ?? 'tuition'),
      payments: (json['payments'] as List?)
              ?.map((e) => FeePayment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'batchId': batchId,
      'amount': amount,
      'dueDate': Timestamp.fromDate(dueDate),
      'status': status.name,
      'term': term,
      'type': type.name,
      'payments': payments.map((e) => e.toJson()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  FeeModel copyWith({
    String? id,
    String? studentId,
    String? batchId,
    double? amount,
    DateTime? dueDate,
    FeePaymentStatus? status,
    String? term,
    FeeType? type,
    List<FeePayment>? payments,
    DateTime? createdAt,
  }) {
    return FeeModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      batchId: batchId ?? this.batchId,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      term: term ?? this.term,
      type: type ?? this.type,
      payments: payments ?? this.payments,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  double get totalPaid =>
      payments.fold(0.0, (s, payment) => s + payment.amount);

  double get balanceDue => amount - totalPaid;

  bool get isOverdue =>
      status != FeePaymentStatus.paid && DateTime.now().isAfter(dueDate);

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeeModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'FeeModel(id: $id, studentId: $studentId, amount: $amount, status: ${status.name})';
}
