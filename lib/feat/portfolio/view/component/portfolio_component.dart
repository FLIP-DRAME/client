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
                child:
                    pilot.portfolioImages.isEmpty
                        ? const _EmptyPortfolioImage()
                        : _NetworkCover(imageUrl: pilot.portfolioImages.first),
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
          ],
        ),
        const SizedBox(height: 34),
        const _SectionTitle('서비스 상세설명'),
        const SizedBox(height: 14),
        Text(pilot.description, style: PortfolioText.body),
        const SizedBox(height: 40),
        if (pilot.portfolioImages.isNotEmpty) ...<Widget>[
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
        ],
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

class _EmptyPortfolioImage extends StatelessWidget {
  const _EmptyPortfolioImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _soft,
      child: const Center(
        child: Icon(Icons.flight_takeoff_rounded, color: _muted, size: 34),
      ),
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
