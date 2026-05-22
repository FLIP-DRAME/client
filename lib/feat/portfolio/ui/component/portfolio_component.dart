part of '../pages/portfolio_page.dart';

class _PageShell extends StatelessWidget {
  const _PageShell({required this.child, this.top = 44, this.bottom = 44});

  final Widget child;
  final double top;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, top, 24, bottom),
          child: child,
        ),
      ),
    );
  }
}

class _PortfolioMain extends StatelessWidget {
  const _PortfolioMain({required this.pilot});

  final DronePilot pilot;

  @override
  Widget build(BuildContext context) {
    final reviews = <({String name, String text, double rating})>[
      (name: '김**', text: '견적이 빠르고 결과물이 깔끔했습니다. 다음에도 이용할게요.', rating: 5.0),
      (name: '이**', text: '허가 지역 설명과 촬영 동선 안내가 자세해서 믿음이 갔어요.', rating: 4.9),
      (name: '박**', text: '사진 퀄리티가 좋고 납품도 빨랐습니다.', rating: 4.8),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Container(
              width: 132,
              height: 132,
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: _NetworkCover(imageUrl: pilot.portfolioImages.first),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(pilot.name, style: PortfolioText.profileName),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: <Widget>[
                        _ProfileMeta(
                          icon: Icons.place_outlined,
                          text: pilot.location,
                        ),
                        _ProfileMeta(
                          icon: Icons.sell_outlined,
                          text: pilot.specialty,
                        ),
                        _ProfileMeta(
                          icon: Icons.map_outlined,
                          text: pilot.availableAreas.join(', '),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(pilot.intro, style: PortfolioText.profileDescription),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),
        const Divider(color: _line),
        const SizedBox(height: 34),
        const _SectionTitle('촬영자 정보'),
        const SizedBox(height: 16),
        _InfoBlock(
          rows: <({IconData icon, String text})>[
            (
              icon: Icons.verified_user_outlined,
              text: '허가 지역: ${pilot.permittedAreas.join(', ')}',
            ),
            (icon: Icons.call_outlined, text: '연락처: ${pilot.contact}'),
            (
              icon: Icons.payments_outlined,
              text: '기본 제안가: ${pilot.priceLabel}',
            ),
            (icon: Icons.work_outline, text: '완료 촬영: ${pilot.completedJobs}건'),
          ],
        ),
        const SizedBox(height: 34),
        const _SectionTitle('서비스 상세설명'),
        const SizedBox(height: 14),
        Text(pilot.description, style: PortfolioText.body),
        const SizedBox(height: 40),
        const _SectionTitle('사진 포트폴리오'),
        const SizedBox(height: 18),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: pilot.portfolioImages.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            mainAxisExtent: 220,
          ),
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: _NetworkCover(imageUrl: pilot.portfolioImages[index]),
            );
          },
        ),
        const SizedBox(height: 40),
        Row(
          children: <Widget>[
            const _SectionTitle('리뷰 및 별점'),
            const Spacer(),
            const Icon(Icons.star_rounded, color: Color(0xFFFFB020)),
            const SizedBox(width: 4),
            Text(
              '${pilot.rating.toStringAsFixed(1)} / 5.0',
              style: PortfolioText.rating,
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _ReviewInput(),

        ...reviews.map(
          (review) => _ReviewTile(
            name: review.name,
            text: review.text,
            rating: review.rating,
          ),
        ),
      ],
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.pilot});

  final DronePilot pilot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _line),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _navy.withValues(alpha: 0.06),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('견적 요청하기', style: PortfolioText.quoteTitle),
          const SizedBox(height: 14),
          Text(
            '${pilot.name}에게 원하는 촬영 서비스의 견적을 받아보세요.',
            style: PortfolioText.quoteBody,
          ),
          const SizedBox(height: 22),
          _QuotePriceRow(label: '촬영가 제안가', value: pilot.priceLabel),
          _QuotePriceRow(label: '응답 속도', value: pilot.responseTime),
          _QuotePriceRow(
            label: '가능 지역',
            value: pilot.availableAreas.join(', '),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _openQuoteRequest(context, pilot),
              style: FilledButton.styleFrom(
                backgroundColor: _navy,
                foregroundColor: Colors.white,
                textStyle: PortfolioText.button,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('촬영 요청하기'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMeta extends StatelessWidget {
  const _ProfileMeta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, color: _muted, size: 20),
        const SizedBox(width: 6),
        Text(text, style: PortfolioText.profileMeta),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: PortfolioText.sectionTitle);
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.rows});

  final List<({IconData icon, String text})> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          rows.map((row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: <Widget>[
                  Icon(row.icon, color: _navy, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(row.text, style: PortfolioText.infoText),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
    required this.name,
    required this.text,
    required this.rating,
  });

  final String name;
  final String text;
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const CircleAvatar(
            backgroundColor: _soft,
            child: Icon(Icons.person_outline_rounded, color: _muted),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(name, style: PortfolioText.reviewName),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFB020),
                      size: 18,
                    ),
                    Text(
                      rating.toStringAsFixed(1),
                      style: PortfolioText.rating,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(text, style: PortfolioText.reviewBody),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuotePriceRow extends StatelessWidget {
  const _QuotePriceRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: <Widget>[
          Text(label, style: PortfolioText.quoteLabel),
          const Spacer(),
          Text(value, style: PortfolioText.quoteValue),
        ],
      ),
    );
  }
}

class _NetworkCover extends StatelessWidget {
  const _NetworkCover({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xFFE4EAF2), Color(0xFFB8C7D8)],
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.flight_takeoff_rounded,
              color: Colors.white,
              size: 42,
            ),
          ),
        );
      },
    );
  }
}

class _ReviewInput extends StatefulWidget {
  const _ReviewInput({super.key});

  @override
  State<_ReviewInput> createState() => _ReviewInputState();
}

class _ReviewInputState extends State<_ReviewInput> {
  double _rating = 5.0;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _soft.withValues(alpha: 0.5), // 배경색을 연하게 설정
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('별점 선택', style: PortfolioText.quoteLabel),
              const SizedBox(width: 16),
              // 단순 구현을 위해 Row와 GestureDetector를 사용하여 별점 선택 UI 구성
              Row(
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () => setState(() => _rating = index + 1.0),
                    child: Icon(
                      Icons.star_rounded,
                      color:
                          _rating > index
                              ? const Color(0xFFFFB020)
                              : _muted.withValues(alpha: 0.3),
                      size: 28,
                    ),
                  );
                }),
              ),
              const SizedBox(width: 8),
              Text('$_rating점', style: PortfolioText.rating),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: '촬영 경험은 어떠셨나요? 리뷰를 남겨주세요.',
              hintStyle: PortfolioText.reviewBody.copyWith(color: _muted),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _line),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                // TODO: 리뷰 등록 로직 연결
                print('리뷰 등록: $_rating점, 내용: ${_controller.text}');
                _controller.clear();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('리뷰가 등록되었습니다.')));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _navy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('리뷰 등록하기'),
            ),
          ),
        ],
      ),
    );
  }
}
