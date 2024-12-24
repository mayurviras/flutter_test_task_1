

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class DockView2 extends StatefulWidget {
  const DockView2({super.key});
  @override
  State<StatefulWidget> createState() =>_DockView2State();

}

class _DockView2State extends State<DockView2> with TickerProviderStateMixin{
  List<Widget> items = [
    const Icon(Icons.person,color: Colors.white,),
    const Icon(Icons.message,color: Colors.white,),
    const Icon(Icons.call,color: Colors.white,) ,
    const Icon(Icons.camera,color: Colors.white,) ,
    const Icon(Icons.photo,color: Colors.white,),
  ];

  final List<AnimationController> _controllers = [];
  int? _hoveredItemIndex;
  @override
  void initState() {
    super.initState();
    for (var i = 0; i < items.length; i++) {
      _controllers.add(AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ));
    }
  }
  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _actionJump(int index) {
    final controller = _controllers[index];

    controller.reset();
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return  Center(
      child: SizedBox(
        height: 70,
        width: 340,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(20),
          ),
          child: ReorderableListView.builder(
            scrollDirection: Axis.horizontal,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final item = items.removeAt(oldIndex);
                items.insert(newIndex, item);
              });
            },
            buildDefaultDragHandles: false,
            proxyDecorator: (child, index, animation) {
              return Material(
                child: child,
              );
            },
            padding: EdgeInsets.zero,
            dragStartBehavior: DragStartBehavior.start,
            clipBehavior: Clip.none,
            onReorderStart: (in1){

            },
            itemBuilder: (BuildContext context, int index) {
              return ReorderableDragStartListener(
                index: index,
                enabled: true,
                key: ValueKey(items[index].hashCode),
                child: GestureDetector(
                  onTap: () => _actionJump(index),
                  child: AnimatedBuilder(
                    animation: _controllers[index],
                    builder: (context, child) {
                      final double offset =
                          -200 * _controllers[index].value * (1 - _controllers[index].value);
                      return Transform.translate(
                        offset: Offset(0, offset),
                        child: child,
                      );
                    },
                    child: _dockItemView(index),
                  ),
                ),
              );
            },
            itemCount: items.length,
          ),
        ),
      ),
    );
  }

  Widget _dockItemView(int index) {
    final isHoveredIcon = _hoveredItemIndex == index;
    final isNeighborIcon = _hoveredItemIndex != null &&
        (index == _hoveredItemIndex! - 1 || index == _hoveredItemIndex! + 1);

    final scale = isHoveredIcon
        ? 1.2
        : isNeighborIcon
        ? 1.1
        : 1.0;
    final translateY = isHoveredIcon
        ? -18.0
        : isNeighborIcon
        ? -9.0
        : 0.0;
    final translateDefault = isHoveredIcon
        ? -5.0
        : isNeighborIcon
        ? -5.0
        : 0.0;


    return MouseRegion(
      onEnter: (_) => setState(() {
        _hoveredItemIndex = index;
      }),
      onExit: (_) => setState(() {
        _hoveredItemIndex = null;
      }),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..translate(translateDefault,translateY,translateDefault)..scale(scale),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 48,
        height: 48,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.primaries[items[index].hashCode % Colors.primaries.length],
        ),
        child: Center(
          child: items[index],
        ),
      ),
    );
  }

}
