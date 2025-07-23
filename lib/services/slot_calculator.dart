// lib/services/slot_calculator.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/calculation_result.dart';

enum SlotMachine {
  imJuggler,
  myJuggler,
  gogoJuggler,
  funkyJuggler,
  happyJuggler,
  jugglerGirls,
  misterJuggler,
  ultramiracleJuggler
}

class SlotCalculator {
  static const Map<SlotMachine, Map<String, List<double>>> machineParameters = {
    SlotMachine.imJuggler: {
      'payout': [98.4, 99.4, 101.1, 102.9, 105.3, 107.5],
      'single_big': [387.8, 381.0, 381.0, 370.26, 370.26, 362.08],
      'single_reg': [636.27, 569.89, 471.48, 445.8, 362.08, 362.08],
      'cherry_big': [923.04, 923.04, 923.04, 862.3, 862.3, 862.3],
      'cherry_reg': [1424.7, 1337.47, 1110.78, 1074.36, 862.3, 862.3],
      'budou': [6.02, 6.02, 6.02, 6.02, 6.02, 5.848],
      'single_cherry': [35.62, 35.62, 35.62, 35.62, 35.62, 35.62],
      'big_sum': [273.1, 269.7, 269.7, 259.0, 259.0, 255.0],
      'reg_sum': [439.8, 399.6, 331.0, 315.1, 255.0, 255.0],
    },
    SlotMachine.myJuggler: {
      'payout': [98.3, 99.4, 101.6, 104.7, 107.5, 112.0],
      'single_big': [420.1, 414.8, 404.5, 376.6, 348.6, 341.3],
      'single_reg': [655.36, 595.8, 496.5, 404.5, 390.1, 327.7],
      'cherry_big': [1365.3, 1365.3, 1365.3, 1365.3, 1337.5, 1129.9],
      'cherry_reg': [1092.267, 1092.267, 1040.25, 1024.0, 862.3, 762.047],
      'budou': [5.98, 5.88, 5.84, 5.81, 5.76, 5.65],
      'single_cherry': [35.85, 35.85, 35.85, 34.66, 33.35, 33.03],
      'big_sum': [273.1, 270.8, 266.4, 254.0, 240.1, 229.1],
      'reg_sum': [409.6, 385.5, 336.1, 290.0, 268.6, 229.1],
    },
    SlotMachine.gogoJuggler: {
      'payout': [98.7, 99.75, 101.09, 103.2, 105.6, 108.40],
      'single_big': [259.0, 258.0, 257.0, 254.0, 247.3, 234.9],
      'single_reg': [354.2, 332.7, 306.2, 268.6, 247.3, 234.9],
      'cherry_big': [999,999,999,999,999,999],
      'cherry_reg': [999,999,999,999,999,999],
      'budou': [6.25, 6.2, 6.15, 6.07, 6.00, 5.92],
      'single_cherry': [33.4, 33.3, 33.2, 33.1, 32.9, 32.8],
      'big_sum': [259.0, 258.0, 257.0, 254.0, 247.3, 234.9],
      'reg_sum': [354.2, 332.7, 306.2, 268.6, 247.3, 234.9],
    },
    SlotMachine.funkyJuggler: {
      'payout': [98.2, 99.7, 101.35, 103.7, 106.4, 111.75],
      'single_big': [358.12, 352.344, 344.926, 330.99, 327.68, 295.207],
      'single_reg': [648.871, 569.878, 500.275, 445.823, 409.6, 344.926],
      'cherry_big': [1040.254, 1024.0, 992.97, 978.149, 923.042, 910.222],
      'cherry_reg': [1489.455, 1394.383, 1285.02, 1236.528, 1213.63, 1057.032],
      'budou': [5.94, 5.9298, 5.8798, 5.8301, 5.80, 5.77],
      'single_cherry': [35.62, 35.62, 35.62, 35.62, 35.62, 35.62],
      'big_sum': [266.4, 259.0, 256.0, 249.2, 240.1, 219.9],
      'reg_sum': [439.8, 407.1, 366.1, 322.8, 299.3, 262.1],
    },
    SlotMachine.happyJuggler: {
      'payout': [98.48, 99.63, 101.45, 105.6, 108.0, 110.85],
      'single_big': [358.12, 354.249, 348.596, 341.333, 322.837, 296.543],
      'single_reg': [682.667, 612.486, 574.877, 496.485, 455.111, 439.839],
      'cherry_big': [1149.754, 1149.754, 1149.754, 936.229, 923.042, 949.797],
      'cherry_reg': [936.229, 885.622, 789.59, 762.047, 682.667, 612.486],
      'budou': [6.04, 6.01, 5.98, 5.86, 5.84, 5.82],
      'single_cherry': [56.55, 56.55, 56.55, 56.55, 56.55, 56.55],
      'big_sum': [273.1, 270.8, 263.2, 254.0, 239.2, 226.0],
      'reg_sum': [397.2, 362.1, 332.7, 300.6, 273.1, 256.0],
    },
    SlotMachine.jugglerGirls: {
      'payout': [98.45, 99.41, 101.5, 103.85, 105.72, 109.23],
      'single_big': [273.1, 270.8, 260.06, 250.14, 243.63, 225.99],
      'single_reg': [381.02, 350.46, 316.6, 281.27, 270.81, 252.06],
      'cherry_big': [999,999,999,999,999,999],
      'cherry_reg': [999,999,999,999,999,999],
      'budou': [6.01, 6.01, 6.01, 6.01, 5.92, 5.89],
      'single_cherry': [33.61, 33.51, 33.3, 33.2, 33.1, 32.9],
      'big_sum': [273.1, 270.8, 260.06, 250.14, 243.63, 225.99],
      'reg_sum': [381.02, 350.46, 316.6, 281.27, 270.81, 252.06],
    },
    SlotMachine.misterJuggler: {
      'payout': [99.3, 100.32, 102.17, 105.04, 107.89, 109.69],
      'single_big': [268.59, 267.49, 260.06, 249.19, 240.94, 237.45],
      'single_reg': [374.49, 354.25, 330.99, 291.27, 257.00, 237.45],
      'cherry_big': [999,999,999,999,999,999],
      'cherry_reg': [999,999,999,999,999,999],
      'budou': [6.207, 6.154, 6.111, 6.076, 6.043, 6.005],
      'single_cherry': [33.61, 33.51, 33.3, 33.2, 33.1, 32.9],
      'big_sum': [268.59, 267.49, 260.06, 249.19, 240.94, 237.45],
      'reg_sum': [374.49, 354.25, 330.99, 291.27, 257.00, 237.45],
    },
    SlotMachine.ultramiracleJuggler: {
      'payout': [98.15, 99.4, 101.3, 103.75, 106.0, 109.6],
      'single_big': [267.5, 261.1, 256.0, 242.7, 233.2, 216.3],
      'single_reg': [425.6, 402.1, 350.5, 322.8, 297.9, 277.7],
      'cherry_big': [999,999,999,999,999,999],
      'cherry_reg': [999,999,999,999,999,999],
      'budou': [5.940, 5.938, 5.936, 5.934, 5.933, 5.929],
      'single_cherry': [35.54, 35.54, 34.86, 34.79, 34.13, 33.44],
      'big_sum': [267.5, 261.1, 260.06, 242.7, 233.2, 216.3],
      'reg_sum': [425.6, 402.1, 350.5, 322.8, 297.9, 277.7],
    },
  };

