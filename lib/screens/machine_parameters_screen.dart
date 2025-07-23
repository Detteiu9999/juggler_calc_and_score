// lib/screens/machine_parameters_screen.dart

import 'package:flutter/material.dart';
import '../services/slot_calculator.dart';

class MachineParametersScreen extends StatelessWidget {
  final SlotMachine machine;
  final Map<String, String>? currentProbabilities;

  const MachineParametersScreen({
    Key? key,
    required this.machine,
    this.currentProbabilities,
  }) : super(key: key);

  List<int> _findClosestValueIndices(String currentProb, List<double> values) {
    if (currentProb.isEmpty || currentProb == "－") return [];

    try {
      final parts = currentProb.split('/');
      if (parts.length != 2) return [];

      double targetProb = 1.0 / double.parse(parts[1]);
      double minDiff = double.infinity;
      List<int> closestIndices = [];

      // まず最小の差分を見つける
      for (int i = 0; i < values.length; i++) {
        double diff = (1.0 / values[i] - targetProb).abs();
        if (diff < minDiff) {
          minDiff = diff;
        }
      }

      // 最小の差分と同じ差分を持つインデックスを全て収集
      for (int i = 0; i < values.length; i++) {
        double diff = (1.0 / values[i] - targetProb).abs();
        if ((diff - minDiff).abs() < 1e-10) { // 浮動小数点の誤差を考慮
          closestIndices.add(i);
        }
      }

      return closestIndices;
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final params = SlotCalculator.machineParameters[machine]!;
    final machineName = _getMachineName(machine);

    final probMap = {
      'single_big': currentProbabilities?['single_big'] ?? '',
      'single_reg': currentProbabilities?['single_reg'] ?? '',
      'cherry_big': currentProbabilities?['cherry_big'] ?? '',
      'cherry_reg': currentProbabilities?['cherry_reg'] ?? '',
      'budou': currentProbabilities?['budou'] ?? '',
      'single_cherry': currentProbabilities?['single_cherry'] ?? '',
      'big_sum': currentProbabilities?['big_sum'] ?? '',
      'reg_sum': currentProbabilities?['reg_sum'] ?? '',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('$machineName パラメータ'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildParameterTable('設定別機械割', params['payout']!),
              SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildParameterTable(
                      '単独BIG確率',
                      params['single_big']!,
                      currentProb: probMap['single_big'],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildParameterTable(
                      '単独REG確率',
                      params['single_reg']!,
                      currentProb: probMap['single_reg'],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              if (machine != SlotMachine.gogoJuggler &&
                  machine != SlotMachine.jugglerGirls &&
                  machine != SlotMachine.misterJuggler) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildParameterTable(
                        '角チェリー + BIG確率',
                        params['cherry_big']!,
                        currentProb: probMap['cherry_big'],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildParameterTable(
                        '角チェリー + REG確率',
                        params['cherry_reg']!,
                        currentProb: probMap['cherry_reg'],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildParameterTable(
                      'ぶどう確率',
                      params['budou']!,
                      currentProb: probMap['budou'],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildParameterTable(
                      '単独チェリー確率',
                      params['single_cherry']!,
                      currentProb: probMap['single_cherry'],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildParameterTable(
                      'BIG合算確率',
                      params['big_sum']!,
                      currentProb: probMap['big_sum'],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildParameterTable(
                      'REG合算確率',
                      params['reg_sum']!,
                      currentProb: probMap['reg_sum'],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParameterTable(String title, List<double> values, {String? currentProb}) {
    final closestIndices = currentProb != null ? _findClosestValueIndices(currentProb, values) : <int>[];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            if (currentProb != null && currentProb != "－")
              Text(
                '現在: $currentProb',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
            SizedBox(height: 8),
            Table(
              border: TableBorder.all(),
              columnWidths: const <int, TableColumnWidth>{
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[200]),
                  children: [
                    _buildTableCell('設定', header: true),
                    _buildTableCell('値', header: true),
                  ],
                ),
                ...List.generate(6, (index) => TableRow(
                  decoration: BoxDecoration(
                    color: closestIndices.contains(index) ? Colors.yellow[100] : null,
                  ),
                  children: [
                    _buildTableCell('${index + 1}'),
                    _buildTableCell(values[index].toString()),
                  ],
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildTableCell(String text, {bool header = false}) {
    return Container(
      padding: EdgeInsets.all(1),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: header ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  String _getMachineName(SlotMachine machine) {
    switch (machine) {
      case SlotMachine.imJuggler:
        return 'アイムジャグラーEX';
      case SlotMachine.myJuggler:
        return 'マイジャグラーⅤ';
      case SlotMachine.gogoJuggler:
        return 'ゴーゴージャグラー3';
      case SlotMachine.funkyJuggler:
        return 'ファンキージャグラー2';
      case SlotMachine.happyJuggler:
        return 'ハッピージャグラーV Ⅲ';
      case SlotMachine.jugglerGirls:
        return 'ジャグラーガールズSS';
      case SlotMachine.misterJuggler:
        return 'ミスタージャグラー';
      case SlotMachine.ultramiracleJuggler:
        return 'ウルトラミラクルジャグラー';
      default:
        return machine.toString();
    }
  }
}