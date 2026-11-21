import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_models.dart';
import 'sound_engine.dart';

class FarmGameEngine extends ChangeNotifier {
  static const String _storageKey = 'r8_farm_shop_state_v1';
  static const List<int> _plotUnlockCosts = [
    0,
    0,
    0,
    110,
    240,
    460,
    820,
    1350,
    2100,
  ];

  static const List<(String, String)> _customerProfiles = [
    ('سارا', '👩🏻'),
    ('رضا', '👨🏻'),
    ('نیما', '🧑🏽'),
    ('مریم', '👩🏽'),
    ('کاوه', '🧔🏻'),
    ('الناز', '👩🏼'),
    ('امیر', '👨🏽'),
    ('نگار', '👧🏻'),
  ];

  final FarmSoundEngine sound = FarmSoundEngine();
  final math.Random _rng = math.Random();
  Timer? _ticker;

  int _coins = 45;
  int _currentStage = 1;
  int _combo = 0;
  int _nextCustomerId = 1;
  CropType _selectedCrop = CropType.wheat;

  late List<FarmPlot> _plots;
  final Map<CropType, int> _inventory = {
    for (final CropType c in CropType.values) c: 0,
  };
  final Map<UpgradeType, int> _upgrades = {
    for (final UpgradeType u in UpgradeType.values) u: 0,
  };
  final List<CustomerOrder> _customers = [];

  // آمار مأموریت‌های مرحله فعلی
  int _stageHarvests = 0;
  int _stageOrders = 0;
  int _stageCoinsEarned = 0;
  final Map<CropType, int> _stageCropHarvests = {
    for (final CropType c in CropType.values) c: 0,
  };

  double _spawnAccumulator = 0.0;
  double _autoFarmerAcc = 0.0;
  double _autoCashierAcc = 0.0;

  String? _statusBanner;
  int _bannerId = 0;
  bool _loaded = false;

  FarmGameEngine() {
    _plots = List.generate(
      9,
      (int idx) => FarmPlot(index: idx, unlocked: idx < 3),
    );
  }

  int get coins => _coins;
  int get currentStage => _currentStage;
  int get combo => _combo;
  CropType get selectedCrop => _selectedCrop;
  List<FarmPlot> get plots => List.unmodifiable(_plots);
  List<CustomerOrder> get customers => List.unmodifiable(_customers);
  String? get statusBanner => _statusBanner;
  int get bannerId => _bannerId;
  bool get isLoaded => _loaded;

  StageSpec get stageSpec => StageCatalog.forStage(_currentStage);

  int stockOf(CropType type) => _inventory[type] ?? 0;
  int upgradeLevel(UpgradeType type) => _upgrades[type] ?? 0;

  int get unlockedPlotsCount => _plots.where((p) => p.unlocked).length;

  int get totalUpgradeLevels {
    int sum = 0;
    for (final int lvl in _upgrades.values) {
      sum += lvl;
    }
    return sum;
  }

  int unlockCostForPlot(int index) {
    if (index < 0 || index >= _plotUnlockCosts.length) return 9999;
    return _plotUnlockCosts[index];
  }

  bool isCropUnlocked(CropType type) {
    return CropCatalog.byType(type).unlockStage <= _currentStage;
  }

  bool get canAffordAnyUpgrade {
    for (final UpgradeSpec spec in UpgradeCatalog.all) {
      final int lvl = upgradeLevel(spec.type);
      if (lvl < spec.maxLevel && _coins >= spec.costForLevel(lvl)) {
        return true;
      }
    }
    return false;
  }

  int goalProgress(StageGoal goal) {
    switch (goal.type) {
      case StageGoalType.harvestAny:
        return _stageHarvests;
      case StageGoalType.harvestSpecific:
        return _stageCropHarvests[goal.cropType ?? CropType.wheat] ?? 0;
      case StageGoalType.serveOrders:
        return _stageOrders;
      case StageGoalType.earnCoins:
        return _stageCoinsEarned;
      case StageGoalType.unlockPlots:
        return unlockedPlotsCount;
      case StageGoalType.upgradeTotal:
        return totalUpgradeLevels;
    }
  }

