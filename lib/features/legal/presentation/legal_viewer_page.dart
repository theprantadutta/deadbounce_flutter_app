import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../../core/legal/legal_documents.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/meta_scaffold.dart';
import 'widgets/markdown_view.dart';

/// Read-only view of the Privacy Policy and Terms, reachable any time from
/// Settings → About. Same two-tab layout as the first-launch gate, but with
/// the standard meta chrome (back button) and no Agree button.
class LegalViewerPage extends StatefulWidget {
  const LegalViewerPage({super.key, this.initialTab = 0});

  /// 0 = Privacy Policy, 1 = Terms.
  final int initialTab;

  @override
  State<LegalViewerPage> createState() => _LegalViewerPageState();
}

class _LegalViewerPageState extends State<LegalViewerPage> {
  late final Future<List<String>> _docs = Future.wait([
    rootBundle.loadString(LegalDocuments.privacyAsset),
    rootBundle.loadString(LegalDocuments.termsAsset),
  ]);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTab.clamp(0, 1),
      child: MetaScaffold(
        title: 'LEGAL',
        bottom: const TabBar(
          labelColor: AppColors.amber300,
          unselectedLabelColor: AppColors.ink300,
          indicatorColor: AppColors.amber400,
          tabs: [
            Tab(text: 'PRIVACY POLICY'),
            Tab(text: 'TERMS'),
          ],
        ),
        child: FutureBuilder<List<String>>(
          future: _docs,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Could not load the legal documents.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.amber400),
              );
            }
            final docs = snapshot.data!;
            const padding = EdgeInsets.symmetric(vertical: AppSpacing.lg);
            return TabBarView(
              children: [
                MarkdownView(data: docs[0], padding: padding),
                MarkdownView(data: docs[1], padding: padding),
              ],
            );
          },
        ),
      ),
    );
  }
}
