import 'dart:math' as math;

enum CropType {
  wheat,
  strawberry,
  corn,
  pumpkin,
  saffron,
}

class CropSpec {
  final CropType type;
  final String name;
  final String emoji;
  final int seedCost;
  final int shopPrice;
  final int quickSellPrice;
  final int growSeconds;
  final int unlockStage;
  final int colorValue;

  const CropSpec({
    required this.type,
    required this.name,
    required this.emoji,
    required this.seedCost,
    required this.shopPrice,
    required this.quickSellPrice,
    required this.growSeconds,
    required this.unlockStage,
    required this.colorValue,
  });
}

class CropCatalog {
  static const List<CropSpec> all = [
    CropSpec(
      type: CropType.wheat,
      name: 'گندم',
      emoji: '🌾',
      seedCost: 0,
      shopPrice: 16,
      quickSellPrice: 9,
      growSeconds: 3,
      unlockStage: 1,
      colorValue: 0xFFEAB308,
    ),
    CropSpec(
      type: CropType.strawberry,
      name: 'توت‌فرنگی',
      emoji: '🍓',
      seedCost: 12,
      shopPrice: 38,
      quickSellPrice: 22,
      growSeconds: 6,
      unlockStage: 2,
      colorValue: 0xFFF43F5E,
    ),
    CropSpec(
      type: CropType.corn,
      name: 'ذرت طلایی',
      emoji: '🌽',
      seedCost: 28,
      shopPrice: 82,
      quickSellPrice: 48,
      growSeconds: 10,
      unlockStage: 3,
      colorValue: 0xFFF59E0B,
    ),
    CropSpec(
      type: CropType.pumpkin,
      name: 'کدو تنبل',
      emoji: '🎃',
      seedCost: 60,
      shopPrice: 170,
      quickSellPrice: 98,
      growSeconds: 15,
      unlockStage: 5,
      colorValue: 0xFFEA580C,
    ),
    CropSpec(
      type: CropType.saffron,
      name: 'زعفران',
      emoji: '🌺',
      seedCost: 130,
      shopPrice: 360,
      quickSellPrice: 210,
      growSeconds: 22,
      unlockStage: 7,
      colorValue: 0xFFA855F7,
    ),
  ];

  static CropSpec byType(CropType type) {
    return all.firstWhere((c) => c.type == type);
  }
}

enum UpgradeType {
  irrigation,
  yieldBonus,
  shopAppeal,
  autoFarmer,
  autoCashier,
}

class UpgradeSpec {
  final UpgradeType type;
  final String title;
  final String description;
  final int baseCost;
  final double costMultiplier;
  final int maxLevel;

  const UpgradeSpec({
    required this.type,
    required this.title,
    required this.description,
    required this.baseCost,
    required this.costMultiplier,
    required this.maxLevel,
  });

  int costForLevel(int currentLevel) {
    return (baseCost * math.pow(costMultiplier, currentLevel)).round();
  }
}

class UpgradeCatalog {
  static const List<UpgradeSpec> all = [
    UpgradeSpec(
      type: UpgradeType.irrigation,
      title: 'آبیاری هوشمند',
      description: 'سرعت رشد همه محصولات ۱۴٪ بیشتر می‌شود',
      baseCost: 80,
      costMultiplier: 1.75,
      maxLevel: 6,
    ),
    UpgradeSpec(
      type: UpgradeType.yieldBonus,
      title: 'کود طلایی',
      description: '۱۸٪ شانس برداشت ۲ برابری در هر سطح',
      baseCost: 110,
      costMultiplier: 1.8,
      maxLevel: 5,
    ),
    UpgradeSpec(
      type: UpgradeType.shopAppeal,
      title: 'دکور و برند فروشگاه',
      description: 'سود سفارش‌ها ۱۵٪ و صبر مشتری‌ها بیشتر می‌شود',
      baseCost: 140,
      costMultiplier: 1.85,
      maxLevel: 6,
    ),
    UpgradeSpec(
      type: UpgradeType.autoFarmer,
      title: 'کشاورز خودکار',
      description: 'به‌صورت خودکار برداشت و دوباره کاشت می‌کند',
      baseCost: 220,
      costMultiplier: 2.0,
      maxLevel: 5,
    ),
    UpgradeSpec(
      type: UpgradeType.autoCashier,
      title: 'صندوق‌دار خودکار',
      description: 'سفارش‌های آماده مشتریان را خودکار تحویل می‌دهد',
      baseCost: 300,
      costMultiplier: 2.1,
      maxLevel: 5,
    ),
  ];

  static UpgradeSpec byType(UpgradeType type) {
    return all.firstWhere((u) => u.type == type);
  }
}

enum StageGoalType {
  harvestAny,
  harvestSpecific,
  serveOrders,
  earnCoins,
  unlockPlots,
  upgradeTotal,
}

