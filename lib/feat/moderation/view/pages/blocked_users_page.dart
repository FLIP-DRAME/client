import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app_providers.dart';
import '../../../../common/d_tokens.dart';
import '../../model/moderation_model.dart';

class BlockedUsersPage extends ConsumerStatefulWidget {
  const BlockedUsersPage({super.key});

  @override
  ConsumerState<BlockedUsersPage> createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends ConsumerState<BlockedUsersPage> {
  List<BlockedUser>? _users;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final users = await ref.read(moderationApiProvider).fetchBlockedUsers();
      if (mounted) setState(() => _users = users);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  Future<void> _unblock(BlockedUser user) async {
    try {
      await ref.read(moderationApiProvider).unblockUser(user.userId);
      if (mounted) {
        setState(() => _users = _users?.where((u) => u.userId != user.userId).toList());
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('차단 해제에 실패했습니다: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = _users;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
          icon: const Icon(Icons.arrow_back_rounded, color: DC.ink),
        ),
        title: const Text(
          '차단 관리',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: DC.ink,
          ),
        ),
      ),
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(DC.spBase),
                child: Text('불러오지 못했습니다: $_error'),
              ),
            )
          : users == null
              ? const Center(child: CircularProgressIndicator())
              : users.isEmpty
                  ? const Center(
                      child: Text(
                        '차단한 사용자가 없습니다.',
                        style: TextStyle(color: DC.muted),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: DC.spXs),
                      itemCount: users.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: DC.hairlineSoft),
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return ListTile(
                          title: Text(user.displayName),
                          trailing: TextButton(
                            onPressed: () => _unblock(user),
                            child: const Text('차단 해제'),
                          ),
                        );
                      },
                    ),
    );
  }
}