  bool isGoalComplete(StageGoal goal) => goalProgress(goal) >= goal.target;

  bool get isCurrentStageComplete {
    for (final StageGoal g in stageSpec.goals) {
      if (!isGoalComplete(g)) return false;
    }
    return true;
  }

  bool canFulfillOrder(CustomerOrder order) {
    for (final MapEntry<CropType, int> entry in order.items.entries) {
      if (stockOf(entry.key) < entry.value) return false;
    }
    return true;
  }

  Future<void> init() async {
    await sound.init();
    await _loadState();
    _loaded = true;
    if (_customers.isEmpty) {
      _spawnCustomer();
      _spawnCustomer();
    }
    _ticker?.cancel();
    _ticker = Timer.periodic(
      const Duration(milliseconds: 200),
      (_) => _onTick(0.2),
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    sound.dispose();
    super.dispose();
  }

  void _onTick(double dtSec) {
    bool changed = false;

    // به‌روزرسانی صبر مشتری‌ها
    for (int i = _customers.length - 1; i >= 0; i--) {
      final CustomerOrder order = _customers[i];
      order.remainingSec -= dtSec;
      changed = true;
      if (order.remainingSec <= 0) {
        _customers.removeAt(i);
        _combo = 0;
        sound.playFail();
        _showBanner('${order.name} منتظر ماند و رفت!');
      }
    }

    // ورود مشتری جدید
    if (_customers.length < 3) {
      _spawnAccumulator += dtSec;
      final double spawnInterval =
          math.max(1.8, 3.4 - (_currentStage * 0.14));
      if (_spawnAccumulator >= spawnInterval) {
        _spawnAccumulator = 0.0;
        _spawnCustomer();
        changed = true;
      }
    }

    // بررسی رشد محصولات روی زمین برای به‌روزرسانی نوار پیشرفت
    for (final FarmPlot plot in _plots) {
      if (plot.crop != null) {
        changed = true;
        break;
      }
    }

    // کشاورز خودکار
    final int farmerLvl = upgradeLevel(UpgradeType.autoFarmer);
    if (farmerLvl > 0) {
      _autoFarmerAcc += dtSec;
      final double interval = (4.0 - farmerLvl * 0.55).clamp(1.0, 4.0);
      if (_autoFarmerAcc >= interval) {
        _autoFarmerAcc = 0.0;
        if (_runAutoFarmerStep()) {
          changed = true;
        }
      }
    }

    // صندوق‌دار خودکار
    final int cashierLvl = upgradeLevel(UpgradeType.autoCashier);
    if (cashierLvl > 0) {
      _autoCashierAcc += dtSec;
      final double interval = (4.2 - cashierLvl * 0.6).clamp(1.1, 4.2);
      if (_autoCashierAcc >= interval) {
        _autoCashierAcc = 0.0;
        if (_runAutoCashierStep()) {
          changed = true;
        }
      }
    }

    if (changed) {
      notifyListeners();
    }
  }

  bool _runAutoFarmerStep() {
    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    for (final FarmPlot plot in _plots) {
      if (plot.isReady(nowMs)) {
        _harvestPlot(plot, fromAuto: true);
        return true;
      }
    }
    for (final FarmPlot plot in _plots) {
      if (plot.isEmpty) {
        final CropSpec spec = CropCatalog.byType(_selectedCrop);
        final CropType toPlant =
            _coins >= spec.seedCost ? _selectedCrop : CropType.wheat;
        _plantPlot(plot, toPlant, fromAuto: true);
        return true;
      }
    }
    return false;
  }

  bool _runAutoCashierStep() {
    for (final CustomerOrder order in List<CustomerOrder>.from(_customers)) {
      if (canFulfillOrder(order)) {
        serveCustomer(order.id, fromAuto: true);
        return true;
      }
    }
    return false;
  }

  void selectCrop(CropType type) {
    if (!isCropUnlocked(type)) {
      final int stageNeeded = CropCatalog.byType(type).unlockStage;
      sound.playFail();
      _showBanner('در مرحله $stageNeeded باز می‌شود');
      notifyListeners();
      return;
    }
    if (_selectedCrop == type) return;
    _selectedCrop = type;
    sound.playClick();
    _saveState();
    notifyListeners();
  }

  void tapPlot(int index) {
    if (index < 0 || index >= _plots.length) return;
    final FarmPlot plot = _plots[index];
    final int nowMs = DateTime.now().millisecondsSinceEpoch;

    if (!plot.unlocked) {
      final int cost = unlockCostForPlot(index);
      if (_coins < cost) {
        sound.playFail();
        _showBanner('برای باز کردن زمین به $cost سکه نیاز است');
        notifyListeners();
        return;
      }
      _coins -= cost;
      plot.unlocked = true;
      sound.playUpgrade();
      _showBanner('زمین شماره ${index + 1} به مزرعه اضافه شد!');
      _saveState();
      notifyListeners();
      return;
    }

    if (plot.isReady(nowMs)) {
      _harvestPlot(plot);
      notifyListeners();
      return;
    }

    if (plot.isEmpty) {
      _plantPlot(plot, _selectedCrop);
      notifyListeners();
      return;
    }
  }

  void _plantPlot(FarmPlot plot, CropType cropType, {bool fromAuto = false}) {
    final CropSpec spec = CropCatalog.byType(cropType);
    if (_coins < spec.seedCost) {
      if (!fromAuto) {
        sound.playFail();
        _showBanner('سکه کافی نیست! می‌توانید گندم رایگان بکارید');
      }
      return;
    }

    _coins -= spec.seedCost;
    final int irrLvl = upgradeLevel(UpgradeType.irrigation);
    final double speedFactor = math.pow(0.86, irrLvl).toDouble();
    final int durationMs =
        math.max(900, (spec.growSeconds * 1000 * speedFactor).round());

    plot.crop = cropType;
    plot.plantedAtMs = DateTime.now().millisecondsSinceEpoch;
    plot.growDurationMs = durationMs;

    if (!fromAuto) {
      sound.playPlant();
    }
    _saveState();
  }

  void _harvestPlot(FarmPlot plot, {bool fromAuto = false}) {
    final CropType? crop = plot.crop;
    if (crop == null) return;

    final int yieldLvl = upgradeLevel(UpgradeType.yieldBonus);
    final bool bonusDouble =
        yieldLvl > 0 && _rng.nextDouble() < (yieldLvl * 0.18);
    final int amount = bonusDouble ? 2 : 1;

    _inventory[crop] = stockOf(crop) + amount;
    _stageHarvests += amount;
    _stageCropHarvests[crop] = (_stageCropHarvests[crop] ?? 0) + amount;

    plot.crop = null;
    plot.plantedAtMs = null;

    if (!fromAuto) {
      sound.playHarvest();
      if (bonusDouble) {
        final CropSpec spec = CropCatalog.byType(crop);
        _showBanner('برداشت طلایی ۲× ${spec.name}!');
      }
    }
    _saveState();
  }

  void serveCustomer(int customerId, {bool fromAuto = false}) {
    final int idx = _customers.indexWhere((c) => c.id == customerId);
    if (idx == -1) return;
    final CustomerOrder order = _customers[idx];

    if (!canFulfillOrder(order)) {
      if (!fromAuto) {
        sound.playFail();
        _showBanner('محصول کافی در انبار برای این سفارش ندارید');
        notifyListeners();
      }
      return;
    }

    for (final MapEntry<CropType, int> entry in order.items.entries) {
      _inventory[entry.key] = stockOf(entry.key) - entry.value;
    }

    _combo++;
    final bool fastServe = order.patienceRatio >= 0.55;
    final int speedBonus = fastServe ? (order.rewardCoins * 0.25).round() : 0;
    final int comboBonus = math.min(_combo, 8) * 5;
    final int totalEarned = order.rewardCoins + speedBonus + comboBonus;

    _coins += totalEarned;
    _stageCoinsEarned += totalEarned;
    _stageOrders++;
    _customers.removeAt(idx);

    sound.playSell();
    if (!fromAuto) {
      final String bonusTag = fastServe ? ' (انعام سرعت!)' : '';
      _showBanner('+$totalEarned سکه از ${order.name}$bonusTag');
    }

    _saveState();
    notifyListeners();
  }

  void quickSellCrop(CropType type) {
    if (stockOf(type) <= 0) return;
    final CropSpec spec = CropCatalog.byType(type);
    _inventory[type] = stockOf(type) - 1;
    _coins += spec.quickSellPrice;
    _stageCoinsEarned += spec.quickSellPrice;
    sound.playSell();
    _showBanner('+${spec.quickSellPrice} سکه (فروش سریع ${spec.name})');
    _saveState();
    notifyListeners();
  }

  bool buyUpgrade(UpgradeType type) {
    final UpgradeSpec spec = UpgradeCatalog.byType(type);
    final int currentLvl = upgradeLevel(type);
    if (currentLvl >= spec.maxLevel) return false;

    final int cost = spec.costForLevel(currentLvl);
    if (_coins < cost) {
      sound.playFail();
      _showBanner('برای این ارتقا به $cost سکه نیاز است');
      notifyListeners();
      return false;
    }

    _coins -= cost;
    _upgrades[type] = currentLvl + 1;
    sound.playUpgrade();
    _showBanner('${spec.title} به سطح ${currentLvl + 1} ارتقا یافت!');
    _saveState();
    notifyListeners();
    return true;
  }

  StageSpec? claimStageReward() {
    if (!isCurrentStageComplete) return null;

    final StageSpec completed = stageSpec;
    _coins += completed.rewardCoins;
    _currentStage++;
    _stageHarvests = 0;
    _stageOrders = 0;
    _stageCoinsEarned = 0;
    for (final CropType c in CropType.values) {
      _stageCropHarvests[c] = 0;
    }

    sound.playStageClear();
    _showBanner(
      'تبریک! ورود به مرحله $_currentStage (+${completed.rewardCoins} سکه)',
    );
    _saveState();
    notifyListeners();
    return completed;
  }

  void toggleSound() {
    sound.setEnabled(!sound.enabled);
    if (sound.enabled) sound.playClick();
    _saveState();
    notifyListeners();
  }

  Future<void> resetAllProgress() async {
    _coins = 45;
    _currentStage = 1;
    _combo = 0;
    _selectedCrop = CropType.wheat;
    _plots = List.generate(
      9,
      (int idx) => FarmPlot(index: idx, unlocked: idx < 3),
    );
    for (final CropType c in CropType.values) {
      _inventory[c] = 0;
      _stageCropHarvests[c] = 0;
    }
    for (final UpgradeType u in UpgradeType.values) {
      _upgrades[u] = 0;
    }
    _stageHarvests = 0;
    _stageOrders = 0;
    _stageCoinsEarned = 0;
    _customers.clear();
    _spawnCustomer();
    _spawnCustomer();
    sound.playClick();
    _showBanner('بازی از مرحله ۱ شروع شد');
    await _saveState();
    notifyListeners();
  }

  void _spawnCustomer() {
    final List<CropSpec> available = CropCatalog.all
        .where((c) => c.unlockStage <= _currentStage)
        .toList();
    if (available.isEmpty) return;

    final (String name, String avatar) =
        _customerProfiles[_rng.nextInt(_customerProfiles.length)];

    final bool wantsTwoTypes =
        available.length >= 2 && _currentStage >= 2 && _rng.nextDouble() < 0.45;
    final Map<CropType, int> items = {};

    final CropSpec first = available[_rng.nextInt(available.length)];
    final int firstQty = _currentStage <= 2 ? (1 + _rng.nextInt(2)) : (1 + _rng.nextInt(3));
    items[first.type] = firstQty;

    if (wantsTwoTypes) {
      final List<CropSpec> others =
          available.where((c) => c.type != first.type).toList();
      final CropSpec second = others[_rng.nextInt(others.length)];
      items[second.type] = 1 + _rng.nextInt(2);
    }

    int baseReward = 0;
    for (final MapEntry<CropType, int> e in items.entries) {
      baseReward += CropCatalog.byType(e.key).shopPrice * e.value;
    }

    final int appealLvl = upgradeLevel(UpgradeType.shopAppeal);
    final double rewardMult = 1.0 + appealLvl * 0.15;
    final int finalReward = (baseReward * rewardMult).round();

    final double basePatience =
        (24.0 + items.length * 6.0 + appealLvl * 3.5).clamp(22.0, 52.0);

    _customers.add(
      CustomerOrder(
        id: _nextCustomerId++,
        name: name,
        avatar: avatar,
        items: items,
        rewardCoins: finalReward,
        maxPatienceSec: basePatience,
        remainingSec: basePatience,
      ),
    );
  }

  void _showBanner(String message) {
    _statusBanner = message;
    _bannerId++;
  }

  Future<void> _saveState() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> data = {
        'coins': _coins,
        'stage': _currentStage,
        'combo': _combo,
        'selectedCrop': _selectedCrop.name,
        'soundEnabled': sound.enabled,
        'stageHarvests': _stageHarvests,
        'stageOrders': _stageOrders,
        'stageCoinsEarned': _stageCoinsEarned,
        'inventory': {
          for (final MapEntry<CropType, int> e in _inventory.entries)
            e.key.name: e.value,
        },
        'stageCropHarvests': {
          for (final MapEntry<CropType, int> e in _stageCropHarvests.entries)
            e.key.name: e.value,
        },
        'upgrades': {
          for (final MapEntry<UpgradeType, int> e in _upgrades.entries)
            e.key.name: e.value,
        },
        'plots': _plots.map((p) => p.toJson()).toList(),
      };
      await prefs.setString(_storageKey, jsonEncode(data));
    } catch (_) {}
  }

  Future<void> _loadState() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) return;

      final Map<String, dynamic> data =
          jsonDecode(raw) as Map<String, dynamic>;
      _coins = (data['coins'] as int?) ?? 45;
      _currentStage = (data['stage'] as int?) ?? 1;
      _combo = (data['combo'] as int?) ?? 0;
      _stageHarvests = (data['stageHarvests'] as int?) ?? 0;
      _stageOrders = (data['stageOrders'] as int?) ?? 0;
      _stageCoinsEarned = (data['stageCoinsEarned'] as int?) ?? 0;

      final bool savedSound = (data['soundEnabled'] as bool?) ?? true;
      sound.setEnabled(savedSound);

      final String? selName = data['selectedCrop'] as String?;
      if (selName != null) {
        for (final CropType c in CropType.values) {
          if (c.name == selName && isCropUnlocked(c)) {
            _selectedCrop = c;
            break;
          }
        }
      }

      final Map<String, dynamic>? invMap =
          data['inventory'] as Map<String, dynamic>?;
      if (invMap != null) {
        for (final CropType c in CropType.values) {
          _inventory[c] = (invMap[c.name] as int?) ?? 0;
        }
      }

      final Map<String, dynamic>? stageInvMap =
          data['stageCropHarvests'] as Map<String, dynamic>?;
      if (stageInvMap != null) {
        for (final CropType c in CropType.values) {
          _stageCropHarvests[c] = (stageInvMap[c.name] as int?) ?? 0;
        }
      }

      final Map<String, dynamic>? upgMap =
          data['upgrades'] as Map<String, dynamic>?;
      if (upgMap != null) {
        for (final UpgradeType u in UpgradeType.values) {
          _upgrades[u] = (upgMap[u.name] as int?) ?? 0;
        }
      }

      final List<dynamic>? rawPlots = data['plots'] as List<dynamic>?;
      if (rawPlots != null && rawPlots.length == 9) {
        _plots = List.generate(
          9,
          (int i) => FarmPlot.fromJson(
            rawPlots[i] as Map<String, dynamic>,
            i,
          ),
        );
      }
    } catch (_) {}
  }
}
