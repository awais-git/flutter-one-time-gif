import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('One-Time GIF')),
        body: const Center(
          child: OneTimeGif(
            gifAsset: 'assets/handshake.gif',
            frameCount: 10,
          ),
        ),
      ),
    );
  }
}

class OneTimeGif extends StatefulWidget {
  final String gifAsset;
  final int frameCount;

  const OneTimeGif({
    super.key,
    required this.gifAsset,
    required this.frameCount,
  });

  @override
  OneTimeGifState createState() => OneTimeGifState();
}

class OneTimeGifState extends State<OneTimeGif> with SingleTickerProviderStateMixin {
  late ImageProvider _imageProvider;
  ImageInfo? _lastFrame;
  bool _isAnimating = true;

  @override
  void initState() {
    super.initState();
    _imageProvider = AssetImage(widget.gifAsset);
    _loadGif();
  }

  void _loadGif() {
    final ImageStream stream = _imageProvider.resolve(const ImageConfiguration());
    ImageStreamListener? listener;

    listener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        if (_isAnimating) {
          setState(() {
            _lastFrame = info;
          });

          if (info.image.width > 0 && info.image.height > 0) {
            Future.delayed(
              const Duration(milliseconds: 100),
              () {
                Duration frameDuration = Duration(milliseconds: 100 * widget.frameCount);
                Future.delayed(
                  frameDuration,
                  () {
                    if (mounted && _isAnimating) {
                      setState(() {
                        _isAnimating = false;
                      });
                      stream.removeListener(listener!);
                    }
                  },
                );
              },
            );
          }
        }
      },
      onError: (exception, stackTrace) {
        debugPrint('Error loading GIF: $exception');
        stream.removeListener(listener!);
      },
    );

    stream.addListener(listener);
  }

  @override
  void dispose() {
    _lastFrame?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _lastFrame != null
        ? Image(
            image: _imageProvider,
            frameBuilder: _isAnimating
                ? null
                : (context, child, frame, wasSynchronouslyLoaded) {
                    return RawImage(
                      image: _lastFrame!.image,
                      width: _lastFrame!.image.width.toDouble(),
                      height: _lastFrame!.image.height.toDouble(),
                      scale: _lastFrame!.scale,
                    );
                  },
          )
        : const CircularProgressIndicator.adaptive();
  }
}
