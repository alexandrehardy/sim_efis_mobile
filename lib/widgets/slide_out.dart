import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SlideOutWidget extends MultiChildRenderObjectWidget {
  final double amount;
  final double maxDistance;

  SlideOutWidget({
    Key? key,
    required Widget bottom,
    required Widget top,
    required this.amount,
    required this.maxDistance,
  }) : super(key: key, children: [bottom, top]);

  @override
  RenderObject createRenderObject(context) {
    return RenderSlideOut(maxDistance, amount);
  }

  @override
  void updateRenderObject(BuildContext context, RenderSlideOut renderObject) {
    renderObject.maxDistance = maxDistance;
    renderObject.amount = amount;
    renderObject.markNeedsPaint();
  }
}

class SlideOutParentData extends ContainerBoxParentData<RenderBox> {}

class RenderSlideOut extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, SlideOutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, SlideOutParentData> {
  double maxDistance;
  double amount;
  RenderSlideOut(this.maxDistance, this.amount);

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! SlideOutParentData) {
      child.parentData = SlideOutParentData();
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

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (amount > 0.5) {
      return firstChild?.hitTest(result, position: position) ?? false;
    } else {
      final SlideOutParentData? childParentData =
          firstChild?.parentData as SlideOutParentData?;
      RenderBox? secondChild = childParentData?.nextSibling;
      return secondChild?.hitTest(result, position: position) ?? false;
    }
  }

  Size computeSizeForNoChild(BoxConstraints constraints) {
    return constraints.smallest;
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
      final SlideOutParentData childParentData =
          child.parentData! as SlideOutParentData;
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
      final SlideOutParentData childParentData =
          child.parentData! as SlideOutParentData;
      child = childParentData.nextSibling;
    }
    size = Size(width, height);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox? child = firstChild;
    if (child != null) {
      context.paintChild(child, offset);
      final SlideOutParentData childParentData =
          child.parentData! as SlideOutParentData;
      child = childParentData.nextSibling;
    }
    if (child != null) {
      context.paintChild(child, offset + Offset(amount * maxDistance, 0.0));
    }
  }
}
