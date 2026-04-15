import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../controller/feedback_conroller.dart';

class FeedbackScreen extends StatefulWidget {
  final String productId;

  const FeedbackScreen({Key? key, required this.productId}) : super(key: key);

  @override
  FeedbackScreenState createState() => FeedbackScreenState();
}

class FeedbackScreenState extends State<FeedbackScreen> {
  final FeedbackController _controller = FeedbackController();

  List<dynamic> feedbacks = [];
  bool loading = true;
  bool refreshing = false;

  @override
  void initState() {
    super.initState();
    loadFeedbacks();
  }

  Future<void> loadFeedbacks({bool showLoader = true}) async {
    if (showLoader && mounted) setState(() => loading = true);

    try {
      final res = await _controller.fetchFeedbacks(widget.productId);
      if (!mounted) return;
      setState(() => feedbacks = res);
    } catch (e) {
      debugPrint('Feedback load error: $e');
      if (!mounted) return;
      setState(() => feedbacks = []);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _refresh() async {
    setState(() => refreshing = true);
    await loadFeedbacks(showLoader: false);
    if (mounted) setState(() => refreshing = false);
  }

  String _getName(dynamic item) {
    try {
      if (item is Map) {
        return item['userName'] ?? 'User';
      }
      return item.userName ?? 'User';
    } catch (_) {
      return 'User';
    }
  }

  String _getComment(dynamic item) {
    try {
      if (item is Map) {
        return item['description'] ?? '';
      }
      return item.description ?? '';
    } catch (_) {
      return '';
    }
  }

  double _getRating(dynamic item) {
    try {
      if (item is Map) return (item['rating'] as num).toDouble();
      return (item.rating as num).toDouble();
    } catch (_) {
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(
        child: LoadingAnimationWidget.fourRotatingDots(
          color: Colors.grey.shade600,
          size: 36,
        ),
      );
    }

    if (feedbacks.isEmpty) {
      return Center(
        child: Text(
          'No reviews yet',
          style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 14),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      color: Colors.black,
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 16, top: 8),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: feedbacks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = feedbacks[index];
          final name = _getName(item);
          final comment = _getComment(item);
          final rating = _getRating(item);

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade300,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          RatingBarIndicator(
                            rating: rating,
                            itemBuilder: (_, __) =>
                                const Icon(Icons.star, color: Colors.amber),
                            itemCount: 5,
                            itemSize: 16,
                          ),
                        ],
                      ),
                      if (comment.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          comment,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey.shade800,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
