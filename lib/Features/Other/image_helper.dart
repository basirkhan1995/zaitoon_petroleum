import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageHelper {
  // Set your base URL here
  static const String baseUrl = "http://100.30.64.72/images/personal/";

  /// Reusable method to load stakeholder profile images
  static Widget stakeholderProfile({
    required String? imageName,
    double size = 40, // diameter of the circular avatar
    BoxFit fit = BoxFit.cover,
    Color placeholderColor = const Color.fromRGBO(128, 128, 128, 0.3), // grey with opacity
    IconData placeholderIcon = Icons.person, // icon for placeholder
    Color errorColor = Colors.red, // color for error widget
    IconData errorIcon = Icons.error, // icon for error widget
  }) {
    // Build placeholder and error widget with the same size
    Widget defaultPlaceholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: placeholderColor, // now supports opacity
      ),
      child: Icon(placeholderIcon, size: size * 0.5, color: Colors.white),
    );

    Widget defaultError = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: errorColor,
      ),
      child: Icon(errorIcon, size: size * 0.5, color: Colors.white),
    );

    // If no imageName provided, show placeholder
    if (imageName == null || imageName.isEmpty) {
      return defaultPlaceholder;
    }

    // Load image with CachedNetworkImage
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: CachedNetworkImage(
        imageUrl: "$baseUrl$imageName",
        width: size,
        height: size,
        fit: fit,
        placeholder: (_, __) => defaultPlaceholder,
        errorWidget: (_, __, ___) => defaultError,
      ),
    );
  }
}
