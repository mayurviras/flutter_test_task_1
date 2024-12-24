import 'package:flutter/material.dart';
import 'package:mac_doc_task/test.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: "Test Task",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: const [
              Expanded(child: SizedBox()),
              DockView(),
              Expanded(child: SizedBox()),
              DockView2(),
              Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );
  }
}
class DockView extends StatefulWidget {
  const DockView({super.key});

  @override
  State<StatefulWidget> createState() =>_DockViewState();

}

class _DockViewState extends State<DockView> with TickerProviderStateMixin{

  List<Widget> items = [
    const Icon(Icons.person,color: Colors.white,),
    const Icon(Icons.message,color: Colors.white,),
    const Icon(Icons.call,color: Colors.white,) ,
    const Icon(Icons.camera,color: Colors.white,) ,
    const Icon(Icons.photo,color: Colors.white,),
  ];
  double hoverScale = 2.5;
  final List<AnimationController> _controllers = [];
  int? _hoveredItemIndex;
  bool draggingActive =false;

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
  void _onReorderItem(int oldIndex, int newIndex) {
    setState(() {
      final item = items.removeAt(oldIndex);
      items.insert(newIndex, item);

      final controller = _controllers.removeAt(oldIndex);
      _controllers.insert(newIndex, controller);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(items.length, (index) {
            return DragTarget<int>(
              onAcceptWithDetails: (fromIndex) {
                _onReorderItem(fromIndex.data, index);
              },
              builder: (context, candidateData, rejectedData) {
                return Draggable<int>(
                  data: index,
                  feedback: _dockItemView(index),
                  childWhenDragging:const SizedBox.shrink(),
                  onDragStarted: () {
                    setState(() {
                      draggingActive =true;
                    });
                  },
                  onDragEnd: (details) {
                    setState(() {
                      draggingActive =false;
                    });
                  },
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
                      child: _dockItemView( index),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ));
  }
  Widget _dockItemView(int index) {
    final isHoveredIcon = _hoveredItemIndex == index;
    final isNeighborIcon = _hoveredItemIndex != null &&
        (index == _hoveredItemIndex! - 1 || index == _hoveredItemIndex! + 1);

    final scale = isHoveredIcon
        ? 1.2
        : isNeighborIcon
        ? (draggingActive?1.2:1.1)
        : 1.0;
    final translateY = isHoveredIcon
        ? -18.0
        : isNeighborIcon
        ? (draggingActive?-18.0:-9.0)
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..translate(translateDefault,translateY,translateDefault)..scale(scale),
        margin: (isHoveredIcon|| isNeighborIcon) && draggingActive?EdgeInsets.only(left: index<1?6:40,right: index>=1?40:6):const EdgeInsets.symmetric(horizontal: 8),
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
