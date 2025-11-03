import 'package:flutter/material.dart';

class NarrationOverlay extends StatefulWidget {
  final String text;
  final VoidCallback? onNext;
  final VoidCallback? onDismiss;
  final VoidCallback? onSkip;
  final bool narrationMode;
  final bool showNext;
  final bool allowTapDismiss;
  final Duration fadeDuration;

  const NarrationOverlay({
    super.key,
    required this.text,
    this.onNext,
    this.onDismiss,
    this.onSkip,
    this.narrationMode = false,
    this.showNext = false,
    this.allowTapDismiss = false,
    this.fadeDuration = const Duration(milliseconds: 300),
  });

  @override
  _NarrationOverlayState createState() => _NarrationOverlayState();
}

class _NarrationOverlayState extends State<NarrationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.fadeDuration);
    _scrollController = ScrollController();
    _ctrl.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth < 360 ? 8.0 : screenWidth * 0.04;
    final maxHeight = MediaQuery.of(context).size.height * 0.75;

    return FadeTransition(
      opacity: _ctrl,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (widget.allowTapDismiss && widget.onDismiss != null) {
                widget.onDismiss!();
              }
            },
            child: Container(color: Colors.black54),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 720,
                  maxHeight: maxHeight,
                ),
                child: Card(
                  color: Colors.black87.withOpacity(0.7),
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Flexible(
                          child: Scrollbar(
                            controller: _scrollController,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              child: Text(
                                widget.text,
                                textAlign: TextAlign.justify,
                                style:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.copyWith(
                                      color: Colors.white,
                                      fontSize: 18,
                                      height: 1.35,
                                    ) ??
                                    const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      height: 1.35,
                                    ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: widget.narrationMode
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () {
                      if (widget.onSkip != null) {
                        widget.onSkip!();
                      } else if (widget.onDismiss != null) {
                        widget.onDismiss!();
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
