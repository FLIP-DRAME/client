import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'd_tokens.dart';

/// 비로그인 상태에서 로그인이 필요한 기능 클릭 시 호출.
/// 로그인 페이지로 이동할지 묻는 다이얼로그를 띄움.
Future<void> showLoginRequiredDialog(
  BuildContext context, {
  String message = '이 기능은 로그인 후 이용할 수 있습니다.',
}) async {
  await showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        title: const Text(
          '로그인이 필요합니다',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0A0B0D),
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF5B616E),
            height: 1.5,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF5B616E),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              textStyle: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              dialogContext.go('/login');
            },
            style: FilledButton.styleFrom(
              backgroundColor: DC.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('로그인하기'),
          ),
        ],
      );
    },
  );
}
