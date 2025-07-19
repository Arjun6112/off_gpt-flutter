import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class DropMenu extends StatefulWidget {
  final Function netCheck;
  final Function newNote;
  final Function shareAll;
  final Function showSettings;
  const DropMenu(this.netCheck, this.newNote, this.shareAll, this.showSettings,
      {super.key});

  @override
  State<DropMenu> createState() => _DropMenuState();
}

class _DropMenuState extends State<DropMenu> {
  final FocusNode _buttonFocusNode = FocusNode(debugLabel: 'DropMenu');

  @override
  void dispose() {
    _buttonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MenuAnchor(
      childFocusNode: _buttonFocusNode,
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(
          isDark
              ? const Color(0xFF09090B) // Zinc-950
              : const Color(0xFFFFFFFF), // Pure white
        ),
        surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
        elevation: WidgetStateProperty.all(8),
        side: WidgetStateProperty.all(
          BorderSide(
            color: isDark
                ? const Color(0xFF27272A) // Zinc-800
                : const Color(0xFFE4E4E7), // Zinc-200
            width: 1,
          ),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
      menuChildren: <Widget>[
        _buildMenuItem(
          icon: Icons.network_check_rounded,
          text: tr("l_server_check"),
          onPressed: () => widget.netCheck(),
          isDark: isDark,
        ),
        _buildMenuItem(
          icon: Icons.add_rounded,
          text: tr("l_new_chat"),
          onPressed: () => widget.newNote(),
          isDark: isDark,
        ),
        _buildMenuItem(
          icon: Icons.share_rounded,
          text: tr("l_share_all"),
          onPressed: () => widget.shareAll(),
          isDark: isDark,
        ),
        _buildMenuItem(
          icon: Icons.settings_rounded,
          text: tr("l_settings"),
          onPressed: () => widget.showSettings(),
          isDark: isDark,
        ),
      ],
      builder: (_, MenuController controller, Widget? child) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.more_vert_rounded,
                size: 18,
                color: isDark
                    ? const Color(0xFFA1A1AA) // Zinc-400
                    : const Color(0xFF71717A), // Zinc-500
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  icon,
                  size: 16,
                  color: isDark
                      ? const Color(0xFFA1A1AA) // Zinc-400
                      : const Color(0xFF71717A), // Zinc-500
                ),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFFF4F4F5) // Zinc-100
                        : const Color(0xFF09090B), // Zinc-950
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
