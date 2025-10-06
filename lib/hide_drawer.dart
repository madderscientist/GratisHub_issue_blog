import 'package:flutter/material.dart';
class RightDrawer extends StatefulWidget {
  final double sideWidth;
  final Widget child;
  final bool visible;

  const RightDrawer({
    super.key,
    required this.sideWidth,
    required this.visible,
    required this.child,
  });

  @override
  State<RightDrawer> createState() => _RightDrawerState();
}

class _RightDrawerState extends State<RightDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    ));
    _controller.value = widget.visible ? 1.0 : 0.0;
  }

  @override
  void didUpdateWidget(covariant RightDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !oldWidget.visible) {
      _controller.forward();
    } else if (!widget.visible && oldWidget.visible) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 完全收回去之后再移除，避免闪一下
    if (!widget.visible && _controller.status == AnimationStatus.dismissed) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return SlideTransition(
          position: _offsetAnimation,
          // 把 child 放到一个“定宽、定高、不被压缩”的盒子里，防止被外面的Stack挤压
          child: SizedBox(
            width: widget.sideWidth,      // 固定宽度
            height: double.infinity,      // 撑满 Stack 高度
            child: Align(
              alignment: Alignment.topRight,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: widget.sideWidth,  // 宽度变化时自带动画
                height: double.infinity,
                color: Colors.white,      // 添加白色底色
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}