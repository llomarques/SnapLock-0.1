import 'package:flutter/material.dart';
import 'package:snaplock/models/post_model.dart';

class DumpPhotoCarousel extends StatefulWidget {
  const DumpPhotoCarousel(
      {super.key, required this.title, required this.photos});

  final String title;
  final List<PostModel> photos;

  @override
  State<DumpPhotoCarousel> createState() => _DumpPhotoCarouselState();
}

class _DumpPhotoCarouselState extends State<DumpPhotoCarousel> {
  final _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _moveTo(int page) {
    if (page < 0 || page >= widget.photos.length) return;
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.photos[_currentPage];

    return Dialog.fullscreen(
      backgroundColor: const Color(0xFFF3E9DC),
      child: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.photos.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final url = widget.photos[index].imageUrl;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 72, 16, 110),
                  child: InteractiveViewer(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          color: Color(0xFFEADBCB),
                        ),
                        child: Image.network(
                          url,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: Color(0xFF895737),
                              size: 64,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            if (widget.photos.length > 1) ...[
              Positioned(
                left: 4,
                top: 0,
                bottom: 72,
                child: Center(
                  child: Opacity(
                    opacity: _currentPage > 0 ? 1 : 0.35,
                    child: IconButton.filledTonal(
                      onPressed: _currentPage > 0
                          ? () => _moveTo(_currentPage - 1)
                          : null,
                      style: IconButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFF3E9DC).withValues(alpha: 0.92),
                        foregroundColor: const Color(0xFF895737),
                      ),
                      icon: const Icon(Icons.chevron_left_rounded, size: 32),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 4,
                top: 0,
                bottom: 72,
                child: Center(
                  child: Opacity(
                    opacity: _currentPage < widget.photos.length - 1 ? 1 : 0.35,
                    child: IconButton.filledTonal(
                      onPressed: _currentPage < widget.photos.length - 1
                          ? () => _moveTo(_currentPage + 1)
                          : null,
                      style: IconButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFF3E9DC).withValues(alpha: 0.92),
                        foregroundColor: const Color(0xFF895737),
                      ),
                      icon: const Icon(Icons.chevron_right_rounded, size: 32),
                    ),
                  ),
                ),
              ),
            ],
            Positioned(
              top: 0,
              left: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E9DC).withValues(alpha: 0.96),
                  border: const Border(
                    bottom: BorderSide(color: Color(0xFFD7CBBD)),
                  ),
                ),
                child: Row(children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Color(0xFF895737)),
                  ),
                  const Spacer(),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Color(0xFF895737),
                      fontFamily: 'serif',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 48),
                ]),
              ),
            ),
            Positioned(
              bottom: 28,
              left: 16,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (photo.caption.isNotEmpty)
                    Text(
                      photo.caption,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF895737),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.photos.length,
                      (index) => Container(
                        width: _currentPage == index ? 18 : 7,
                        height: 7,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? const Color(0xFF895737)
                              : const Color(0xFFD7CBBD),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
