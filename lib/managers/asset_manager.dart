import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vector_graphics/vector_graphics.dart';

import '../models/prompt.dart';

class AssetManager {
  AssetManager._();

  static final AssetManager _instance = AssetManager._();

  static AssetManager get instance => _instance;

  factory AssetManager() => _instance;

  static const AssetBytesLoader logoOutlineBlackLoader =
      AssetBytesLoader('assets/logo_outline_black_100x.svg.vec');
  static const AssetBytesLoader logoOutlineWhiteLoader =
      AssetBytesLoader('assets/logo_outline_white_100x.svg.vec');
  static const AssetBytesLoader logoFilledBlackLoader =
      AssetBytesLoader('assets/logo_filled_black_100x.svg.vec');
  static const AssetBytesLoader logoFilledWhiteLoader =
      AssetBytesLoader('assets/logo_filled_white_100x.svg.vec');

  late final PictureInfo logoOutlineBlackPicInfo;
  late final PictureInfo logoOutlineWhitePicInfo;
  late final PictureInfo logoFilledBlackPicInfo;
  late final PictureInfo logoFilledWhitePicInfo;

  Future<void> init() async {
    logoOutlineBlackPicInfo =
        await vg.loadPicture(logoOutlineBlackLoader, null);
    logoOutlineWhitePicInfo =
        await vg.loadPicture(logoOutlineWhiteLoader, null);
    logoFilledBlackPicInfo = await vg.loadPicture(logoFilledBlackLoader, null);
    logoFilledWhitePicInfo = await vg.loadPicture(logoFilledWhiteLoader, null);
  }

  static Widget getPromptIcon(Prompt prompt, {Color? color, double? size}) {
    switch (prompt.icon) {
      case 'analyze':
        return SvgPicture(
          const AssetBytesLoader('assets/prompts/analyze.svg.vec'),
          width: size,
          height: size,
          placeholderBuilder: (BuildContext context) =>
              const CircularProgressIndicator(),
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
