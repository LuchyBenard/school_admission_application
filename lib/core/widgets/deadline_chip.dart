import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// A countdown chip that shows how long remains until a school's
/// application deadline. Turns into a "Closed" chip once the deadline
/// has passed. Live-updates every second for an accurate countdown.
class DeadlineChip extends StatefulWidget {
  final DateTime? deadline;
  final bool showIcon;

  const DeadlineChip({
    super.key,
    this.deadline,
    this.showIcon = true,
  });

  @override
  State<DeadlineChip> createState() => _DeadlineChipState();
}

class _DeadlineChipState extends State<DeadlineChip> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTicker();
  }

  @override
  void didUpdateWidget(DeadlineChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.deadline != widget.deadline) {
      _startTicker();
    }
  }

  void _startTicker() {
    _timer?.cancel();
    if (widget.deadline != null) {
      _timer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => setState(() {}),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _isClosed =>
      widget.deadline == null || !DateTime.now().isBefore(widget.deadline!);

  String get _label {
    final deadline = widget.deadline;
    if (_isClosed) return 'Closed';

    final diff = deadline!.difference(DateTime.now());

    if (diff.inDays >= 1) {
      return '${diff.inDays}d ${diff.inHours % 24}h left';
    }
    if (diff.inHours >= 1) {
      return '${diff.inHours}h ${diff.inMinutes % 60}m left';
    }
    if (diff.inMinutes >= 1) {
      return '${diff.inMinutes}m left';
    }
    return 'Ends soon';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.deadline == null) return const SizedBox.shrink();

    final color =
        _isClosed ? AppColors.error : AppColors.warning;
    final background =
        color.withValues(alpha: _isClosed ? 0.12 : 0.15);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showIcon) ...[
            Icon(
              _isClosed
                  ? Icons.event_busy_outlined
                  : Icons.hourglass_top_outlined,
              size: 12.w,
              color: color,
            ),
            SizedBox(width: 4.w),
          ],
          Text(
            _label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}