class StageGoal {
  final StageGoalType type;
  final int target;
  final CropType? cropType;
  final String label;

  const StageGoal({
    required this.type,
    required this.target,
    this.cropType,
    required this.label,
  });
}

class StageSpec {
  final int number;
  final String title;
  final int rewardCoins;
  final String unlockHint;
  final List<StageGoal> goals;

  const StageSpec({
    required this.number,
    required this.title,
    required this.rewardCoins,
    required this.unlockHint,
    required this.goals,
  });
}

class StageCatalog {
  static const List<StageSpec> _fixed = [
    StageSpec(
      number: 1,
      title: 'روستای نوپا',
      rewardCoins: 110,
      unlockHint: 'باز شدن بذر توت‌فرنگی 🍓',
      goals: [
        StageGoal(type: StageGoalType.harvestAny, target: 4, label: 'برداشت محصول'),
        StageGoal(type: StageGoalType.serveOrders, target: 2, label: 'تحویل سفارش'),
      ],
    ),
    StageSpec(
      number: 2,
      title: 'غرفه محلی',
      rewardCoins: 180,
      unlockHint: 'باز شدن بذر ذرت طلایی 🌽',
      goals: [
        StageGoal(
          type: StageGoalType.harvestSpecific,
          target: 3,
          cropType: CropType.strawberry,
          label: 'برداشت توت‌فرنگی',
        ),
        StageGoal(type: StageGoalType.unlockPlots, target: 4, label: 'تعداد زمین باز'),
        StageGoal(type: StageGoalType.serveOrders, target: 4, label: 'تحویل سفارش'),
      ],
    ),
    StageSpec(
      number: 3,
      title: 'بازارچه پررونق',
      rewardCoins: 280,
      unlockHint: 'درآمد بیشتر سفارش‌های ترکیبی',
      goals: [
        StageGoal(
          type: StageGoalType.harvestSpecific,
          target: 4,
          cropType: CropType.corn,
          label: 'برداشت ذرت',
        ),
        StageGoal(type: StageGoalType.upgradeTotal, target: 2, label: 'سطح ارتقاها'),
        StageGoal(type: StageGoalType.earnCoins, target: 450, label: 'درآمد مرحله'),
      ],
    ),
    StageSpec(
      number: 4,
      title: 'مزرعه مکانیزه',
      rewardCoins: 420,
      unlockHint: 'باز شدن بذر کدو تنبل 🎃',
      goals: [
        StageGoal(type: StageGoalType.unlockPlots, target: 6, label: 'تعداد زمین باز'),
        StageGoal(type: StageGoalType.serveOrders, target: 7, label: 'تحویل سفارش'),
        StageGoal(type: StageGoalType.upgradeTotal, target: 4, label: 'سطح ارتقاها'),
      ],
    ),
    StageSpec(
      number: 5,
      title: 'برداشت پاییزی',
      rewardCoins: 650,
      unlockHint: 'مشتری‌های VIP با انعام بالاتر',
      goals: [
        StageGoal(
          type: StageGoalType.harvestSpecific,
          target: 4,
          cropType: CropType.pumpkin,
          label: 'برداشت کدو',
        ),
        StageGoal(type: StageGoalType.earnCoins, target: 1200, label: 'درآمد مرحله'),
        StageGoal(type: StageGoalType.serveOrders, target: 8, label: 'تحویل سفارش'),
      ],
    ),
    StageSpec(
      number: 6,
      title: 'فروشگاه مرکزی',
      rewardCoins: 950,
      unlockHint: 'باز شدن بذر زعفران سلطنتی 🌺',
      goals: [
        StageGoal(type: StageGoalType.unlockPlots, target: 7, label: 'تعداد زمین باز'),
        StageGoal(type: StageGoalType.upgradeTotal, target: 7, label: 'سطح ارتقاها'),
        StageGoal(type: StageGoalType.earnCoins, target: 2000, label: 'درآمد مرحله'),
      ],
    ),
    StageSpec(
      number: 7,
      title: 'طلای سرخ',
      rewardCoins: 1400,
      unlockHint: 'آزاد شدن ظرفیت کامل سفارش‌ها',
      goals: [
        StageGoal(
          type: StageGoalType.harvestSpecific,
          target: 4,
          cropType: CropType.saffron,
          label: 'برداشت زعفران',
        ),
        StageGoal(type: StageGoalType.serveOrders, target: 10, label: 'تحویل سفارش'),
        StageGoal(type: StageGoalType.earnCoins, target: 3500, label: 'درآمد مرحله'),
      ],
    ),
    StageSpec(
      number: 8,
      title: 'زنجیره صادرات',
      rewardCoins: 2100,
      unlockHint: 'آستانه امپراتوری کشاورزی',
      goals: [
        StageGoal(type: StageGoalType.unlockPlots, target: 9, label: 'باز کردن کل مزرعه'),
        StageGoal(type: StageGoalType.upgradeTotal, target: 11, label: 'سطح ارتقاها'),
        StageGoal(type: StageGoalType.earnCoins, target: 5500, label: 'درآمد مرحله'),
      ],
    ),
    StageSpec(
      number: 9,
      title: 'برند ملی',
      rewardCoins: 3200,
      unlockHint: 'مرحله نهایی در پیش است!',
      goals: [
        StageGoal(type: StageGoalType.harvestAny, target: 28, label: 'برداشت محصول'),
        StageGoal(type: StageGoalType.serveOrders, target: 14, label: 'تحویل سفارش'),
        StageGoal(type: StageGoalType.earnCoins, target: 8500, label: 'درآمد مرحله'),
      ],
    ),
    StageSpec(
      number: 10,
      title: 'امپراتوری R8Force',
      rewardCoins: 5000,
      unlockHint: 'ورود به مراحل نامحدود استادکار',
      goals: [
        StageGoal(type: StageGoalType.upgradeTotal, target: 16, label: 'سطح ارتقاها'),
        StageGoal(type: StageGoalType.serveOrders, target: 18, label: 'تحویل سفارش'),
        StageGoal(type: StageGoalType.earnCoins, target: 13000, label: 'درآمد مرحله'),
      ],
    ),
  ];

