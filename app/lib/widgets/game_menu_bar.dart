import 'package:flutter/material.dart';

class GameMenuBar extends StatefulWidget implements PreferredSizeWidget {
  final void Function(String) onMenuTap;
  final String active;
  const GameMenuBar({super.key, required this.onMenuTap, required this.active});

  @override
  State<GameMenuBar> createState() => _GameMenuBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _GameMenuBarState extends State<GameMenuBar> {
  String? _pressedId;

  @override
  Widget build(BuildContext context) {
    List<Widget> buttons = [
      _iconButton(context, Icons.home, 'home'),
      _iconButton(context, Icons.map, 'map'),
      _iconButton(context, Icons.backpack, 'ekwipunek'),
    ];
    return BottomAppBar(
      color: const Color(0xFF232323),
      elevation: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: buttons,
      ),
    );
  }

  Widget _iconButton(BuildContext context, IconData icon, String id) {
    final isPressed = _pressedId == id;
    // Default color: gray; when pressed -> deep purple
    final color = isPressed ? Colors.deepPurple : Colors.grey;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressedId = id),
      onTapUp: (_) => setState(() => _pressedId = null),
      onTapCancel: () => setState(() => _pressedId = null),
      child: IconButton(
        onPressed: () {
          if (id == 'ekwipunek') {
            try {
              Navigator.of(context).pushNamed('/text_challenge');
            } catch (_) {
              widget.onMenuTap(id);
            }
            return;
          }
          widget.onMenuTap(id);
        },
        icon: Icon(icon, color: color),
        tooltip: id,
      ),
    );
  }
}
