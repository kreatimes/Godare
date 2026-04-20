import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:godare/values/colors_app.dart';

/// Menú circular flotante hecho a mano.
class MyCircularMenu extends StatefulWidget {
  final Function(int) onItemSelected;
  final int selectedItem;

  const MyCircularMenu({
    super.key,
    required this.onItemSelected,
    required this.selectedItem,
  });

  @override
  State<MyCircularMenu> createState() => _MyCircularMenuState();
}

class _MyCircularMenuState extends State<MyCircularMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isOpen = false;

  static const List<_MenuItem> _items = [
    _MenuItem(icon: Icons.home,         label: 'Inicio',   activeColor: Colors.green),
    _MenuItem(icon: Icons.groups,       label: 'Amigos',   activeColor: Colors.orange),
    _MenuItem(pngAsset: 'assets/icons/challenges.png', label: 'Retos', activeColor: Colors.deepPurple),
    _MenuItem(icon: Icons.emoji_events, label: 'Ranking',  activeColor: Colors.amber),
    _MenuItem(icon: Icons.store,        label: 'Tienda',   activeColor: Colors.blue),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isOpen = !_isOpen);
    if (_isOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _selectItem(int index) {
    widget.onItemSelected(index);
    _toggle();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ..._buildMenuItems(),
          GestureDetector(
            onTap: _toggle,
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: ColorsApp.basePink,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ColorsApp.basePink.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: AnimatedRotation(
                turns: _isOpen ? 0.125 : 0,
                duration: const Duration(milliseconds: 300),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMenuItems() {
    const double startAngle = 200 * math.pi / 180;
    const double endAngle   = 340 * math.pi / 180;
    const double radius     = 95.0;
    const double centerX    = 130;
    const double centerY    = 229;

    return List.generate(_items.length, (index) {
      final item       = _items[index];
      final isSelected = widget.selectedItem == index;

      final angle  = startAngle + (endAngle - startAngle) * (index / (_items.length - 1));
      final targetX = centerX + radius * math.cos(angle) - 24;
      final targetY = centerY + radius * math.sin(angle) - 24;

      return AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) {
          final currentX = centerX - 24 + (targetX - (centerX - 24)) * _expandAnimation.value;
          final currentY = centerY - 24 + (targetY - (centerY - 24)) * _expandAnimation.value;

          return Positioned(
            left: currentX,
            top: currentY,
            child: Opacity(
              opacity: _expandAnimation.value,
              child: child,
            ),
          );
        },
        child: GestureDetector(
          onTap: () => _selectItem(index),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected ? item.activeColor : Colors.black87,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: item.pngAsset != null
                  ? Image.asset(item.pngAsset!, width: 30, height: 30)
                  : Icon(item.icon, color: Colors.white, size: 22),
            ),
          ),
        ),
      );
    });
  }
}

class _MenuItem {
  final IconData? icon;
  final String? pngAsset;
  final Color activeColor;
  final String label;

  const _MenuItem({
    this.icon,
    this.pngAsset,
    required this.activeColor,
    required this.label,
  });
}