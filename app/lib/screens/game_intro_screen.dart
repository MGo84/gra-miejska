import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/settings_provider.dart';
import '../core/widgets/narration_overlay.dart';
import '../providers/game_progress_provider.dart';
import '../models/game_progress.dart';
import '../widgets/game_menu_bar.dart';

class GameIntroScreen extends StatefulWidget {
  const GameIntroScreen({super.key});

  @override
  _GameIntroScreenState createState() => _GameIntroScreenState();
}

class _GameIntroScreenState extends State<GameIntroScreen> {
  int _currentPart = 0;
  String _displayed = '';
  bool _showNext = true; // Next should be active immediately
  bool _fullyShown = false;
  List<String> _lines = [];
  int _linesRevealed = 0;
  int _typingSession = 0;

  List<String> get _parts => [
    'intro.part1'.tr(),
    'intro.part2'.tr(),
    'intro.part3'.tr(),
  ];

  @override
  void initState() {
    super.initState();
    // Start after first frame so MediaQuery and theme are available for measuring lines
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startTyping();
    });
  }

  void _autoSave() {
    final progress = GameProgress(
      currentScreen: '/intro',
      solvedPoints: [],
      inventory: [],
      username: null,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<GameProgressProvider>().save(progress);
      }
    });
  }

  void _startTyping() async {
    final sessionId = ++_typingSession;
    setState(() {
      _displayed = '';
      _showNext = true; // button active immediately
      _fullyShown = false;
    });
    final text = _parts[_currentPart];
    // Reveal the text line-by-line. Use TextPainter to compute line breaks
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth < 360 ? 8.0 : screenWidth * 0.04;
    final fontSize = screenWidth < 360 ? 16.0 : 18.0;
    final textStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: fontSize,
          height: 1.35,
          color: Colors.white,
        ) ??
        TextStyle(fontSize: fontSize, height: 1.35, color: Colors.white);

    final maxWidth = screenWidth - horizontalPadding * 2;
    final tp = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: Directionality.of(context),
      maxLines: null,
    );
    tp.layout(minWidth: 0, maxWidth: maxWidth);
    final metrics = tp.computeLineMetrics();

    // Extract per-line substrings so we can animate each line independently
    final lineEndOffsets = <int>[];
    for (var i = 0; i < metrics.length; i++) {
      final lm = metrics[i];
      final dy = lm.baseline - lm.ascent / 2;
      final pos = tp.getPositionForOffset(Offset(1.0, dy));
      final range = tp.getLineBoundary(pos);
      lineEndOffsets.add(range.end);
    }

    final lines = <String>[];
    var prev = 0;
    for (final end in lineEndOffsets) {
      lines.add(text.substring(prev, end));
      prev = end;
    }

    setState(() {
      _lines = lines;
      _linesRevealed = 0;
      _displayed = '';
    });

    const lineDelay = Duration(milliseconds: 350); // faster, smooth fade
    for (var i = 0; i < _lines.length; i++) {
      if (sessionId != _typingSession) return;
      await Future.delayed(lineDelay);
      if (!mounted) return;
      if (sessionId != _typingSession) return;
      setState(() {
        _linesRevealed = i + 1;
        _displayed = _lines.take(_linesRevealed).join();
      });
    }

    if (!mounted) return;
    if (sessionId != _typingSession) return;
    setState(() {
      _fullyShown = true;
      _showNext = true;
      _linesRevealed = _lines.length;
      _displayed = _lines.join();
    });
    _autoSave();
  }

  void _nextPart() {
    final fullText = _parts[_currentPart];
    if (!_fullyShown) {
      // reveal remaining text immediately
      _typingSession++;
      setState(() {
        _displayed = fullText;
        _fullyShown = true;
        _showNext = true;
        _linesRevealed = _lines.length;
      });
      _autoSave();
      return;
    }

    if (_currentPart < _parts.length - 1) {
      setState(() {
        _currentPart++;
      });
      _startTyping();
    } else {
      Navigator.pushReplacementNamed(context, '/faction');
      _autoSave();
    }
  }

  @override
  Widget build(BuildContext context) {
    final narrationMode = context.watch<SettingsProvider>().narrationEnabled;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = screenWidth < 360 ? 8.0 : screenWidth * 0.04;
    final minTextAreaHeight = screenHeight * 0.32;
    final buttonWidth = screenWidth < 360 ? screenWidth * 0.7 : 360.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 12.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 32.0, bottom: 32.0),
              child: Container(
                width: 200,
                height: 200,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.image, size: 100, color: Colors.grey),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                    child: Stack(
                      children: [
                        if (!narrationMode)
                          SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: minTextAreaHeight,
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: Stack(
                                  alignment: Alignment.topLeft,
                                  children: [
                                    // Reserve final layout with a transparent full-text widget
                                    Opacity(
                                      opacity: 0.0,
                                      child: Text(
                                        _parts[_currentPart],
                                        textAlign: TextAlign.justify,
                                        softWrap: true,
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.copyWith(
                                              fontSize: screenWidth < 360
                                                  ? 16
                                                  : 18,
                                              height: 1.35,
                                              color: Colors.white,
                                            ) ??
                                            const TextStyle(
                                              fontSize: 18,
                                              height: 1.35,
                                              color: Colors.white,
                                            ),
                                      ),
                                    ),
                                    // Visible lines animated with fade so they appear smoothly
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: List.generate(_lines.length, (
                                        i,
                                      ) {
                                        final line = _lines[i];
                                        final visible = i < _linesRevealed;
                                        return AnimatedOpacity(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          opacity: visible ? 1.0 : 0.0,
                                          child: Text(
                                            line,
                                            textAlign: TextAlign.justify,
                                            softWrap: true,
                                            style:
                                                Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      fontSize:
                                                          screenWidth < 360
                                                          ? 16
                                                          : 18,
                                                      height: 1.35,
                                                      color: Colors.white,
                                                    ) ??
                                                const TextStyle(
                                                  fontSize: 18,
                                                  height: 1.35,
                                                  color: Colors.white,
                                                ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (narrationMode)
                          NarrationOverlay(
                            narrationMode: narrationMode,
                            text: _displayed,
                            showNext: _showNext,
                            allowTapDismiss: false,
                            onNext: _nextPart,
                            onSkip: () {
                              Navigator.pushReplacementNamed(context, '/map');
                            },
                            onDismiss: () {
                              setState(() {});
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: buttonWidth),
                child: ElevatedButton(
                  onPressed: _nextPart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _fullyShown
                        ? Colors.deepPurple
                        : Colors.grey,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 12.0,
                    ),
                  ),
                  child: Text(
                    'intro.next'.tr().toUpperCase(),
                    style: const TextStyle(letterSpacing: 1.0),
                  ),
                ),
              ),
            ),
          ),
          GameMenuBar(
            onMenuTap: (id) {
              if (id == 'map') Navigator.pushReplacementNamed(context, '/map');
              if (id == 'home')
                Navigator.pushReplacementNamed(context, '/home');
              if (id == 'ekwipunek') Navigator.pushNamed(context, '/choice');
              if (id == 'powrot') {
                final provider = context.read<GameProgressProvider>();
                final route = provider.progress?.currentScreen ?? '/intro';
                final args = provider.progress?.currentArgs;
                Navigator.pushNamed(context, route, arguments: args);
              }
            },
            active: 'powrot',
          ),
        ],
      ),
    );
  }
}
