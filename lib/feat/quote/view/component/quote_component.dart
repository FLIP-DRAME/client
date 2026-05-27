import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/drame_text_styles.dart';

const quoteNavy = Colors.black;
const quoteInk = Colors.black;
const quoteMuted = Colors.black;
const quoteSoft = Color(0xFFF7F8FA);
const quoteFocus = Color(0xFFE5E7EB);
const quoteLine = Color(0xFFE4EAF2);

class QuoteText {
  static const TextStyle logo = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: quoteNavy,
    fontSize: 18,
    fontWeight: DrameTextStyles.bold,
    height: 1.2,
  );

  static const TextStyle title = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: quoteInk,
    fontSize: DrameTextStyles.pageTitleSize,
    fontWeight: DrameTextStyles.bold,
    height: 1.25,
    letterSpacing: -0.25,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: quoteNavy,
    fontSize: DrameTextStyles.cardTitleSize,
    fontWeight: DrameTextStyles.bold,
    height: 1.3,
    letterSpacing: -0.15,
  );

  static const TextStyle body = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: quoteMuted,
    fontSize: DrameTextStyles.bodySize,
    fontWeight: DrameTextStyles.regular,
    height: 1.55,
  );

  static const TextStyle label = TextStyle(
    fontFamily: DrameTextStyles.fontFamily,
    color: quoteInk,
    fontSize: DrameTextStyles.labelSize,
    fontWeight: DrameTextStyles.semiBold,
    height: 1.35,
  );

  static const TextStyle button = DrameTextStyles.button;
}

class QuoteScaffold extends StatelessWidget {
  const QuoteScaffold({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: quoteSoft,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/my/quotes');
            }
          },
        ),
        title: Text(title, style: QuoteText.logo),
      ),
      body: child,
    );
  }
}

class QuoteShell extends StatelessWidget {
  const QuoteShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 42, 24, 72),
            child: child,
          ),
        ),
      ),
    );
  }
}

class QuotePanel extends StatelessWidget {
  const QuotePanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: quoteLine),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: quoteNavy.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: QuoteText.label),
    );
  }
}

class ChoiceWrap extends StatelessWidget {
  const ChoiceWrap({
    super.key,
    required this.values,
    required this.selected,
    required this.onSelected,
  });

  final List<String> values;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          values.map((value) {
            final active = selected == value;
            return ChoiceChip(
              selected: active,
              label: Text(value),
              onSelected: (_) => onSelected(value),
              color: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFFEEF0F3);
                }
                return Colors.white;
              }),
              showCheckmark: false,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: BorderSide(
                color: active ? const Color(0xFFB0B8C8) : quoteLine,
              ),
              labelStyle: QuoteText.body.copyWith(
                color: quoteInk,
                fontWeight: DrameTextStyles.semiBold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }).toList(),
    );
  }
}

class QuoteTextField extends StatelessWidget {
  const QuoteTextField({
    super.key,
    required this.label,
    required this.controller,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: QuoteText.body.copyWith(color: quoteInk),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: QuoteText.body,
        filled: true,
        fillColor: quoteSoft,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: quoteLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: quoteFocus),
        ),
      ),
    );
  }
}

class QuoteInfoRow extends StatelessWidget {
  const QuoteInfoRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(width: 128, child: Text(label, style: QuoteText.body)),
          Expanded(
            child: Text(
              value,
              style: QuoteText.label.copyWith(
                fontWeight: DrameTextStyles.semiBold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuoteStepHeader extends StatelessWidget {
  const QuoteStepHeader({super.key, required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: QuoteText.title),
        const SizedBox(height: 10),
        Text(body, style: QuoteText.body),
      ],
    );
  }
}
