import 'dart:developer' as dev;

import 'package:app_core/app_core.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class AppCacheImageNetwork extends StatefulWidget {
  const AppCacheImageNetwork(
    this.imageUrl, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorImage,
    this.maxWidthDiskCache,
    this.maxHeightDiskCache,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? errorImage;
  final int? maxWidthDiskCache;
  final int? maxHeightDiskCache;

  @override
  State<AppCacheImageNetwork> createState() => _AppCacheImageNetworkState();
}

class _AppCacheImageNetworkState extends State<AppCacheImageNetwork> {
  late ValueNotifier<String> _notifier;
  late String imageUrl;
  int countLoadImg = 0;
  @override
  void initState() {
    super.initState();
    imageUrl = widget.imageUrl;
    _notifier = ValueNotifier(getAWSS3BaseImageUrl(imageUrl));
  }

  @override
  void didUpdateWidget(covariant AppCacheImageNetwork oldWidget) {
    if (widget.imageUrl != imageUrl) {
      imageUrl = widget.imageUrl;
      countLoadImg = 0;
      _notifier = ValueNotifier(getAWSS3BaseImageUrl(imageUrl));
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: _notifier,
        builder: (context, value, child) {
          return CachedNetworkImage(
            cacheKey: _notifier.value,
            imageUrl: imageUrl,
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: widget.fit,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.colorBurn,
                  ),
                ),
              ),
            ),
            placeholder: (context, url) => url.isNotEmpty
                ? Container(
                    height: widget.height,
                    width: widget.width,
                    color: AppColors.white900,
                    child: Shimmer.fromColors(
                      child: Skelton(
                        height: widget.height,
                        width: widget.width,
                      ),
                    ),
                  )
                : SizedBox(
                    height: widget.height,
                    width: widget.width,
                    child: widget.errorImage ??
                        const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: AppColors.coolGray500,
                          ),
                        ),
                  ),
            errorListener: (e) async {
              await DefaultCacheManager().removeFile(_notifier.value);
              dev.log('Cached Image $imageUrl Fail$e');
            },
            errorWidget: (context, url, error) {
              if (countLoadImg < 5 && url.isNotEmpty) {
                Future.delayed(const Duration(milliseconds: 50), () async {
                  countLoadImg++;
                  await DefaultCacheManager().removeFile(_notifier.value);
                  _notifier.value = _notifier.value +
                      DateTime.now().millisecondsSinceEpoch.toString();
                  await DefaultCacheManager()
                      .downloadFile(imageUrl, key: _notifier.value);
                });
                return Container(
                  height: widget.height,
                  width: widget.width,
                  color: AppColors.white900,
                  child: Shimmer.fromColors(
                    child: Skelton(
                      height: widget.height,
                      width: widget.width,
                    ),
                  ),
                );
              } else {
                return SizedBox(
                  height: widget.height,
                  width: widget.width,
                  child: widget.errorImage ??
                      const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: AppColors.coolGray500,
                        ),
                      ),
                );
              }
            },
            width: widget.width,
            height: widget.height,
            maxWidthDiskCache: widget.maxWidthDiskCache ?? 640,
            maxHeightDiskCache: widget.maxHeightDiskCache ?? 960,
            fit: widget.fit,
            filterQuality: FilterQuality.medium,
            fadeInDuration: const Duration(milliseconds: 0),
            fadeOutDuration: const Duration(milliseconds: 0),
          );
        });
  }
}

String getAWSS3BaseImageUrl(String fullUrl) {
  RegExp regExp = RegExp(r'(^[^?]+)');
  Match? match = regExp.firstMatch(fullUrl);
  return match?.group(1) ?? '';
}
