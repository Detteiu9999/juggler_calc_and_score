// lib/screens/slot_analyzer_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slot_calc/screens/records_screen.dart';
import '../../models/calculation_result.dart';
import '../../services/slot_calculator.dart';
import '../models/practice_record.dart';
import '../services/record_service.dart';
import 'machine_parameters_screen.dart';
import 'machine_images_screen.dart';

class SlotAnalyzerScreen extends StatefulWidget {
  @override
  _SlotAnalyzerScreenState createState() => _SlotAnalyzerScreenState();
}

class _SlotAnalyzerScreenState extends State<SlotAnalyzerScreen>  with WidgetsBindingObserver{
  // 機種選択の状態を保存するキー
  static const String _selectedMachineKey = 'selectedMachine';

  SlotMachine selectedMachine = SlotMachine.imJuggler;
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController(); // ScrollController追加
  bool _showHaibun = false;

  // TextEditingController群
  final total1Controller = TextEditingController();
  final countAController = TextEditingController();
  final countBController = TextEditingController();
  final countCController = TextEditingController();
  final countDController = TextEditingController();
  final countEController = TextEditingController();
  final countHController = TextEditingController();
  final total2Controller = TextEditingController();
  final countFController = TextEditingController();
  final countGController = TextEditingController();

  final List<TextEditingController> haibunControllers =
  List.generate(6, (index) => TextEditingController());

  final FocusScopeNode _focusScopeNode = FocusScopeNode();

  // 計算結果
  CalculationResult? result;

  // 分数表示用の値を保持する変数
  String _total1Fraction = '';
  String _total2Fraction = '';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSavedData();

    // デバウンス処理を入れたリスナーの設定
    void updateFractions() {
      if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
      _debounceTimer = Timer(Duration(milliseconds: 300), () {
        if (!mounted) return;
        setState(() {
          // 必要な分数のみを更新
          _updateFractions();
        });
      });
    }

