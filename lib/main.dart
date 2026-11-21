import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game_engine.dart';
import 'game_models.dart';

const String kBrandName = 'R8Force';
const String kAuthorName = 'امین شیردلی';
const String kVersion = '1.0.0';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF071112),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const R8FarmShopApp());
}

class R8FarmShopApp extends StatelessWidget {
  const R8FarmShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'R8Force Farm & Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF071112),
      ),
      home: const FarmShopScreen(),
    );
  }
}

class FarmShopScreen extends StatefulWidget {
  const FarmShopScreen({super.key});

  @override
  State<FarmShopScreen> createState() => _FarmShopScreenState();
}

class _FarmShopScreenState extends State<FarmShopScreen> {
  final FarmGameEngine _engine = FarmGameEngine();

  @override
  void initState() {
    super.initState();
    _engine.init();
  }

  @override
  void dispose() {
    _engine.dispose();
    super.dispose();
  }

  void _onClaimStage() {
    HapticFeedback.heavyImpact();
    final StageSpec? cleared = _engine.claimStageReward();
    if (cleared == null) return;

    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: const Color(0xFF0D1D1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(color: Color(0x6610B981)),
            ),
            title: Text(
              'مرحله ${cleared.number} تکمیل شد! 🎉',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'جایزه دریافتی: +${cleared.rewardCoins} سکه 🪙',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFACC15),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  cleared.unlockHint,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xCC6EE7B7),
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'ورود به مرحله بعد',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openUpgradesSheet({int initialTab = 0}) {
    HapticFeedback.lightImpact();
    int activeTab = initialTab;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0B181A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext sCtx, StateSetter setSheetState) {
            return ListenableBuilder(
              listenable: _engine,
              builder: (BuildContext context, _) {
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.68,
                        child: Column(
                          children: [
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0x44FFFFFF),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'مدیریت مزرعه و فروشگاه',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0x28FACC15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0x66FACC15),
                                    ),
                                  ),
                                  child: Text(
                                    '🪙 ${_engine.coins}',
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFFFDE047),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0x14FFFFFF),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _SheetTab(
                                      label: 'ارتقا و کارمندان',
                                      selected: activeTab == 0,
                                      onTap: () =>
                                          setSheetState(() => activeTab = 0),
                                    ),
                                  ),
                                  Expanded(
                                    child: _SheetTab(
                                      label: 'انبار و فروش سریع',
                                      selected: activeTab == 1,
                                      onTap: () =>
                                          setSheetState(() => activeTab = 1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: activeTab == 0
                                  ? _buildUpgradeList()
                                  : _buildBarnList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildUpgradeList() {
    return ListView.separated(
      itemCount: UpgradeCatalog.all.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (BuildContext context, int index) {
        final UpgradeSpec spec = UpgradeCatalog.all[index];
        final int lvl = _engine.upgradeLevel(spec.type);
        final bool maxed = lvl >= spec.maxLevel;
        final int cost = spec.costForLevel(lvl);
        final bool affordable = !maxed && _engine.coins >= cost;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: const Color(0x14FFFFFF),
            border: Border.all(
              color: affordable
                  ? const Color(0x7710B981)
                  : const Color(0x20FFFFFF),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          spec.title,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x2610B981),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'سطح $lvl/${spec.maxLevel}',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6EE7B7),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      spec.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xBBE2E8F0),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: maxed
                    ? null
                    : () {
                        HapticFeedback.mediumImpact();
                        _engine.buyUpgrade(spec.type);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: maxed
                      ? const Color(0x22FFFFFF)
                      : (affordable
                          ? const Color(0xFF10B981)
                          : const Color(0x2294A3B8)),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  maxed ? 'تکمیل' : '🪙 $cost',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBarnList() {
    return ListView.separated(
      itemCount: CropCatalog.all.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (BuildContext context, int index) {
        final CropSpec spec = CropCatalog.all[index];
        final bool unlocked = _engine.isCropUnlocked(spec.type);
        final int stock = _engine.stockOf(spec.type);

        return Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: const Color(0x14FFFFFF),
            border: Border.all(color: const Color(0x20FFFFFF)),
          ),
          child: Row(
            children: [
              Text(spec.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      spec.name,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      unlocked
                          ? 'موجودی: $stock  •  فروش به مشتری: ~${spec.shopPrice}🪙'
                          : 'در مرحله ${spec.unlockStage} باز می‌شود',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xAAE2E8F0),
                      ),
                    ),
                  ],
                ),
              ),
              if (unlocked)
                ElevatedButton(
                  onPressed: stock > 0
                      ? () {
                          HapticFeedback.lightImpact();
                          _engine.quickSellCrop(spec.type);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0EA5E9),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'فروش +${spec.quickSellPrice}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _confirmReset() {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: const Color(0xFF0D1D1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            title: const Text('شروع دوباره از مرحله ۱؟'),
            content: const Text(
              'تمام سکه‌ها، زمین‌ها و ارتقاهای ذخیره‌شده پاک می‌شوند.',
              style: TextStyle(color: Color(0xCCE2E8F0)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('انصراف'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _engine.resetAllProgress();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                ),
                child: const Text('ریست کامل'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // پس‌زمینه زمردی و شبانه مدرن
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF081B1A),
                  Color(0xFF060E12),
                  Color(0xFF0B1C1E),
                ],
              ),
            ),
          ),
          Positioned(
            top: -90,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x4410B981), Color(0x0010B981)],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -70,
            child: Container(
              width: 280,
              height: 280,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x38F59E0B), Color(0x00F59E0B)],
                ),
              ),
            ),
          ),
          ListenableBuilder(
            listenable: _engine,
            builder: (BuildContext context, _) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                    child: Column(
                      children: [
                        _buildTopHeader(),
                        const SizedBox(height: 8),
                        _buildStageMissionCard(),
                        const SizedBox(height: 8),
                        _buildShopCustomersStrip(),
                        const SizedBox(height: 8),
                        Expanded(child: _buildFarmGrid()),
                        const SizedBox(height: 8),
                        _buildCropSelectorBar(),
                        const SizedBox(height: 8),
                        _buildBottomControls(),
                        const SizedBox(height: 5),
                        const Text(
                          '$kBrandName  •  $kAuthorName  •  v$kVersion',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 0.4,
                            color: Color(0x66CBD5E1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: const Color(0x28FACC15),
                border: Border.all(color: const Color(0x66FACC15)),
              ),
              child: Text(
                '🪙 ${_engine.coins}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFFDE047),
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            if (_engine.combo >= 2) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC4899),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'کمبو ×${_engine.combo}',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
        Row(
          children: [
            _SmallIconBtn(
              icon: _engine.sound.enabled
                  ? Icons.volume_up_rounded
                  : Icons.volume_off_rounded,
              active: _engine.sound.enabled,
              onTap: _engine.toggleSound,
            ),
            const SizedBox(width: 6),
            _SmallIconBtn(
              icon: Icons.restart_alt_rounded,
              active: false,
              onTap: _confirmReset,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStageMissionCard() {
    final StageSpec spec = _engine.stageSpec;
    final bool readyToClaim = _engine.isCurrentStageComplete;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: readyToClaim
              ? const [Color(0x4410B981), Color(0x33FACC15)]
              : const [Color(0x1CFFFFFF), Color(0x0DFFFFFF)],
        ),
        border: Border.all(
          color: readyToClaim
              ? const Color(0xAA34D399)
              : const Color(0x26FFFFFF),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x3310B981),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'مرحله ${spec.number}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF6EE7B7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    spec.title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              if (readyToClaim)
                GestureDetector(
                  onTap: _onClaimStage,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'دریافت جایزه (+${spec.rewardCoins}🪙)',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              else if (_engine.statusBanner != null)
                Flexible(
                  child: Text(
                    _engine.statusBanner!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Color(0xBBFDE68A),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: spec.goals.map((StageGoal g) {
              final int cur = _engine.goalProgress(g).clamp(0, g.target);
              final bool done = cur >= g.target;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: done
                        ? const Color(0x3310B981)
                        : const Color(0x16071112),
                    border: Border.all(
                      color: done
                          ? const Color(0x8834D399)
                          : const Color(0x1FFFFFFF),
                    ),
                  ),
                  child: Text(
                    '${done ? "✓ " : ""}${g.label}: $cur/${g.target}',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: done ? FontWeight.w700 : FontWeight.w500,
                      color: done
                          ? const Color(0xFFA7F3D0)
                          : const Color(0xCCE2E8F0),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildShopCustomersStrip() {
    return SizedBox(
      height: 118,
      child: Row(
        children: List.generate(3, (int slot) {
          final CustomerOrder? order = slot < _engine.customers.length
              ? _engine.customers[slot]
              : null;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: order == null
                  ? _buildEmptyCustomerSlot()
                  : _buildCustomerCard(order),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyCustomerSlot() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0x0EFFFFFF),
        border: Border.all(color: const Color(0x18FFFFFF)),
      ),
      alignment: Alignment.center,
      child: const Text(
        'در انتظار\nمشتری...',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 11, color: Color(0x66E2E8F0)),
      ),
    );
  }

  Widget _buildCustomerCard(CustomerOrder order) {
    final bool canServe = _engine.canFulfillOrder(order);
    final double ratio = order.patienceRatio;
    final Color barColor = ratio > 0.55
        ? const Color(0xFF10B981)
        : (ratio > 0.25 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444));

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _engine.serveCustomer(order.id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: canServe
                ? const [Color(0x3D10B981), Color(0x22059669)]
                : const [Color(0x1AFFFFFF), Color(0x0CFFFFFF)],
          ),
          border: Border.all(
            color: canServe
                ? const Color(0xCC34D399)
                : const Color(0x24FFFFFF),
            width: canServe ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.avatar} ${order.name}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '+${order.rewardCoins}🪙',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFDE047),
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: 4,
              runSpacing: 2,
              alignment: WrapAlignment.center,
              children: order.items.entries.map((MapEntry<CropType, int> e) {
                final CropSpec spec = CropCatalog.byType(e.key);
                final bool enough = _engine.stockOf(e.key) >= e.value;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: enough
                        ? const Color(0x3310B981)
                        : const Color(0x22071112),
                  ),
                  child: Text(
                    '${spec.emoji}×${e.value}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: enough
                          ? const Color(0xFFA7F3D0)
                          : const Color(0xBBE2E8F0),
                    ),
                  ),
                );
              }).toList(),
            ),
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 4,
                    backgroundColor: const Color(0x22FFFFFF),
                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  canServe ? 'لمس برای تحویل ✓' : 'موجودی کم است',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: canServe ? FontWeight.w800 : FontWeight.w400,
                    color: canServe
                        ? const Color(0xFF6EE7B7)
                        : const Color(0x88E2E8F0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmGrid() {
    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0x1AFFFFFF), Color(0x0BFFFFFF)],
            ),
            border: Border.all(color: const Color(0x26FFFFFF)),
          ),
          child: Column(
            children: List.generate(3, (int row) {
              return Expanded(
                child: Row(
                  children: List.generate(3, (int col) {
                    final int idx = row * 3 + col;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(4.5),
                        child: _buildPlotTile(_engine.plots[idx], nowMs),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildPlotTile(FarmPlot plot, int nowMs) {
    if (!plot.unlocked) {
      final int cost = _engine.unlockCostForPlot(plot.index);
      final bool canBuy = _engine.coins >= cost;
      return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _engine.tapPlot(plot.index);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: canBuy ? const Color(0x22FACC15) : const Color(0x28060E12),
            border: Border.all(
              color: canBuy ? const Color(0x88FACC15) : const Color(0x1EFFFFFF),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_open_rounded,
                size: 20,
                color: canBuy
                    ? const Color(0xFFFDE047)
                    : const Color(0x66FFFFFF),
              ),
              const SizedBox(height: 4),
              Text(
                '🪙 $cost',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: canBuy
                      ? const Color(0xFFFDE047)
                      : const Color(0x77E2E8F0),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (plot.isEmpty) {
      final CropSpec sel = CropCatalog.byType(_engine.selectedCrop);
      return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _engine.tapPlot(plot.index);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: const Color(0x36142921),
            border: Border.all(color: const Color(0x3334D399)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_circle_outline_rounded,
                size: 22,
                color: Color(0x886EE7B7),
              ),
              const SizedBox(height: 3),
              Text(
                'کاشت ${sel.name}',
                style: const TextStyle(
                  fontSize: 10.5,
                  color: Color(0x99A7F3D0),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final CropSpec spec = CropCatalog.byType(plot.crop!);
    final bool ready = plot.isReady(nowMs);
    final double prog = plot.progress(nowMs);
    final int secLeft = plot.remainingSeconds(nowMs);

    return GestureDetector(
      onTap: () {
        if (ready) {
          HapticFeedback.mediumImpact();
          _engine.tapPlot(plot.index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: ready
                ? [
                    Color(spec.colorValue).withAlpha(115),
                    const Color(0x4410B981),
                  ]
                : const [Color(0x3813261F), Color(0x280A1916)],
          ),
          border: Border.all(
            color: ready
                ? const Color(0xEEFDE047)
                : Color(spec.colorValue).withAlpha(90),
            width: ready ? 1.8 : 1.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              ready ? spec.emoji : (prog < 0.4 ? '🌱' : spec.emoji),
              style: TextStyle(fontSize: ready ? 30 : 24),
            ),
            const SizedBox(height: 4),
            if (ready)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'برداشت!',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              )
            else ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: prog,
                  minHeight: 5,
                  backgroundColor: const Color(0x24FFFFFF),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(spec.colorValue),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${secLeft}s',
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xBBE2E8F0),
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCropSelectorBar() {
    return SizedBox(
      height: 74,
      child: Row(
        children: CropCatalog.all.map((CropSpec spec) {
          final bool unlocked = _engine.isCropUnlocked(spec.type);
          final bool selected = _engine.selectedCrop == spec.type;
          final int stock = _engine.stockOf(spec.type);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.5),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _engine.selectCrop(spec.type);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: selected
                        ? Color(spec.colorValue).withAlpha(65)
                        : (unlocked
                            ? const Color(0x16FFFFFF)
                            : const Color(0x10071112)),
                    border: Border.all(
                      color: selected
                          ? Color(spec.colorValue)
                          : const Color(0x22FFFFFF),
                      width: selected ? 1.6 : 1.0,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            unlocked ? spec.emoji : '🔒',
                            style: const TextStyle(fontSize: 17),
                          ),
                          if (unlocked && stock > 0) ...[
                            const SizedBox(width: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$stock',
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        spec.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          color: unlocked
                              ? Colors.white
                              : const Color(0x66E2E8F0),
                        ),
                      ),
                      Text(
                        unlocked
                            ? (spec.seedCost == 0 ? 'رایگان' : '${spec.seedCost}🪙')
                            : 'مرحله ${spec.unlockStage}',
                        style: TextStyle(
                          fontSize: 9.5,
                          color: unlocked
                              ? const Color(0xCCFDE047)
                              : const Color(0x66E2E8F0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomControls() {
    final bool hasUpgradeReady = _engine.canAffordAnyUpgrade;
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _openUpgradesSheet(initialTab: 0),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: hasUpgradeReady
                      ? const [Color(0xFF10B981), Color(0xFF059669)]
                      : const [Color(0x22FFFFFF), Color(0x14FFFFFF)],
                ),
                border: Border.all(
                  color: hasUpgradeReady
                      ? const Color(0xAA6EE7B7)
                      : const Color(0x26FFFFFF),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.upgrade_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    hasUpgradeReady ? 'ارتقا و کارمندان •' : 'ارتقا و کارمندان',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => _openUpgradesSheet(initialTab: 1),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0x18FFFFFF),
                border: Border.all(color: const Color(0x28FFFFFF)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 18,
                    color: Color(0xFF67E8F9),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'انبار و فروش سریع',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SmallIconBtn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _SmallIconBtn({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: active ? const Color(0x2810B981) : const Color(0x14FFFFFF),
          border: Border.all(
            color: active ? const Color(0x6634D399) : const Color(0x22FFFFFF),
          ),
        ),
        child: Icon(
          icon,
          size: 19,
          color: active ? const Color(0xFF6EE7B7) : const Color(0xAAFFFFFF),
        ),
      ),
    );
  }
}

class _SheetTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SheetTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(vertical: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: selected ? const Color(0x3810B981) : Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? Colors.white : const Color(0x99E2E8F0),
          ),
        ),
      ),
    );
  }
}