  static StageSpec forStage(int stageNumber) {
    if (stageNumber >= 1 && stageNumber <= _fixed.length) {
      return _fixed[stageNumber - 1];
    }
    final int extra = stageNumber - _fixed.length;
    return StageSpec(
      number: stageNumber,
      title: 'استادکار سطح $extra',
      rewardCoins: 4500 + extra * 1800,
      unlockHint: 'پاداش ویژه رکوردداران',
      goals: [
        StageGoal(
          type: StageGoalType.harvestAny,
          target: 24 + extra * 5,
          label: 'برداشت محصول',
        ),
        StageGoal(
          type: StageGoalType.serveOrders,
          target: 14 + extra * 3,
          label: 'تحویل سفارش',
        ),
        StageGoal(
          type: StageGoalType.earnCoins,
          target: 12000 + extra * 4500,
          label: 'درآمد مرحله',
        ),
      ],
    );
  }
}

class FarmPlot {
  final int index;
  bool unlocked;
  CropType? crop;
  int? plantedAtMs;
  int growDurationMs;

  FarmPlot({
    required this.index,
    required this.unlocked,
    this.crop,
    this.plantedAtMs,
    this.growDurationMs = 3000,
  });

  bool get isEmpty => unlocked && crop == null;

  double progress(int nowMs) {
    if (crop == null || plantedAtMs == null || growDurationMs <= 0) return 0.0;
    return ((nowMs - plantedAtMs!) / growDurationMs).clamp(0.0, 1.0);
  }

  bool isReady(int nowMs) {
    if (!unlocked || crop == null || plantedAtMs == null) return false;
    return (nowMs - plantedAtMs!) >= growDurationMs;
  }

  int remainingSeconds(int nowMs) {
    if (crop == null || plantedAtMs == null) return 0;
    final int leftMs = growDurationMs - (nowMs - plantedAtMs!);
    if (leftMs <= 0) return 0;
    return (leftMs / 1000).ceil();
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'unlocked': unlocked,
      'crop': crop?.name,
      'plantedAtMs': plantedAtMs,
      'growDurationMs': growDurationMs,
    };
  }

  factory FarmPlot.fromJson(Map<String, dynamic> map, int fallbackIndex) {
    final String? cropName = map['crop'] as String?;
    CropType? parsedCrop;
    if (cropName != null) {
      for (final CropType c in CropType.values) {
        if (c.name == cropName) {
          parsedCrop = c;
          break;
        }
      }
    }
    return FarmPlot(
      index: (map['index'] as int?) ?? fallbackIndex,
      unlocked: (map['unlocked'] as bool?) ?? (fallbackIndex < 3),
      crop: parsedCrop,
      plantedAtMs: map['plantedAtMs'] as int?,
      growDurationMs: (map['growDurationMs'] as int?) ?? 3000,
    );
  }
}

class CustomerOrder {
  final int id;
  final String name;
  final String avatar;
  final Map<CropType, int> items;
  final int rewardCoins;
  final double maxPatienceSec;
  double remainingSec;

  CustomerOrder({
    required this.id,
    required this.name,
    required this.avatar,
    required this.items,
    required this.rewardCoins,
    required this.maxPatienceSec,
    required this.remainingSec,
  });

  double get patienceRatio => (remainingSec / maxPatienceSec).clamp(0.0, 1.0);
}
