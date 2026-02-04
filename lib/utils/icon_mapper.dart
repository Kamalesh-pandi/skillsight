import 'package:flutter/material.dart';

class IconMapper {
  static IconData getIcon(int? code) {
    if (code == null) return Icons.work_outline;

    switch (code) {
      case 0xe1b1:
        return Icons.code;
      case 0xe5e1:
        return Icons.storage;
      case 0xe597:
        return Icons.phone_android;
      case 0xe362:
        return Icons.layers;
      case 0xf58c:
        return Icons.bar_chart;
      case 0xf543:
        return Icons.psychology;
      case 0xf833:
        return Icons.settings_input_component;
      case 0xf1a5:
        return Icons.all_inclusive;
      case 0xe18a:
        return Icons.cloud;
      case 0xe0e6:
        return Icons.brush;
      case 0xf603:
        return Icons.assignment_ind;
      case 0xe58b:
        return Icons.security;
      default:
        return Icons.work_outline;
    }
  }
}
