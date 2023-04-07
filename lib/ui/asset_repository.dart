import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vector_graphics/vector_graphics.dart';

import '../models/prompt.dart';

class AssetRepository {
  static Widget getPromptIcon(Prompt prompt, {Color? color, double? size}) {
    switch (prompt.icon) {
      case 'analyze':
        return SvgPicture(
          const AssetBytesLoader('assets/prompts/analyze.svg.vec'),
          width: size,
          height: size,
          placeholderBuilder: (BuildContext context) => const CircularProgressIndicator(),
          colorFilter:
              color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
        );
      case 'documentCode':
        return SvgPicture(
          const AssetBytesLoader('assets/prompts/document_code.svg.vec'),
          width: size,
          height: size,
          colorFilter:
              color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
        );
      case 'email':
        return SvgPicture(
          const AssetBytesLoader('assets/prompts/email.svg.vec'),
          width: size,
          height: size,
          colorFilter:
              color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
        );
      case 'general':
        return SvgPicture(
          const AssetBytesLoader('assets/prompts/general.svg.vec'),
          width: size,
          height: size,
          colorFilter:
              color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
        );
      case 'readMe':
        return SvgPicture(
          const AssetBytesLoader('assets/prompts/readme.svg.vec'),
          width: size,
          height: size,
          colorFilter:
              color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
        );
      case 'scientific':
        return SvgPicture(
          const AssetBytesLoader('assets/prompts/scientific.svg.vec'),
          width: size,
          height: size,
          colorFilter:
              color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
        );
      default:
        return ImageIcon(NetworkImage(prompt.icon), color: color);
    }
  }
}
