import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vector_graphics/vector_graphics.dart';

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

  static Widget getPromptIcon(String icon, {Color? color, double? size}) {
    final String iconPath;
    switch (icon) {
      case 'analyze':
        iconPath = 'assets/prompts/analyze.svg.vec';
        break;
      case 'documentCode':
        iconPath = 'assets/prompts/document_code.svg.vec';
        break;
      case 'email':
        iconPath = 'assets/prompts/email.svg.vec';
        break;
      case 'general':
        iconPath = 'assets/prompts/general.svg.vec';
        break;
      case 'readMe':
        iconPath = 'assets/prompts/readme.svg.vec';
        break;
      case 'scientific':
        iconPath = 'assets/prompts/scientific.svg.vec';
        break;
      case 'twitter':
        iconPath = 'assets/prompts/twitter.svg.vec';
        break;
      case 'reddit':
        iconPath = 'assets/prompts/reddit.svg.vec';
        break;
      default:
        if (icon.startsWith('https://')) {
          return Image.network(icon, fit: BoxFit.fitWidth);
        }

        return const Icon(Icons.question_mark);
    }

    return Container(
      width: size ?? 24,
      height: size ?? 24,
      alignment: Alignment.center,
      child: SvgPicture(
        AssetBytesLoader(iconPath),
        width: size,
        height: size,
        placeholderBuilder: (BuildContext context) =>
            const CupertinoActivityIndicator(),
        colorFilter:
            color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
  }
}
