import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

Future<Uint8List?> showImageCropper({
  required BuildContext context,
  required Uint8List imageBytes,
}) async {
  return await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      child: SizedBox(
        width: 750,
        height: 600,
        child: CustomCropper(imageBytes: imageBytes),
      ),
    ),
  );
}

class CustomCropper extends StatefulWidget {
  final Uint8List imageBytes;
  const CustomCropper({super.key, required this.imageBytes});

  @override
  State<CustomCropper> createState() => _CustomCropperState();
}

class _CustomCropperState extends State<CustomCropper> {
  ui.Image? decoded;
  Rect crop = Rect.fromLTWH(150, 150, 250, 250);

  bool dragging = false;
  bool resizing = false;
  late Offset dragStart;
  late Rect cropStart;
  late ResizeHandle activeHandle;

  static const double handleSize = 14;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  Future<void> _decode() async {
    final img = await decodeImageFromList(widget.imageBytes);
    setState(() => decoded = img);
  }

  @override
  Widget build(BuildContext context) {
    if (decoded == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: (_) => { dragging = false, resizing = false },
            child: Stack(
              children: [
                Center(child: RawImage(image: decoded)),
                Positioned(
                  left: crop.left,
                  top: crop.top,
                  child: Container(
                    width: crop.width,
                    height: crop.height,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent, width: 2),
                      color: Colors.blue.withValues(alpha: .1),
                    ),
                  ),
                ),

                /// Corner Resize Handles
                ..._buildHandles(),
              ],
            ),
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text("Cancel"),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () async {
                final result = await _crop();
                if (mounted) Navigator.pop(context, result);
              },
              child: const Text("Crop"),
            ),
            const SizedBox(width: 20),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // CROP LOGIC
  // ─────────────────────────────────────────────

  Future<Uint8List> _crop() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawImageRect(
      decoded!,
      crop,
      Rect.fromLTWH(0, 0, crop.width, crop.height),
      Paint(),
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(
      crop.width.toInt(),
      crop.height.toInt(),
    );

    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  // ─────────────────────────────────────────────
  // HANDLE BUILDER
  // ─────────────────────────────────────────────
  List<Widget> _buildHandles() {
    return ResizeHandle.values.map((handle) {
      final pos = _getHandlePosition(handle);
      return Positioned(
        left: pos.dx - handleSize / 2,
        top: pos.dy - handleSize / 2,
        child: MouseRegion(
          cursor: SystemMouseCursors.resizeUpLeftDownRight,
          child: GestureDetector(
            onPanStart: (details) {
              resizing = true;
              activeHandle = handle;
              dragStart = details.localPosition;
              cropStart = crop;
            },
            onPanUpdate: _handleResize,
            child: Container(
              width: handleSize,
              height: handleSize,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.blueAccent),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Offset _getHandlePosition(ResizeHandle handle) {
    switch (handle) {
      case ResizeHandle.topLeft:
        return Offset(crop.left, crop.top);
      case ResizeHandle.topRight:
        return Offset(crop.right, crop.top);
      case ResizeHandle.bottomLeft:
        return Offset(crop.left, crop.bottom);
      case ResizeHandle.bottomRight:
        return Offset(crop.right, crop.bottom);
    }
  }

  // ─────────────────────────────────────────────
  // DRAG & RESIZE LOGIC
  // ─────────────────────────────────────────────

  void _onPanStart(DragStartDetails d) {
    dragStart = d.localPosition;

    if (crop.contains(d.localPosition)) {
      dragging = true;
      cropStart = crop;
    }
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (dragging && !resizing) {
      final delta = d.localPosition - dragStart;
      setState(() {
        crop = cropStart.shift(delta);
      });
    }
  }

  void _handleResize(DragUpdateDetails d) {
    final delta = d.localPosition - dragStart;

    double left = cropStart.left;
    double top = cropStart.top;
    double right = cropStart.right;
    double bottom = cropStart.bottom;

    switch (activeHandle) {
      case ResizeHandle.topLeft:
        left += delta.dx;
        top += delta.dy;
        break;
      case ResizeHandle.topRight:
        right += delta.dx;
        top += delta.dy;
        break;
      case ResizeHandle.bottomLeft:
        left += delta.dx;
        bottom += delta.dy;
        break;
      case ResizeHandle.bottomRight:
        right += delta.dx;
        bottom += delta.dy;
        break;
    }

    setState(() {
      crop = Rect.fromLTRB(left, top, right, bottom);
    });
  }
}

enum ResizeHandle { topLeft, topRight, bottomLeft, bottomRight }
