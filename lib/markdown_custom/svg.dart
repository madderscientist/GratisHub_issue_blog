import 'package:flutter/material.dart';
import 'package:markdown_widget/widget/widget_visitor.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:markdown_widget/widget/inlines/img.dart';

/// Special handling for SVG images
final svgImgGenerator = SpanNodeGeneratorWithTag(
  tag: 'img',
  generator: (node, config, visitor) {
    final attr = node.attributes;
    final src = attr['src'] ?? '';
    if (src.toLowerCase().endsWith('.svg')) {
      return SvgNode(attr, config, visitor);
    }
    return ImageNode(attr, config, visitor);
  },
);

class SvgNode extends ImageNode {
  SvgNode(super.attributes, super.config, super.visitor);

  @override
  InlineSpan build() {
    double? width;
    double? height;
    if (attributes['width'] != null && attributes['width']!.isNotEmpty) {
      width = double.tryParse(attributes['width']!);
    }
    if (attributes['height'] != null && attributes['height']!.isNotEmpty) {
      height = double.tryParse(attributes['height']!);
    }
    final imageUrl = attributes['src'] ?? '';
    // 但是会显示异常 疑似是插件的问题
    final svgWidget = SvgPicture.network(
      imageUrl,
      width: width,
      height: height,
      fit: BoxFit.contain,
      clipBehavior: Clip.none,
      placeholderBuilder: (BuildContext context) => buildErrorImage(imageUrl, attributes['alt'] ?? '', null),
    );
    // 和ImageNode相比少了点击放大
    return WidgetSpan(child: svgWidget);
  }
}