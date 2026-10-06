import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../copy/roasts.dart';
import '../../core/theme.dart';
import '../../core/wrapped.dart';
import '../../state/providers.dart';
import '../share/share_service.dart';
import 'wrapped_slides.dart';

class WrappedScreen extends ConsumerStatefulWidget {
  const WrappedScreen({super.key, required this.year});

  final int year;

  @override
  ConsumerState<WrappedScreen> createState() => _WrappedScreenState();
}

class _WrappedScreenState extends ConsumerState<WrappedScreen> {
  final _pages = PageController();
  final _keys = <int, GlobalKey>{};
  int _index = 0;
  bool _sharing = false;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _step(int delta, int count) {
    final next = _index + delta;
    if (next < 0 || next >= count) return;
    _pages.animateToPage(
      next,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _share() async {
    setState(() => _sharing = true);
    try {
      final boundary =
          _keys[_index]!.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      final file = await captureCard(
        boundary,
        'fuck-corpo-wrapped-${widget.year}-${_index + 1}',
      );
      await shareCardImage(file, text: wrappedCaption);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Couldn't print that slide. Try again."),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider)!;
    final sessions = ref.watch(sessionsProvider).value ?? const [];
    final stats = WrappedStats.from(sessions, widget.year);
    final slides = buildWrappedSlides(
      stats,
      profile,
      style: ref.watch(receiptStyleProvider),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Payslip.ink,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 4, 0),
                child: Row(
                  children: [
                    for (var i = 0; i < slides.length; i++)
                      Expanded(
                        child: Container(
                          height: 3,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          color: i <= _index
                              ? Payslip.paper
                              : Payslip.paper.withValues(alpha: 0.25),
                        ),
                      ),
                    IconButton(
                      tooltip: 'Close',
                      color: Payslip.paper,
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) => GestureDetector(
                    onTapUp: (d) => _step(
                      d.localPosition.dx < c.maxWidth / 3 ? -1 : 1,
                      slides.length,
                    ),
                    child: PageView.builder(
                      controller: _pages,
                      itemCount: slides.length,
                      onPageChanged: (i) => setState(() => _index = i),
                      itemBuilder: (context, i) => Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: FittedBox(
                            child: RepaintBoundary(
                              key: _keys.putIfAbsent(i, GlobalKey.new),
                              child: slides[i],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Payslip.paper,
                    foregroundColor: Payslip.ink,
                  ),
                  onPressed: _sharing ? null : _share,
                  icon: const Icon(Icons.ios_share),
                  label: const Text('SHARE THIS SLIDE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
