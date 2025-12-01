import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

enum ShapeStyle { circle, roundedRectangle }

class ImageHelper {
  static const String baseUrl = "http://100.30.64.72/images/personal/";

  /// Reusable method to load stakeholder profile images
  static Widget stakeholderProfile({
    required String? imageName,
    double size = 40, // diameter or height of the widget
    BoxFit fit = BoxFit.cover,
    Color placeholderColor = const Color.fromRGBO(128, 128, 128, 0.2),
    Color errorColor = Colors.red,
    IconData errorIcon = Icons.error,
    IconData placeholderIcon = Icons.person,
    ShapeStyle shapeStyle = ShapeStyle.circle, // new parameter
    double borderRadius = 5, // used for rounded rectangle
    BoxBorder? border, // optional border
  }) {
    // Placeholder widget
    Widget noImagePlaceholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: shapeStyle == ShapeStyle.circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: shapeStyle == ShapeStyle.circle ? null : BorderRadius.circular(borderRadius),
        border: border,
        color: placeholderColor,
      ),
      child: Icon(
        placeholderIcon,
        size: size * 0.5,
        color: Colors.white,
      ),
    );

    // Error widget
    Widget errorWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: shapeStyle == ShapeStyle.circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: shapeStyle == ShapeStyle.circle ? null : BorderRadius.circular(borderRadius),
        border: border,
        color: errorColor,
      ),
      child: Icon(errorIcon, size: size * 0.5, color: Colors.white),
    );

    // If no image, return placeholder
    if (imageName == null || imageName.isEmpty) {
      return noImagePlaceholder;
    }

    // Load image with CachedNetworkImage
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: shapeStyle == ShapeStyle.circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: shapeStyle == ShapeStyle.circle ? null : BorderRadius.circular(borderRadius),
        border: border,
      ),
      clipBehavior: Clip.hardEdge,
      child: CachedNetworkImage(
        imageUrl: "$baseUrl$imageName",
        width: size,
        height: size,
        fit: fit,
        placeholder: (_, __) => Center(
          child: SizedBox(
            width: size * 0.4,
            height: size * 0.4,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
        errorWidget: (_, __, ___) => errorWidget,
      ),
    );
  }
}
