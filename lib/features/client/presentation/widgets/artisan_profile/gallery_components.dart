import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../../core/theme/design_tokens.dart';

/// Gallery image tile — shows a network image with a fallback placeholder.
class GalleryTile extends StatelessWidget {
  const GalleryTile({super.key, required this.imageUrl, this.overflowCount});
  final String imageUrl;
  final int? overflowCount; // if non-null, renders a "+N" overlay
 
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: DesignTokens.warmTint,
              child: const Icon(
                PhosphorIcons.image,
                color: DesignTokens.warmBorder,
                size: 28,
              ),
            ),
          ),
          if (overflowCount != null)
            Container(
              color: Colors.black54,
              alignment: Alignment.center,
              child: Text(
                '+$overflowCount',
                style: const TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
 
/// Full-screen gallery viewer
class GalleryViewerScreen extends StatefulWidget {
  const GalleryViewerScreen({
    super.key,
    required this.urls,
    required this.initialIndex,
  });
 
  final List<String> urls;
  final int initialIndex;
 
  @override
  State<GalleryViewerScreen> createState() => _GalleryViewerScreenState();
}
 
class _GalleryViewerScreenState extends State<GalleryViewerScreen> {
  late final PageController _pageCtrl;
  late int _current;
 
  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageCtrl = PageController(initialPage: widget.initialIndex);
  }
 
  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_current + 1} / ${widget.urls.length}',
          style: const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageCtrl,
        itemCount: widget.urls.length,
        onPageChanged: (int i) => setState(() => _current = i),
        itemBuilder: (BuildContext context, int i) {
          return InteractiveViewer(
            child: Center(
              child: Image.network(
                widget.urls[i],
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  PhosphorIcons.imageBroken,
                  color: Colors.white54,
                  size: 48,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