  static CalculationResult calculate({
    required String total1,
    required String countA,
    required String countB,
    required String countC,
    required String countD,
    required String countE,
    required String total2,
    required String countF,
    required String countG,
    required String countH,
    required List<String> haibun,
    required SlotMachine machine,
  }) {
    // 入力値の変換とバリデーション
    int countAValue = int.tryParse(countA) ?? 0;
    int countBValue = int.tryParse(countB) ?? 0;
    int countCValue = int.tryParse(countC) ?? 0;
    int countDValue = int.tryParse(countD) ?? 0;
    int countEValue = int.tryParse(countE) ?? 0;
    int total2Value = int.tryParse(total2) ?? 0;
    int countFValue = int.tryParse(countF) ?? 0;
    int countGValue = int.tryParse(countG) ?? 0;
    int countHValue = int.tryParse(countH) ?? 0;

    int total1Value = (int.tryParse(total1) ?? 0) - total2Value;

    // 入力値の検証
    bool hasValidData = false;
    if (total1Value > 0) {
      if (countAValue > 0 || countBValue > 0 || countCValue > 0 ||
          countDValue > 0 || countEValue > 0 || countHValue > 0) {
        hasValidData = true;
      }
    }
    if (total2Value > 0) {
      if (countFValue > 0 || countGValue > 0) {
        hasValidData = true;
      }
    }

    if (!hasValidData) {
      // デフォルト値を返す
      return CalculationResult(
        probabilities: List.filled(6, 16.67),
        averageSettings: 3.5,
        averagePayout: machineParameters[machine]!['payout']!
            .reduce((a, b) => a + b) / 6,
        averageWage: 0,
        probStrings: List.filled(7, "－"),
      );
    }

    List<int> haibunValues = haibun
        .map((e) => int.tryParse(e) ?? 1)
        .toList();

    // 機種のパラメータを取得
    final params = machineParameters[machine]!;

    // 確率計算用の配列
    List<List<double>> probs = List.generate(8, (_) => List.filled(6, 1.0));

    // 単独BIG確率計算
    if (total1Value > 0 && countAValue >= 0) {
      _calculateProbability(
          total1Value,
          countAValue,
          params['single_big']!,
          probs[0]
      );
    }

    // 単独REG確率計算
    if (total1Value > 0 && countBValue >= 0) {
      _calculateProbability(
          total1Value - countAValue,
          countBValue,
          params['single_reg']!,
          probs[1]
      );
    }

    // 角チェリー+BIG確率計算
    if (total1Value > 0 && countCValue >= 0) {
      _calculateProbability(
          total1Value - countAValue - countBValue,
          countCValue,
          params['cherry_big']!,
          probs[2]
      );
    }

    // 角チェリー+REG確率計算
    if (total1Value > 0 && countDValue >= 0) {
      _calculateProbability(
          total1Value - countAValue - countBValue - countCValue,
          countDValue,
          params['cherry_reg']!,
          probs[3]
      );
    }

    // ぶどう確率計算
    if (total1Value > 0 && countEValue > 0) {
      _calculateProbability(
          total1Value - countAValue - countBValue - countCValue - countDValue,
          countEValue,
          params['budou']!,
          probs[4]
      );
    }

    // データカウンターBIG確率計算
    if (total2Value > 0 && countFValue > 0) {
      _calculateProbability(
          total2Value,
          countFValue,
          params['big_sum']!,
          probs[5]
      );
    }

    // データカウンターREG確率計算
    if (total2Value > 0 && countGValue > 0) {
      _calculateProbability(
          total2Value - countFValue,
          countGValue,
          params['reg_sum']!,
          probs[6]
      );
    }

    // 単独チェリー確率計算
    if (total1Value > 0 && countHValue > 0) {
      _calculateProbability(
          total1Value - countAValue - countBValue - countCValue - countDValue - countEValue,
          countHValue,
          params['single_cherry']!,
          probs[7]
      );
    }

    // 設定配分の計算
    double haibunSum = haibunValues.reduce((a, b) => a + b).toDouble();
    List<double> haibunRatios = haibunValues.map((v) => v / haibunSum).toList();

    // 総合確率の計算
    List<double> finalProbs = List.filled(6, 0.0);
    for (int i = 0; i < 6; i++) {
      double settingProb = haibunRatios[i];
      for (int j = 0; j < probs.length; j++) {
        settingProb *= probs[j][i];
      }
      finalProbs[i] = settingProb;
    }

    // 確率の正規化
    double totalProb = finalProbs.reduce((a, b) => a + b);
    List<double> probabilities = finalProbs
        .map((p) => double.parse((p / totalProb * 100).toStringAsFixed(2)))
        .toList();

    // 出現確率の文字列計算
    List<String> probStrings = [
      _calculateProbString(total1Value, countAValue),
      _calculateProbString(total1Value, countBValue),
      _calculateProbString(total1Value, countCValue),
      _calculateProbString(total1Value, countDValue),
      _calculateProbString(total1Value, countEValue),
      _calculateProbString(total2Value, countFValue),
      _calculateProbString(total2Value, countGValue),
      _calculateProbString(total1Value, countHValue),
    ];

    // 平均値の計算
    double averageSettings = _calculateAverageSettings(probabilities);
    double averagePayout = _calculateAveragePayout(probabilities, params['payout']!);
    double averageWage = _calculateAverageWage(probabilities, params['payout']!);

    return CalculationResult(
      probabilities: probabilities,
      averageSettings: averageSettings,
      averagePayout: averagePayout,
      averageWage: averageWage,
      probStrings: probStrings,
    );
  }

