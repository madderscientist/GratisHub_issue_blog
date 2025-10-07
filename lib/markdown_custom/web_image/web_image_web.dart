import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;
import '../../lazy_notifier.dart';

// 点击放大要搭配 web/index.html 中的 showImageOverlay 方法使用
@JS()
external void showImageOverlay(String id);

/// 用html渲染图片，支持跨域
/// 仅支持web平台
class WebImage extends StatefulWidget {
  final String url;
  final double? width;
  final double? height;
  final bool allowClickToEnlarge;

  const WebImage({
    super.key,
    this.url = '',
    this.width,
    this.height,
    this.allowClickToEnlarge = true,
  });

  @override
  State<WebImage> createState() => _WebImageState();
}

class _WebImageState extends State<WebImage> {
  late LazyNotifier<List<double?>> sizeNotifier = LazyNotifier([null, null]);
  late String _viewType;

  @override
  void initState() {
    super.initState();
    if (kIsWeb == false) {
      throw UnsupportedError('WebImage is only supported on web platform');
    }
    _viewType =
        "web_image_${widget.url.hashCode}_${DateTime.now().millisecondsSinceEpoch}";

    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final img = web.HTMLImageElement();
      img.id = _viewType;
      img.src = widget.url;
      img.style
        ..width = widget.width != null ? '${widget.width}px' : 'auto'
        ..height = widget.height != null ? '${widget.height}px' : 'auto'
        ..cursor = 'default'
        ..pointerEvents = 'none';
      // 不能用js的onclick，不然会穿透flutter的元素响应点击
      img.onLoad.listen((_) {
        if (!mounted) return;
        sizeNotifier.value = [
          img.naturalWidth.toDouble(),
          img.naturalHeight.toDouble(),
        ];
      });

      img.onError.listen((_) {
        if (!mounted) return;
        sizeNotifier.value = [24, 24];
      });

      return img;
    });
  }

  @override
  void dispose() {
    super.dispose();
    sizeNotifier.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb == false) {
      throw UnsupportedError('WebImage is only supported on web platform');
    }
    return ValueListenableBuilder<List<double?>>(
      valueListenable: sizeNotifier,
      builder: (context, size, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth;
            double w = widget.width ?? size[0] ?? 24;
            double h = widget.height ?? size[1] ?? 24;
            if (w > maxWidth) {
              h = maxWidth / w * h;
              w = maxWidth;
            }
            final img =
                web.document.getElementById(_viewType) as web.HTMLImageElement?;
            if (img != null) {
              img.style.width = '${w}px';
              img.style.height = '${h}px';
            }
            const block = SizedBox.expand();
            return SizedBox(
              width: w,
              height: h,
              child: Stack(
                // 放一个透明的手势层在上面，防止穿透
                children: [
                  HtmlElementView(
                    key: ValueKey(_viewType),
                    viewType: _viewType,
                  ),
                  Positioned.fill(
                    child: widget.allowClickToEnlarge
                        ? GestureDetector(
                            onTap: () => showImageOverlay(_viewType),
                            behavior: HitTestBehavior.translucent,
                            child: block,
                          )
                        : block,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
