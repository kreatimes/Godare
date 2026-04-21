import 'package:flutter/material.dart';
import 'package:godare/values/colors_app.dart';

// Menu flotante que se despliega en linea horizontal desde el centro
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
  bool _isOpen = false;

  static const List<_MenuItem> _items = [
    _MenuItem(icon: Icons.home,         label: 'Inicio',  activeColor: Colors.green),
    _MenuItem(icon: Icons.groups,       label: 'Amigos',  activeColor: Colors.orange),
    _MenuItem(pngAsset: 'assets/icons/challenges.png', label: 'Retos', activeColor: Colors.deepPurple),
    _MenuItem(icon: Icons.emoji_events, label: 'Ranking', activeColor: Colors.amber),
    _MenuItem(icon: Icons.store,        label: 'Tienda',  activeColor: Colors.blue),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isOpen = !_isOpen);
    _isOpen ? _controller.forward() : _controller.reverse();
  }

  void _selectItem(int index) {
    widget.onItemSelected(index);
    if (_isOpen) _toggle();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // fila de items que aparece sobre el boton
            if (_controller.value > 0)
              Opacity(
                opacity: _controller.value,
                child: Transform.translate(
                  offset: Offset(0, 12 * (1 - _controller.value)),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.88),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(_items.length, (index) {
                        final item = _items[index];
                        final isSelected = widget.selectedItem == index;
                        final delay = index / (_items.length - 1);
                        final itemAnim = CurvedAnimation(
                          parent: _controller,
                          curve: Interval(
                            delay * 0.3,
                            delay * 0.3 + 0.7,
                            curve: Curves.easeOut,
                          ),
                        );

                        return AnimatedBuilder(
                          animation: itemAnim,
                          builder: (context, child) => Opacity(
                            opacity: itemAnim.value,
                            child: Transform.translate(
                              offset: Offset(0, 8 * (1 - itemAnim.value)),
                              child: child,
                            ),
                          ),
                          child: GestureDetector(
                            onTap: () => _selectItem(index),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: isSelected ? 50 : 44,
                                    height: isSelected ? 50 : 44,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? item.activeColor
                                          : Colors.white.withOpacity(0.12),
                                      shape: BoxShape.circle,
                                      border: isSelected
                                          ? Border.all(
                                        color: item.activeColor.withOpacity(0.5),
                                        width: 2,
                                      )
                                          : null,
                                    ),
                                    child: Center(
                                      child: item.pngAsset != null
                                          ? Image.asset(item.pngAsset!,
                                          width: 24, height: 24,
                                          color: Colors.white)
                                          : Icon(item.icon,
                                          color: Colors.white,
                                          size: isSelected ? 22 : 20),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.label,
                                    style: TextStyle(
                                      color: isSelected
                                          ? item.activeColor
                                          : Colors.white54,
                                      fontSize: 9,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),

            // boton principal
            GestureDetector(
              onTap: _toggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: _isOpen ? Colors.black87 : ColorsApp.basePink,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_isOpen ? Colors.black : ColorsApp.basePink)
                          .withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: AnimatedRotation(
                  turns: _isOpen ? 0.125 : 0,
                  duration: const Duration(milliseconds: 280),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
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