import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

abstract final class AppDimensions {
  // ── Base Spacing / Gap Scale (Kelipatan 4) ──
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space6 = 6.0;
  static const double space8 = 8.0;
  static const double space10 = 10.0;
  static const double space12 = 12.0;
  static const double space14 = 14.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;

  // ── Semantic Layout Constants ──
  static const double pagePadding = space16;
  static const double cardPadding = space16;
  static const double sectionGap = space20;
  static const double itemGap = space12;
  static const double smallGap = space8;
  static const double microGap = space4;

  // ── Border Radius Scale ──
  static const double radiusXs = 6.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusFull = 999.0; // Pill / Badge / Avatar

  // ── Component Sizing ──
  static const double buttonHeight = 44.0;
  static const double iconSs = 12.0;
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double avatarSize = 44.0;
  static const double maxFormWidth = 420.0;
  static const double maxDialogWidth = 520.0;

  // ── Ready-to-use EdgeInsets ──
  static const EdgeInsets paddingPage = EdgeInsets.all(pagePadding);
  static const EdgeInsets paddingCard = EdgeInsets.all(cardPadding);
  static const EdgeInsets paddingCardCompact = EdgeInsets.all(space12);
  static const EdgeInsets paddingBadge = EdgeInsets.symmetric(
    horizontal: space10,
    vertical: space4,
  );
  static const EdgeInsets paddingBanner = EdgeInsets.symmetric(
    horizontal: space14,
    vertical: space10,
  );

  // ── Ready-to-use BorderRadius ──
  static final BorderRadius borderRadiusSm = BorderRadius.circular(radiusSm);
  static final BorderRadius borderRadiusMd = BorderRadius.circular(radiusMd);
  static final BorderRadius borderRadiusLg = BorderRadius.circular(radiusLg);
  static final BorderRadius borderRadiusPill = BorderRadius.circular(
    radiusFull,
  );

  // ── Ready-to-use Gap Widgets (Otomatis untuk Row & Column) ──
  static const Gap gap4 = Gap(space4);
  static const Gap gap6 = Gap(space6);
  static const Gap gap8 = Gap(space8);
  static const Gap gap10 = Gap(space10);
  static const Gap gap12 = Gap(space12);
  static const Gap gap16 = Gap(space16);
  static const Gap gap20 = Gap(space20);
  static const Gap gap24 = Gap(space24);
  static const Gap gap32 = Gap(space32);

  // ── Ready-to-use SliverGap (Untuk CustomScrollView) ──
  static const SliverGap sliverGap8 = SliverGap(space8);
  static const SliverGap sliverGap12 = SliverGap(space12);
  static const SliverGap sliverGap16 = SliverGap(space16);
  static const SliverGap sliverGap24 = SliverGap(space24);
}
