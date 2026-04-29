import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maac_example/models/news_article.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDetailContent extends StatelessWidget {
  final NewsArticle article;

  const NewsDetailContent({super.key, required this.article});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Hero(
              tag: 'news_image_${article.id}',
              child: Image.network(
                article.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.broken_image_outlined, size: 48),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(24.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text(
                DateFormat.yMMMMd().format(article.publishedAt),
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(article.title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, height: 1.2)),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              Text(
                article.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 48),
              FilledButton.icon(
                onPressed: () => _launchUrl(article.url),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Read Full Article'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ],
    );
  }
}
