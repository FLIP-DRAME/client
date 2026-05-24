import 'package:flutter_test/flutter_test.dart';
import 'package:mode/feat/main/network/drone_pilot_api.dart';
import 'package:mode/feat/main/network/quote_status.dart';

void main() {
  // ── QuoteStatusHelper unit tests ──────────────────────────────────────────

  group('QuoteStatusHelper.effectiveClientStatus', () {
    test('job=open, no quote → open', () {
      expect(
        QuoteStatusHelper.effectiveClientStatus(
          jobStatus: 'open',
          quoteStatus: '',
        ),
        'open',
      );
    });

    test('job=open, quote=quoted → quoted', () {
      expect(
        QuoteStatusHelper.effectiveClientStatus(
          jobStatus: 'open',
          quoteStatus: 'quoted',
        ),
        'quoted',
      );
    });

    test('job=open, quote=submitted → submitted', () {
      expect(
        QuoteStatusHelper.effectiveClientStatus(
          jobStatus: 'open',
          quoteStatus: 'submitted',
        ),
        'submitted',
      );
    });

    test('job=accepted overrides quoteStatus', () {
      expect(
        QuoteStatusHelper.effectiveClientStatus(
          jobStatus: 'accepted',
          quoteStatus: 'quoted',
        ),
        'accepted',
      );
    });

    test('job=in_progress overrides quoteStatus', () {
      expect(
        QuoteStatusHelper.effectiveClientStatus(
          jobStatus: 'in_progress',
          quoteStatus: 'quoted',
        ),
        'in_progress',
      );
    });

    test('job=completed overrides quoteStatus', () {
      expect(
        QuoteStatusHelper.effectiveClientStatus(
          jobStatus: 'completed',
          quoteStatus: 'quoted',
        ),
        'completed',
      );
    });
  });

  group('QuoteStatusHelper.clientLabel', () {
    test('open + no quote → 요청 보냄 (견적 대기중)', () {
      final effective = QuoteStatusHelper.effectiveClientStatus(
        jobStatus: 'open',
        quoteStatus: '',
      );
      expect(
        QuoteStatusHelper.clientLabel(effective, hasQuote: false),
        '요청 보냄',
      );
    });

    test('quoted + hasQuote → 견적 받음', () {
      expect(
        QuoteStatusHelper.clientLabel('quoted', hasQuote: true),
        '견적 받음',
      );
    });

    test('quoted + no quote → 요청 보냄', () {
      expect(
        QuoteStatusHelper.clientLabel('quoted', hasQuote: false),
        '요청 보냄',
      );
    });

    test('submitted → 견적 받음', () {
      expect(
        QuoteStatusHelper.clientLabel('submitted', hasQuote: true),
        '견적 받음',
      );
    });

    test('accepted → 진행중', () {
      expect(
        QuoteStatusHelper.clientLabel('accepted', hasQuote: true),
        '진행중',
      );
    });

    test('in_progress → 진행중', () {
      expect(
        QuoteStatusHelper.clientLabel('in_progress', hasQuote: true),
        '진행중',
      );
    });

    test('completed → 완료', () {
      expect(
        QuoteStatusHelper.clientLabel('completed', hasQuote: true),
        '완료',
      );
    });

    test('rejected → 거절', () {
      expect(
        QuoteStatusHelper.clientLabel('rejected', hasQuote: false),
        '거절',
      );
    });

    test('expired → 만료', () {
      expect(
        QuoteStatusHelper.clientLabel('expired', hasQuote: false),
        '만료',
      );
    });
  });

  // ── UserQuoteSummary model tests ──────────────────────────────────────────

  group('UserQuoteSummary status getters', () {
    UserQuoteSummary makeQuote(String status) => UserQuoteSummary(
      id: 'id',
      pilotId: 'pilot',
      pilotName: '테스트 운용자',
      category: '항공촬영',
      area: '서울',
      date: '2026.05.25',
      status: status,
      price: '-',
      detail: '',
      budgetRange: '',
      contactWindow: '',
      message: '',
    );

    test('요청 보냄 → isPending=true, 나머지 false', () {
      final q = makeQuote('요청 보냄');
      expect(q.isPending, isTrue);
      expect(q.isQuoteReceived, isFalse);
      expect(q.isInProgress, isFalse);
      expect(q.isCompleted, isFalse);
    });

    test('견적 받음 → isQuoteReceived=true, 나머지 false', () {
      final q = makeQuote('견적 받음');
      expect(q.isQuoteReceived, isTrue);
      expect(q.isPending, isFalse);
      expect(q.isInProgress, isFalse);
    });

    test('진행중 → isInProgress=true, 나머지 false', () {
      final q = makeQuote('진행중');
      expect(q.isInProgress, isTrue);
      expect(q.isPending, isFalse);
      expect(q.isQuoteReceived, isFalse);
    });

    test('완료 → isCompleted=true', () {
      final q = makeQuote('완료');
      expect(q.isCompleted, isTrue);
      expect(q.isPending, isFalse);
    });
  });

  // ── End-to-end status pipeline (simulates fetchMyQuotes row processing) ──

  group('견적 대기중 파이프라인', () {
    // Replicates the logic in fetchMyQuotes for a newly submitted job with no operator quote yet.
    test('신규 job_request(open) + 견적 없음 → 요청 보냄', () {
      const jobStatus = 'open';
      const quoteStatus = ''; // no quote row
      const hasQuote = false;

      final effective = QuoteStatusHelper.effectiveClientStatus(
        jobStatus: jobStatus,
        quoteStatus: quoteStatus,
      );
      final label = QuoteStatusHelper.clientLabel(effective, hasQuote: hasQuote);

      expect(label, '요청 보냄');

      final summary = UserQuoteSummary(
        id: 'job-1',
        pilotId: 'pilot-1',
        pilotName: '견적 대기중',
        category: '항공촬영',
        area: '서울',
        date: '2026.05.25',
        status: label,
        price: '-',
        detail: '현장 촬영',
        budgetRange: '50만원 이하',
        contactWindow: '오후',
        message: '',
      );

      expect(summary.isPending, isTrue,
          reason: '운용자가 아직 견적을 보내지 않은 요청은 isPending이어야 합니다.');
      expect(summary.isQuoteReceived, isFalse);
      expect(summary.isInProgress, isFalse);
    });

    test('운용자가 견적 제출(quoted/submitted) → 견적 받음', () {
      const jobStatus = 'open';
      const quoteStatus = 'submitted';
      const hasQuote = true;

      final effective = QuoteStatusHelper.effectiveClientStatus(
        jobStatus: jobStatus,
        quoteStatus: quoteStatus,
      );
      final label = QuoteStatusHelper.clientLabel(effective, hasQuote: hasQuote);

      expect(label, '견적 받음');

      final summary = UserQuoteSummary(
        id: 'job-2',
        pilotId: 'pilot-1',
        pilotName: '운용자A',
        category: '항공촬영',
        area: '서울',
        date: '2026.05.25',
        status: label,
        price: '30만원',
        detail: '',
        budgetRange: '',
        contactWindow: '',
        message: '견적을 보냈습니다.',
      );

      expect(summary.isQuoteReceived, isTrue);
      expect(summary.isPending, isFalse);
    });

    test('quoteRank: submitted > rejected (우선순위 정렬 검증)', () {
      expect(
        QuoteStatusHelper.quoteRank('submitted'),
        greaterThan(QuoteStatusHelper.quoteRank('rejected')),
      );
      expect(
        QuoteStatusHelper.quoteRank('accepted'),
        greaterThan(QuoteStatusHelper.quoteRank('submitted')),
      );
      expect(
        QuoteStatusHelper.quoteRank('completed'),
        greaterThan(QuoteStatusHelper.quoteRank('accepted')),
      );
    });
  });
}
