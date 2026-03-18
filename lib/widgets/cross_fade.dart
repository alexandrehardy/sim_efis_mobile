import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CrossFadeWidget extends MultiChildRenderObjectWidget {
  final double amount;

  CrossFadeWidget({
    Key? key,
    required Widget first,
    required Widget second,
    required this.amount,
  }) : super(key: key, children: [first, second]);

  @override
  RenderObject createRenderObject(context) {
    return RenderCrossFade(amount);
  }

  @override
  void updateRenderObject(BuildContext context, RenderCrossFade renderObject) {
    renderObject.amount = amount;
    renderObject.markNeedsPaint();
  }
}

class CrossFadeParentData extends ContainerBoxParentData<RenderBox> {}

class RenderCrossFade extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, CrossFadeParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, CrossFadeParentData> {
  double amount;
  RenderCrossFade(this.amount);

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! CrossFadeParentData) {
      child.parentData = CrossFadeParentData();
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    RenderBox? child = firstChild;
    if (child != null) {
      return child.getMinIntrinsicWidth(height);
    }
    return 0.0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    RenderBox? child = firstChild;
    if (child != null) {
      return child.getMaxIntrinsicWidth(height);
    }
    return 0.0;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    RenderBox? child = firstChild;
    if (child != null) {
      return child.getMinIntrinsicHeight(width);
    }
    return 0.0;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    RenderBox? child = firstChild;
    if (child != null) {
      return child.getMaxIntrinsicHeight(width);
    }
    return 0.0;
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    RenderBox? child = firstChild;
    if (child != null) {
      return child.getDistanceToActualBaseline(baseline);
    }
    return super.computeDistanceToActualBaseline(baseline);
  }

  Size computeSizeForNoChild(BoxConstraints constraints) {
    return constraints.smallest;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (amount < 0.5) {
      return firstChild?.hitTest(result, position: position) ?? false;
    } else {
      final CrossFadeParentData? childParentData =
          firstChild?.parentData as CrossFadeParentData?;
      RenderBox? secondChild = childParentData?.nextSibling;
      return secondChild?.hitTest(result, position: position) ?? false;
    }
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    RenderBox? child = firstChild;
    double width = 0.0;
    double height = 0.0;
    if (child == null) {
      return computeSizeForNoChild(constraints);
    }
    while (child != null) {
      Size childSize = child.computeDryLayout(
        constraints,
      );
      if (width < childSize.width) {
        width = childSize.width;
      }
      if (height < childSize.height) {
        height = childSize.height;
      }
      final CrossFadeParentData childParentData =
          child.parentData! as CrossFadeParentData;
      child = childParentData.nextSibling;
    }
    return Size(width, height);
  }

  @override
  void performLayout() {
    RenderBox? child = firstChild;
    double width = 0.0;
    double height = 0.0;
    if (child == null) {
      size = computeSizeForNoChild(constraints);
      return;
    }
    while (child != null) {
      child.layout(
        constraints,
        parentUsesSize: true,
      );
      if (width < child.size.width) {
        width = child.size.width;
      }
      if (height < child.size.height) {
        height = child.size.height;
      }
      final CrossFadeParentData childParentData =
          child.parentData! as CrossFadeParentData;
      child = childParentData.nextSibling;
    }
    size = Size(width, height);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox? child = firstChild;
    if (child != null) {
      context.paintChild(child, offset);
      final CrossFadeParentData childParentData =
          child.parentData! as CrossFadeParentData;
      child = childParentData.nextSibling;
    }
    if (child != null) {
      context.canvas.saveLayer(
          offset & size,
          Paint()
            ..blendMode = BlendMode.srcATop
            ..color = Color.fromARGB((amount * 255).round(), 255, 255, 255));
      context.paintChild(child, offset);
      context.canvas.restore();
    }
  }
}