  static void _calculateProbability(
      int total,
      int count,
      List<double> settings,
      List<double> results
      ) {
    try {
      if (total <= 0) return;

      List<double> lcomb = List<double>.filled(total + 1, 0);
      double lsum = 0;
      for (int idx = 2; idx <= total; idx++) {
        lsum += log(idx);
        lcomb[idx] = lsum;
      }

      int remaining = total - count;
      double prob = lcomb[total] - lcomb[count] - lcomb[remaining];

      for (int i = 0; i < 6; i++) {
        double lk = log(1/settings[i]);
        double lm = log(1 - 1/settings[i]);
        if (count == 0) {
          // カウントが0の場合は、事象が発生しなかった確率を計算
          results[i] = exp(total * lm);
        } else {
          // 通常の確率計算
          results[i] = exp(prob + count * lk + remaining * lm);
        }
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "計算中にエラーが発生しました: $e",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 4,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  static String _calculateProbString(int total, int count) {
    if (total == 0 || count == 0) {
      return "－";
    }
    return "1/${(total/count).round()}";
  }

  static double _calculateAverageSettings(List<double> probabilities) {
    double sum = 0;
    for (int i = 0; i < probabilities.length; i++) {
      sum += (i + 1) * (probabilities[i] / 100);
    }
    return double.parse(sum.toStringAsFixed(2));
  }

  static double _calculateAveragePayout(List<double> probabilities, List<double> payouts) {
    double sum = 0;
    for (int i = 0; i < probabilities.length; i++) {
      sum += payouts[i] * (probabilities[i] / 100);
    }
    return double.parse(sum.toStringAsFixed(2));
  }

  static double _calculateAverageWage(List<double> probabilities, List<double> payouts) {
    double sum = 0;
    for (int i = 0; i < probabilities.length; i++) {
      sum += 2400 * (payouts[i] - 100) / 100 * 20 * (probabilities[i] / 100);
    }
    return double.parse(sum.toStringAsFixed(0));
  }
}