    // 必要最小限のコントローラーにのみリスナーを追加
    total1Controller.addListener(updateFractions);
    countFController.addListener(updateFractions);
    countGController.addListener(updateFractions);
    total2Controller.addListener(updateFractions);
  }

  // 分数計算を効率化
  void _updateFractions() {
    final total1 = int.tryParse(total1Controller.text) ?? 0;
    final total2 = int.tryParse(total2Controller.text) ?? 0;

    if (total1 > 0) {
      _total1Fraction = (total1 - total2).toString();
    } else {
      _total1Fraction = '';
    }

    if (total2 > 0) {
      _total2Fraction = total2.toString();
    } else {
      _total2Fraction = '';
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _saveData();
    _debounceTimer?.cancel();
    _scrollController.dispose();
    _focusScopeNode.dispose();
    // コントローラーの破棄
    total1Controller.dispose();
    countAController.dispose();
    countBController.dispose();
    countCController.dispose();
    countDController.dispose();
    countEController.dispose();
    countHController.dispose();
    total2Controller.dispose();
    countFController.dispose();
    countGController.dispose();
    for (var controller in haibunControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _saveData();
    } else if (state == AppLifecycleState.resumed) {
      // アプリがレジュームされたときの処理を追加
      setState(() {
        _focusScopeNode.unfocus();
        Future.delayed(Duration(milliseconds: 100), () {
          if (mounted) {
            _focusScopeNode.requestFocus();
          }
        });
      });
    }
  }

  // データの保存
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // 機種選択の保存
    await prefs.setInt(_selectedMachineKey, selectedMachine.index);

    // データカウンター部分の保存
    await prefs.setString('total2', total2Controller.text);
    await prefs.setString('countF', countFController.text);
    await prefs.setString('countG', countGController.text);

    // ボーナス・小役確率部分の保存
    await prefs.setString('total1', total1Controller.text);
    await prefs.setString('countA', countAController.text);
    await prefs.setString('countB', countBController.text);
    await prefs.setString('countC', countCController.text);
    await prefs.setString('countD', countDController.text);
    await prefs.setString('countE', countEController.text);
    await prefs.setString('countH', countHController.text);

    // 設定配分の保存
    for (int i = 0; i < haibunControllers.length; i++) {
      await prefs.setString('haibun$i', haibunControllers[i].text);
    }

    // 表示状態の保存
    await prefs.setBool('showHaibun', _showHaibun);
  }

  // 保存したデータの読み込み
  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      // 機種選択の読み込み
      final savedMachineIndex = prefs.getInt(_selectedMachineKey);
      if (savedMachineIndex != null && savedMachineIndex < SlotMachine.values.length) {
        selectedMachine = SlotMachine.values[savedMachineIndex];
      }

      // データカウンター部分の読み込み
      total2Controller.text = prefs.getString('total2') ?? '';
      countFController.text = prefs.getString('countF') ?? '';
      countGController.text = prefs.getString('countG') ?? '';

      // ボーナス・小役確率部分の読み込み
      total1Controller.text = prefs.getString('total1') ?? '';
      countAController.text = prefs.getString('countA') ?? '';
      countBController.text = prefs.getString('countB') ?? '';
      countCController.text = prefs.getString('countC') ?? '';
      countDController.text = prefs.getString('countD') ?? '';
      countEController.text = prefs.getString('countE') ?? '';
      countHController.text = prefs.getString('countH') ?? '';

      // 設定配分の読み込み
      for (int i = 0; i < haibunControllers.length; i++) {
        haibunControllers[i].text = prefs.getString('haibun$i') ?? '';
      }

      // 表示状態の読み込み
      _showHaibun = prefs.getBool('showHaibun') ?? false;
    });

    // フラクション表示の更新
    _updateFractions();
  }

  // ボーナス・小役確率フォームのクリア
  void _clearBonusForm() {
    setState(() {
      total1Controller.clear();
      countAController.clear();
      countBController.clear();
      countCController.clear();
      countDController.clear();
      countEController.clear();
      countHController.clear();
    });
    _saveData();
  }

  // データカウンターフォームのクリア
  void _clearCounterForm() {
    setState(() {
      total2Controller.clear();
      countFController.clear();
      countGController.clear();
    });
    _saveData();
  }

  void _calculate() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        result = SlotCalculator.calculate(
          total1: total1Controller.text,
          countA: countAController.text,
          countB: countBController.text,
          countC: countCController.text,
          countD: countDController.text,
          countE: countEController.text,
          total2: total2Controller.text,
          countF: countFController.text,
          countG: countGController.text,
          countH: countHController.text,
          haibun: haibunControllers.map((c) => c.text).toList(),
          machine: selectedMachine,
        );
      });

      // 計算後、少し遅延させてスクロール
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      });
    }
  }

  // 確率文字列を計算する補助関数を追加
  String _calculateProbString(int total, int count) {
    if (total <= 0 || count <= 0) return "－";
    return "1/${(total/count).toStringAsFixed(3)}";
  }

  Widget _buildInputField(
      String label,
      TextEditingController controller,
      {String? suffix}
      ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          suffix: suffix != null ? Text(suffix) : null,
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return null;
          }
          if (int.tryParse(value) == null) {
            return '数値を入力してください';
          }
          return null;
        },
      ),
    );
  }

  // 分数を計算して文字列で返す関数
  String _calculateFraction(String count, String total) {
    if (count.isEmpty || total.isEmpty) return '';
    final countNum = int.tryParse(count);
    final totalNum = int.tryParse(total);
    if (countNum == null || totalNum == null || totalNum == 0 || countNum == 0) return '';

    return '1/${(totalNum / countNum).toStringAsFixed(2)}';
  }

  void _saveRecord() async {
    final gameCount = (int.tryParse(total1Controller.text) ?? 0) -
        (int.tryParse(total2Controller.text) ?? 0);

    if (gameCount <= 0) {
      Fluttertoast.showToast(msg: "有効なゲーム数を入力してください");
      return;
    }

    final countA = int.tryParse(countAController.text) ?? 0;
    final countB = int.tryParse(countBController.text) ?? 0;
    final countC = int.tryParse(countCController.text) ?? 0;
    final countD = int.tryParse(countDController.text) ?? 0;
    final countE = int.tryParse(countEController.text) ?? 0;  // ぶどう回数

    final totalBIG = countA + countC;
    final totalREG = countB + countD;

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('記録の保存確認'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('以下の内容で保存しますか？'),
            SizedBox(height: 8),
            Text('実践G数: ${gameCount}G'),
            Text('BIG: ${totalBIG}回'),
            Text('REG: ${totalREG}回'),
            Text('ぶどう: ${countE}回'),  // 追加
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('保存'),
          ),
        ],
      ),
    );

    if (shouldSave != true) return;

    final record = PracticeRecord(
      date: DateTime.now(),
      machine: selectedMachine,
      gameCount: gameCount,
      bigProbability: totalBIG > 0 ? gameCount / totalBIG : double.infinity,
      regProbability: totalREG > 0 ? gameCount / totalREG : double.infinity,
      budouProbability: countE > 0 ? gameCount / countE : double.infinity,  // 追加
      budouCount: countE,  // 追加
    );

    await RecordService.saveRecord(record);
    Fluttertoast.showToast(msg: "記録を保存しました");
  }


  // 入力フィールドと分数表示を含むウィジェット
  Widget _buildInputFieldWithFraction(
      String label,
      TextEditingController controller,
      {String? suffix,
        String? totalValue,
        bool showFraction = false,
        bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            labelText: label,
            suffix: suffix != null ? Text(suffix) : null,
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) return null;
            if (int.tryParse(value) == null) return '数値を入力してください';
            return null;
          },
        ),
        if (showFraction && totalValue != null && totalValue.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: Text(
              _calculateFraction(controller.text, totalValue),
              style: TextStyle(fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildCounterField(
      String label,
      TextEditingController controller,
      String? totalValue,
      ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // 上端で揃える
        children: [
          Expanded(
            flex: 4,
            child: _buildInputFieldWithFraction(
              label,
              controller,
              suffix: '回',
              totalValue: totalValue,
              showFraction: true,
            ),
          ),
          SizedBox(width: 8),
          Container(
            width: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: 48, // TextFormFieldの標準的な高さに合わせる
                  child: IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline,
                      size: 32,
                      color: Colors.red,
                    ),
                    padding: EdgeInsets.zero, // パディングを削除して位置を調整
                    constraints: BoxConstraints(), // デフォルトの制約を解除
                    onPressed: () {
                      int currentValue = int.tryParse(controller.text) ?? 0;
                      if (currentValue > 0) {
                        setState(() {
                          controller.text = (currentValue - 1).toString();
                        });
                        _saveData();
                      }
                    },
                  ),
                ),
                SizedBox(
                  height: 48, // TextFormFieldの標準的な高さに合わせる
                  child: IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      size: 32,
                      color: Colors.blue,
                    ),
                    padding: EdgeInsets.zero, // パディングを削除して位置を調整
                    constraints: BoxConstraints(), // デフォルトの制約を解除
                    onPressed: () {
                      int currentValue = int.tryParse(controller.text) ?? 0;
                      setState(() {
                        controller.text = (currentValue + 1).toString();
                      });
                      _saveData();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      node: _focusScopeNode,
      child: Scaffold(
        body: Column(
          children: [
            // 機種選択カード - 固定表示部分
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(  // Column から Row に変更
                  children: [
                    Expanded(  // ドロップダウンを Expanded で囲む
                      child: DropdownButtonFormField<SlotMachine>(
                        isExpanded: true,
                        value: selectedMachine,
                        onChanged: (SlotMachine? newValue) {
                          setState(() {
                            selectedMachine = newValue!;
                            if (newValue == SlotMachine.gogoJuggler ||
                                newValue == SlotMachine.jugglerGirls ||
                                newValue == SlotMachine.misterJuggler ||
                                newValue == SlotMachine.ultramiracleJuggler ||
                                newValue == SlotMachine.newPulserBT
                            ) {
                              countCController.clear();
                              countDController.clear();
                            }
                            _saveData();
                          });
                        },
                        items: const [
                          DropdownMenuItem(
                            value: SlotMachine.imJuggler,
                            child: Text('アイムジャグラーEX'),
                          ),
                          DropdownMenuItem(
                            value: SlotMachine.myJuggler,
                            child: Text('マイジャグラーⅤ'),
                          ),
                          DropdownMenuItem(
                            value: SlotMachine.gogoJuggler,
                            child: Text('ゴーゴージャグラー3（実践ボーナス数は全て単独欄に入力）'),
                          ),
                          DropdownMenuItem(
                            value: SlotMachine.funkyJuggler,
                            child: Text('ファンキージャグラー2'),
                          ),
                          DropdownMenuItem(
                            value: SlotMachine.happyJuggler,
                            child: Text('ハッピージャグラーV Ⅲ'),
                          ),
                          DropdownMenuItem(
                            value: SlotMachine.jugglerGirls,
                            child: Text('ジャグラーガールズSS（実践ボーナス数は全て単独欄に入力）'),
                          ),
                          DropdownMenuItem(
                            value: SlotMachine.misterJuggler,
                            child: Text('ミスタージャグラー（実践ボーナス数は全て単独欄に入力）'),
                          ),
                          DropdownMenuItem(
                            value: SlotMachine.ultramiracleJuggler,
                            child: Text('ウルトラミラクルジャグラー（実践ボーナス数は全て単独欄に入力）'),
                          ),
                          DropdownMenuItem(
                            value: SlotMachine.newPulserBT,
                            child: Text('ニューパルサーBT（実践ボーナス数は全て単独欄に入力）'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8), // 適切な間隔を追加
                    IconButton(
                      icon: Icon(Icons.info_outline),
                      onPressed: () {
                        // 現在の確率を計算
                        Map<String, String> currentProbs = {
                          'single_big': _calculateProbString(
                              (int.tryParse(total1Controller.text) ?? 0) - (int.tryParse(total2Controller.text) ?? 0),
                              int.tryParse(countAController.text) ?? 0),
                          'single_reg': _calculateProbString(
                              (int.tryParse(total1Controller.text) ?? 0) - (int.tryParse(total2Controller.text) ?? 0),
                              int.tryParse(countBController.text) ?? 0),
                          'cherry_big': _calculateProbString(
                              (int.tryParse(total1Controller.text) ?? 0) - (int.tryParse(total2Controller.text) ?? 0),
                              int.tryParse(countCController.text) ?? 0),
                          'cherry_reg': _calculateProbString(
                              (int.tryParse(total1Controller.text) ?? 0) - (int.tryParse(total2Controller.text) ?? 0),
                              int.tryParse(countDController.text) ?? 0),
                          'budou': _calculateProbString(
                              (int.tryParse(total1Controller.text) ?? 0) - (int.tryParse(total2Controller.text) ?? 0),
                              int.tryParse(countEController.text) ?? 0),
                          'single_cherry': _calculateProbString(
                              (int.tryParse(total1Controller.text) ?? 0) - (int.tryParse(total2Controller.text) ?? 0),
                              int.tryParse(countHController.text) ?? 0),
                          'big_sum': _calculateProbString(
                              int.tryParse(total1Controller.text) ?? 0,
                              (int.tryParse(countFController.text) ?? 0) + (int.tryParse(countAController.text) ?? 0) + (int.tryParse(countCController.text) ?? 0)),
                          'reg_sum': _calculateProbString(
                              int.tryParse(total1Controller.text) ?? 0,
                              (int.tryParse(countGController.text) ?? 0) + (int.tryParse(countBController.text) ?? 0) + (int.tryParse(countDController.text) ?? 0)),
                        };

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MachineParametersScreen(
                              machine: selectedMachine,
                              currentProbabilities: currentProbs,  // 現在の確率を渡す
                            ),
                          ),
                        );
                      },
                      tooltip: 'パラメータ表示',
                    ),
                    IconButton(
                      icon: Icon(Icons.image),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MachineImagesScreen(),
                          ),
                        );
                      },
                      tooltip: '機種画像一覧',
                    ),
                  ],
                ),
              ),
            ),
            // スクロール可能な残りのコンテンツ
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('着席時データカウンター',
                                      style: Theme.of(context).textTheme.titleLarge),
                                  TextButton(
                                    onPressed: _clearCounterForm,
                                    child: Text('クリア'),
                                  ),
                                ],
                              ),
                              _buildInputField('ゲーム数', total2Controller, suffix: 'G中'),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInputFieldWithFraction(
                                      'BIG',
                                      countFController,
                                      suffix: '回',
                                      totalValue: total2Controller.text,
                                      showFraction: true,
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildInputFieldWithFraction(
                                      'REG',
                                      countGController,
                                      suffix: '回',
                                      totalValue: total2Controller.text,
                                      showFraction: true,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('ボーナス・小役確率',
                                      style: Theme.of(context).textTheme.titleLarge),
                                  TextButton(
                                    onPressed: _clearBonusForm,
                                    child: Text('クリア'),
                                  ),
                                ],
                              ),
                              _buildInputField('現在の総ゲーム数', total1Controller, suffix: 'G中'),
                              SizedBox(height: 8),
                              // 4つのボーナスカウンターを縦に配置
                              _buildCounterField(
                                '単独BIG',
                                countAController,
                                ((int.tryParse(total1Controller.text) ?? 0) - (int.tryParse(total2Controller.text) ?? 0)).toString(),
                              ),
                              _buildCounterField(
                                '角チェリー+BIG',
                                countCController,
                                ((int.tryParse(total1Controller.text) ?? 0) - (int.tryParse(total2Controller.text) ?? 0)).toString(),
                              ),
                              _buildCounterField(
                                '単独REG',
                                countBController,
                                ((int.tryParse(total1Controller.text) ?? 0) - (int.tryParse(total2Controller.text) ?? 0)).toString(),
                              ),
                              _buildCounterField(
                                '角チェリー+REG',
                                countDController,
                                ((int.tryParse(total1Controller.text) ?? 0) - (int.tryParse(total2Controller.text) ?? 0)).toString(),
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInputFieldWithFraction(
                                      '単独チェリー',
                                      countHController,
                                      suffix: '回',
                                      totalValue: ((int.tryParse(total1Controller.text) ?? 0) - (int.tryParse(total2Controller.text) ?? 0)).toString(),
                                      showFraction: true,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: _buildInputFieldWithFraction(
                                      'ぶどう',
                                      countEController,
                                      suffix: '回',
                                      totalValue: ((int.tryParse(total1Controller.text) ?? 0) - (int.tryParse(total2Controller.text) ?? 0)).toString(),
                                      showFraction: true,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveRecord,
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('記録を保存'),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => RecordsScreen()),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('記録を表示'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      ExpansionPanelList(
                        elevation: 1,
                        expandedHeaderPadding: EdgeInsets.all(0),
                        children: [
                          ExpansionPanel(
                            headerBuilder: (context, isExpanded) {
                              return ListTile(
                                title: Text('設定配分を入力'),
                                onTap: () {
                                  setState(() {
                                    _showHaibun = !_showHaibun;
                                  });
                                },
                              );
                            },
                            body: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  for (int i = 0; i < 6; i += 2)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildInputField(
                                              '設定${i + 1}',
                                              haibunControllers[i],
                                              suffix: '台'
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: _buildInputField(
                                              '設定${i + 2}',
                                              haibunControllers[i + 1],
                                              suffix: '台'
                                          ),
                                        ),
                                      ],
                                    ),
                                  SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            for (var controller in haibunControllers) {
                                              controller.text = '1';
                                            }
                                          });
                                          _saveData();
                                        },
                                        child: Text('均等'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            final values = [15, 50, 20, 13, 2, 1];
                                            for (int i = 0; i < haibunControllers.length; i++) {
                                              haibunControllers[i].text = values[i].toString();
                                            }
                                          });
                                          _saveData();
                                        },
                                        child: Text('通常'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            final values = [15, 45, 25, 15, 9, 2];
                                            for (int i = 0; i < haibunControllers.length; i++) {
                                              haibunControllers[i].text = values[i].toString();
                                            }
                                          });
                                          _saveData();
                                        },
                                        child: Text('特日'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            isExpanded: _showHaibun,
                          ),
                        ],
                        expansionCallback: (panelIndex, isExpanded) {
                          setState(() {
                            _showHaibun = !_showHaibun;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _calculate,
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('設定判別する'),
                        ),
                      ),
                      if (result != null) ...[
                        SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('設定期待度',
                                    style: Theme.of(context).textTheme.titleLarge),
                                ...List.generate(6, (index) {
                                  return Column(
                                    children: [
                                      SizedBox(height: 8),
                                      Text('設定${index + 1}: ${result!.probabilities[index]}%'),
                                      LinearProgressIndicator(
                                        value: (result!.probabilities[index] / 100).isNaN ?
                                        0.0 :
                                        (result!.probabilities[index] / 100).clamp(0.0, 1.0),
                                      ),
                                    ],
                                  );
                                }),
                                SizedBox(height: 16),
                                Text('各平均期待値',
                                    style: Theme.of(context).textTheme.titleMedium),
                                ListTile(
                                  title: Text('平均設定'),
                                  trailing: Text('${result!.averageSettings}'),
                                ),
                                ListTile(
                                  title: Text('平均PAYOUT'),
                                  trailing: Text('${result!.averagePayout}%'),
                                ),
                                ListTile(
                                  title: Text('平均時給(800G/時)'),
                                  trailing: Text('${result!.averageWage}円(${result!.averageWage/20}枚)'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}