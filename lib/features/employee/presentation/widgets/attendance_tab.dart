import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:hris_apps/apps/theme/app_colors.dart';
import 'package:hris_apps/apps/theme/app_dimensions.dart';
import 'package:hris_apps/features/employee/domain/entities/attendance_record.dart';
import 'package:hris_apps/features/employee/presentation/providers/employee_provider.dart';

class AttendanceTab extends StatefulWidget {
  final bool isLead;

  const AttendanceTab({super.key, required this.isLead});

  @override
  State<AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<AttendanceTab> {
  late final DateTime _today;
  late DateTime _selectedDate;
  late DateTime _focusedDate;
  CalendarView _view = CalendarView.month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _selectedDate = _today;
    _focusedDate = _today;
  }

  String _currentTimeFormatted() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatIndonesianDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Color _statusColor(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('terlambat')) return AppColors.warning;
    if (lower.contains('alpha') || lower.contains('tidak')) {
      return AppColors.error;
    }
    return AppColors.success;
  }

  static DateTime _addDays(DateTime date, int days) =>
      DateTime(date.year, date.month, date.day + days);

  static DateTime _startOfWeek(DateTime date, int firstDayOfWeek) {
    final sundayBasedWeekday = date.weekday % DateTime.daysPerWeek;
    final distance =
        (sundayBasedWeekday - firstDayOfWeek + DateTime.daysPerWeek) %
        DateTime.daysPerWeek;
    return _addDays(date, -distance);
  }

  List<AttendanceRecord> _eventsForDate(
    DateTime date,
    List<AttendanceRecord> history,
  ) {
    return history
        .where(
          (item) =>
              item.rawDate.year == date.year &&
              item.rawDate.month == date.month &&
              item.rawDate.day == date.day,
        )
        .toList(growable: false);
  }

  void _changeView(Set<CalendarView> selection) {
    final nextView = selection.first;
    final firstDayOfWeek = MaterialLocalizations.of(context)
        .firstDayOfWeekIndex;
    setState(() {
      _view = nextView;
      _focusedDate = nextView == CalendarView.month
          ? DateTime(_selectedDate.year, _selectedDate.month)
          : _startOfWeek(_selectedDate, firstDayOfWeek);
    });
  }

  void _selectDate(DateTime date, List<AttendanceRecord> events) {
    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day);
      _focusedDate = _selectedDate;
    });
  }

  void _showToday() {
    final firstDayOfWeek = MaterialLocalizations.of(context)
        .firstDayOfWeekIndex;
    setState(() {
      _selectedDate = _today;
      _focusedDate = _view == CalendarView.month
          ? DateTime(_today.year, _today.month)
          : _startOfWeek(_today, firstDayOfWeek);
    });
  }

  void _updateVisiblePage(DateTime pageAnchor) {
    setState(() {
      _focusedDate = pageAnchor;
    });
  }

  Future<void> _handleCheckIn(BuildContext context) async {
    final time = _currentTimeFormatted();
    final success = await context.read<EmployeeProvider>().performCheckIn(time);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: success ? null : AppColors.error,
          content: Text(
            success
                ? 'Check-In berhasil dicatat pukul $time.'
                : 'Gagal melakukan Check-In.',
          ),
        ),
      );
  }

  Future<void> _handleCheckOut(BuildContext context) async {
    final time = _currentTimeFormatted();
    final success = await context.read<EmployeeProvider>().performCheckOut(
      time,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: success ? null : AppColors.error,
          content: Text(
            success
                ? 'Check-Out berhasil dicatat pukul $time.'
                : 'Gagal melakukan Check-Out.',
          ),
        ),
      );
  }

  Widget _buildAttendanceMarkers(
    BuildContext context,
    CalendarDayDetails<AttendanceRecord> day,
  ) {
    if (day.events.isEmpty) return const SizedBox.shrink();

    final record = day.events.first;
    final selectedMarkerColor = Theme.of(context).colorScheme.onPrimary;
    final markerColor = day.isSelected
        ? selectedMarkerColor
        : _statusColor(record.status);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Container(
          width: AppDimensions.space6,
          height: AppDimensions.space6,
          decoration: BoxDecoration(color: markerColor, shape: BoxShape.circle),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeeProvider>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final selectedEvents = _eventsForDate(
      _selectedDate,
      provider.attendanceHistory,
    );
    final selectedRecord = selectedEvents.firstOrNull;

    final calendarTheme = CalendarCarouselThemeData(
      selected: CalendarDayStyle(
        backgroundColor: colors.primary,
        textStyle: TextStyle(
          color: colors.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      today: CalendarDayStyle(
        backgroundColor: colors.secondaryContainer,
        textStyle: TextStyle(
          color: colors.onSecondaryContainer,
          fontWeight: FontWeight.bold,
        ),
        border: BorderSide(color: colors.secondary),
      ),
      header: CalendarHeaderStyle(iconColor: colors.primary),
    );

    return RefreshIndicator(
      onRefresh: provider.loadAttendanceHistory,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppDimensions.paddingPage,
        children: [
          if (widget.isLead) ...[
            Container(
              padding: AppDimensions.paddingBanner,
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: 0.6),
                borderRadius: AppDimensions.borderRadiusSm,
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.verified_user_rounded,
                    size: 18,
                    color: colors.primary,
                  ),
                  AppDimensions.gap8,
                  Expanded(
                    child: Text(
                      'Mode Team Lead Aktif • Anda memiliki akses persetujuan cuti tim.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppDimensions.gap12,
          ],

          // ── Kartu Presensi Hari Ini ──
          Card(
            child: Padding(
              padding: AppDimensions.paddingCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Presensi Hari Ini', style: theme.textTheme.titleMedium),
                  AppDimensions.gap12,
                  Row(
                    children: [
                      Expanded(
                        child: _TimeBox(
                          label: 'Jam Masuk',
                          value: provider.todayCheckInTime ?? '--:--',
                          color: AppColors.success,
                        ),
                      ),
                      AppDimensions.gap12,
                      Expanded(
                        child: _TimeBox(
                          label: 'Jam Pulang',
                          value: provider.todayCheckOutTime ?? '--:--',
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  AppDimensions.gap16,
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed:
                              (provider.hasCheckedInToday ||
                                  provider.isSubmittingAttendance)
                              ? null
                              : () => _handleCheckIn(context),
                          icon: const Icon(
                            Icons.login_rounded,
                            size: AppDimensions.iconSm,
                          ),
                          label: const Text('Check-In'),
                        ),
                      ),
                      AppDimensions.gap12,
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed:
                              (!provider.hasCheckedInToday ||
                                  provider.hasCheckedOutToday ||
                                  provider.isSubmittingAttendance)
                              ? null
                              : () => _handleCheckOut(context),
                          icon: const Icon(
                            Icons.logout_rounded,
                            size: AppDimensions.iconSm,
                          ),
                          label: const Text('Check-Out'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          AppDimensions.gap20,

          // ── Kontrol Kalender (Judul, Tombol Hari Ini & Segmented View) ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Kalender Absensi', style: theme.textTheme.titleSmall),
              TextButton.icon(
                onPressed: _showToday,
                icon: const Icon(Icons.today_rounded, size: 18),
                label: const Text('Hari Ini'),
              ),
            ],
          ),
          AppDimensions.gap6,
          Row(
            children: [
              Expanded(
                child: SegmentedButton<CalendarView>(
                  segments: const [
                    ButtonSegment<CalendarView>(
                      value: CalendarView.month,
                      icon: Icon(Icons.calendar_view_month_rounded, size: 18),
                      label: Text('Bulan'),
                    ),
                    ButtonSegment<CalendarView>(
                      value: CalendarView.week,
                      icon: Icon(Icons.view_week_rounded, size: 18),
                      label: Text('Minggu'),
                    ),
                  ],
                  selected: {_view},
                  onSelectionChanged: _changeView,
                ),
              ),
            ],
          ),
          AppDimensions.gap10,

          // ── Legenda Status ──
          Row(
            children: [
              const _LegendDot(color: AppColors.success, label: 'Hadir'),
              AppDimensions.gap12,
              const _LegendDot(color: AppColors.warning, label: 'Terlambat'),
              AppDimensions.gap12,
              const _LegendDot(color: AppColors.error, label: 'Tidak Hadir'),
            ],
          ),
          AppDimensions.gap10,

          // ── Widget CalendarCarousel ──
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.space8),
              child: provider.isLoadingAttendance
                  ? const SizedBox(
                      height: 340,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        height: _view == CalendarView.month ? 390 : 175,
                        child: CalendarCarousel<AttendanceRecord>(
                          view: _view,
                          locale: Localizations.localeOf(context),
                          selectedDate: _selectedDate,
                          focusedDate: _focusedDate,
                          eventsForDate: (date) =>
                              _eventsForDate(date, provider.attendanceHistory),
                          firstDate: DateTime(_today.year - 1),
                          lastDate: DateTime(_today.year + 1, 12, 31),
                          onDateSelected: _selectDate,
                          onPageChanged: _updateVisiblePage,
                          markerBuilder: _buildAttendanceMarkers,
                          header: const CalendarHeaderConfig(
                            enableDatePicker: true,
                          ),
                          weekdays: const CalendarWeekdayConfig(
                            format: CalendarWeekdayFormat.short,
                          ),
                          layout: const CalendarLayoutConfig(
                            fixedSixWeeks: true,
                          ),
                          paging: const CalendarPagingConfig(),
                          theme: calendarTheme,
                        ),
                      ),
                    ),
            ),
          ),

          const Gap(AppDimensions.space14),

          // ── Detail Absensi Tanggal Terpilih ──
          Card(
            child: Padding(
              padding: AppDimensions.paddingCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatIndonesianDate(_selectedDate),
                        style: theme.textTheme.titleSmall,
                      ),
                      if (selectedRecord != null)
                        Container(
                          padding: AppDimensions.paddingBadge,
                          decoration: BoxDecoration(
                            color: _statusColor(selectedRecord.status)
                                .withValues(alpha: 0.12),
                            borderRadius: AppDimensions.borderRadiusPill,
                          ),
                          child: Text(
                            selectedRecord.status,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: _statusColor(selectedRecord.status),
                            ),
                          ),
                        ),
                    ],
                  ),
                  AppDimensions.gap10,
                  const Divider(),
                  AppDimensions.gap10,
                  if (selectedRecord == null)
                    Text(
                      'Tidak ada catatan presensi pada tanggal ini.',
                      style: theme.textTheme.bodySmall,
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: _TimeBox(
                            label: 'Check-In',
                            value: selectedRecord.checkIn,
                            color: AppColors.success,
                          ),
                        ),
                        AppDimensions.gap12,
                        Expanded(
                          child: _TimeBox(
                            label: 'Check-Out',
                            value: selectedRecord.checkOut,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppDimensions.space8,
          height: AppDimensions.space8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        AppDimensions.gap4,
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _TimeBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _TimeBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: AppDimensions.paddingCardCompact,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppDimensions.borderRadiusSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium),
          AppDimensions.gap4,
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
