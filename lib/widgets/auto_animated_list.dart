import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sim_efis/widgets/slide_out.dart';

enum ResizingAction {
  done,
  deleting,
  adding,
  changing,
}

class ResizingWidget {
  Widget sourceWidget;
  Widget targetWidget;
  ResizingAction action;

  ResizingWidget({
    required this.sourceWidget,
    required this.targetWidget,
    required this.action,
  });
}

class AutoAnimatedList extends StatefulWidget {
  final List<Widget> children;
  const AutoAnimatedList({
    Key? key,
    required this.children,
  }) : super(key: key);

  @override
  State<AutoAnimatedList> createState() => _AutoAnimatedListState();
}

class _AutoAnimatedListState extends State<AutoAnimatedList>
    with SingleTickerProviderStateMixin {
  List<ResizingWidget> children = [];
  AnimationController? animation;
  ReverseAnimation? reverseAnimation;

  @override
  void initState() {
    super.initState();
    animation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      animationBehavior: AnimationBehavior.preserve,
    );
    reverseAnimation = ReverseAnimation(animation!);
    children = widget.children
        .map((e) => ResizingWidget(
              sourceWidget: Container(),
              targetWidget: e,
              action: ResizingAction.done,
            ))
        .toList();
  }

  @override
  dispose() {
    animation?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AutoAnimatedList oldWidget) {
    super.didUpdateWidget(oldWidget);
    int index;
    int changes = 0;

    for (index = 0; index < widget.children.length; index++) {
      if (index < children.length) {
        if (children[index].targetWidget.key != widget.children[index].key) {
          children[index].action = ResizingAction.changing;
          changes++;
          children[index].sourceWidget = children[index].targetWidget;
          children[index].targetWidget = widget.children[index];
        } else {
          //children[index].action = ResizingAction.done;
        }
      }
    }
    while (index < children.length) {
      children[index].action = ResizingAction.deleting;
      changes++;
    }
    if (changes > 0) {
      animation?.forward(from: 0.0);
    }
  }

  Widget buildAnimatedChild(ResizingWidget baseWidget) {
    switch (baseWidget.action) {
      case ResizingAction.adding:
        return SizeTransition(
          sizeFactor: animation as Animation<double>,
          child: baseWidget.targetWidget,
        );
      case ResizingAction.deleting:
        return SizeTransition(
          sizeFactor: reverseAnimation as Animation<double>,
          child: baseWidget.targetWidget,
        );
      case ResizingAction.changing:
        return AnimatedBuilder(
          animation: animation as Animation<double>,
          builder: (BuildContext context, Widget? child) => SlideOutWidget(
            maxDistance: 400,
            amount: animation!.value,
            top: baseWidget.sourceWidget,
            bottom: baseWidget.targetWidget,
          ),
        );
      case ResizingAction.done:
        return baseWidget.targetWidget;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: children.map((e) => buildAnimatedChild(e)).toList(),
    );
  }
}
