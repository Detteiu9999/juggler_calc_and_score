import '../services/slot_calculator.dart';

class PracticeRecord {
  final DateTime date;
  final SlotMachine machine;
  final int gameCount;
  final double bigProbability;
  final double regProbability;
  final double budouProbability;
  final int budouCount;
  final int? coinDifference;  // 追加: 差枚数（nullable）

  PracticeRecord({
    required this.date,
    required this.machine,
    required this.gameCount,
    required this.bigProbability,
    required this.regProbability,
    required this.budouProbability,
    required this.budouCount,
    this.coinDifference,  // 追加
  });

  // コピーと更新のためのメソッドを追加
  PracticeRecord copyWith({
    DateTime? date,
    SlotMachine? machine,
    int? gameCount,
    double? bigProbability,
    double? regProbability,
    double? budouProbability,
    int? budouCount,
    int? coinDifference,
  }) {
    return PracticeRecord(
      date: date ?? this.date,
      machine: machine ?? this.machine,
      gameCount: gameCount ?? this.gameCount,
      bigProbability: bigProbability ?? this.bigProbability,
      regProbability: regProbability ?? this.regProbability,
      budouProbability: budouProbability ?? this.budouProbability,
      budouCount: budouCount ?? this.budouCount,
      coinDifference: coinDifference ?? this.coinDifference,
    );
  }

  // 数値またはInfinityを安全にパースするヘルパーメソッド
  static double _parseDoubleOrInfinity(dynamic value) {
    if (value == null || value == 'Infinity') {
      return double.infinity;
    }
    if (value is num) {
      return value.toDouble();
    }
    try {
      return double.parse(value.toString());
    } catch (e) {
      return double.infinity;
    }
  }

  factory PracticeRecord.fromJson(Map<String, dynamic> json) {
    return PracticeRecord(
      date: DateTime.parse(json['date']),
      machine: SlotMachine.values.firstWhere(
            (e) => e.toString() == json['machine'],
      ),
      gameCount: json['gameCount'],
      bigProbability: _parseDoubleOrInfinity(json['bigProbability']),
      regProbability: _parseDoubleOrInfinity(json['regProbability']),
      budouProbability: _parseDoubleOrInfinity(json['budouProbability'] ?? 'Infinity'),
      budouCount: json['budouCount'] ?? 0,
      coinDifference: json['coinDifference'],  // 追加
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'machine': machine.toString(),
      'gameCount': gameCount,
      'bigProbability': bigProbability.isInfinite ? 'Infinity' : bigProbability,
      'regProbability': regProbability.isInfinite ? 'Infinity' : regProbability,
      'budouProbability': budouProbability.isInfinite ? 'Infinity' : budouProbability,
      'budouCount': budouCount,
      'coinDifference': coinDifference,  // 追加
    };
  }
}