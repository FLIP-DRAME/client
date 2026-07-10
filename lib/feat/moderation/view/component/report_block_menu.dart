import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app_providers.dart';
import '../../../../common/d_tokens.dart';
import '../../model/moderation_model.dart';

/// Kebab-menu button offering "신고하기" / "차단하기" for a piece of UGC or
/// its author. Self-contained: owns its own dialogs and API calls, so it can
/// be dropped into any card (feed post, chat room app bar, profile) without
/// the parent needing to wire anything beyond identifying the target.
class ReportBlockMenuButton extends ConsumerWidget {
  const ReportBlockMenuButton({
    super.key,
    required this.reportTargetType,
    required this.reportTargetId,
    this.targetUserId,
    this.targetUserName = '이 사용자',
    this.isOwnContent = false,
    this.onBlocked,
    this.iconColor,
  });

  /// [ReportTargetType.feedPost] / [ReportTargetType.chatUser] / [ReportTargetType.userProfile]
  final String reportTargetType;

  /// The id of the reported thing itself (post id, or the other user's id
  /// when reporting a chat/profile).
  final String reportTargetId;

  /// The user who authored the content / the chat counterpart. Null hides
  /// the block option (nothing to block, e.g. reporting your own content
  /// isn't offered in the first place -- see [isOwnContent]).
  final String? targetUserId;
  final String targetUserName;

  /// Hides both actions when true (can't report/block yourself).
  final bool isOwnContent;

  /// Called after a successful block, so the caller can remove the blocked
  /// user's content from whatever list is currently showing it.
  final VoidCallback? onBlocked;

  final Color? iconColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isOwnContent) return const SizedBox.shrink();

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, color: iconColor ?? DC.muted),
      onSelected: (value) {
        if (value == 'report') {
          _showReportDialog(context, ref);
        } else if (value == 'block') {
          _showBlockDialog(context, ref);
        }
      },
      itemBuilder: (context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(value: 'report', child: Text('신고하기')),
        if (targetUserId != null)
          const PopupMenuItem<String>(value: 'block', child: Text('차단하기')),
      ],
    );
  }

  Future<void> _showReportDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<({String reason, String detail})>(
      context: context,
      builder: (_) => _ReportDialog(targetName: targetUserName),
    );
    if (result == null || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(moderationApiProvider)
          .submitReport(
            targetType: reportTargetType,
            targetId: reportTargetId,
            reason: result.reason,
            detail: result.detail,
          );
      messenger.showSnackBar(
        const SnackBar(
          content: Text('신고가 접수되었습니다. 검토 후 조치하겠습니다.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('신고 접수에 실패했습니다: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showBlockDialog(BuildContext context, WidgetRef ref) async {
    final userId = targetUserId;
    if (userId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('사용자를 차단할까요?'),
        content: Text(
          '$targetUserName님을 차단하면 서로의 게시글과 채팅이 보이지 않게 됩니다. '
          '마이페이지의 차단 관리에서 언제든 해제할 수 있습니다.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('차단하기'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(moderationApiProvider).blockUser(userId);
      onBlocked?.call();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('차단했습니다.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('차단에 실패했습니다: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _ReportDialog extends StatefulWidget {
  const _ReportDialog({required this.targetName});

  final String targetName;

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  String _reason = reportReasons.first;
  final TextEditingController _detailController = TextEditingController();

  @override
  void dispose() {
    _detailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.targetName} 신고하기'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('신고 사유', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: DC.spXs),
            DropdownButtonFormField<String>(
              value: _reason,
              isExpanded: true,
              items: reportReasons
                  .map(
                    (reason) =>
                        DropdownMenuItem<String>(value: reason, child: Text(reason)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _reason = value);
              },
            ),
            const SizedBox(height: DC.spSm),
            const Text('상세 내용 (선택)', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: DC.spXs),
            TextField(
              controller: _detailController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '상황을 자세히 알려주시면 검토에 도움이 됩니다.',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop((
            reason: _reason,
            detail: _detailController.text.trim(),
          )),
          child: const Text('신고 제출'),
        ),
      ],
    );
  }
}
