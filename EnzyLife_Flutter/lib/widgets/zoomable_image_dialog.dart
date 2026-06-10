import 'package:flutter/material.dart';

class FullscreenImagePage extends StatelessWidget {
  final String imageUrl;
  final bool isNetwork;

  const FullscreenImagePage({
    super.key,
    required this.imageUrl,
    this.isNetwork = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 5.0,
          clipBehavior: Clip.none,
          child: Hero(
            tag: imageUrl,
            child: isNetwork
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported, color: Colors.white54, size: 48),
                          SizedBox(height: 8),
                          Text('Gagal memuat gambar', style: TextStyle(color: Colors.white70)),
                        ],
                      );
                    },
                  )
                : Image.asset(
                    imageUrl,
                    fit: BoxFit.contain,
                  ),
          ),
        ),
      ),
    );
  }
}

// Helper function to easily open the zoom view
void openFullscreenImage(BuildContext context, String imageUrl, {bool isNetwork = false}) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black,
      pageBuilder: (context, _, __) => FullscreenImagePage(
        imageUrl: imageUrl,
        isNetwork: isNetwork,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}
