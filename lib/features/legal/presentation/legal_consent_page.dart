import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../../core/legal/legal_consent_store.dart';
import '../../../core/legal/legal_documents.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/animated_arena_background.dart';
import 'widgets/markdown_view.dart';

/// First-launch legal gate: shows the Privacy Policy and Terms in two tabs and
/// blocks the rest of the app until the user accepts the current
/// [LegalDocuments.version]. Re-appears whenever that version is bumped.
///
/// Device-level and pre-auth — the router routes here before login when
/// [LegalConsentStore.hasAcceptedCurrent] is false. Accepting notifies the
/// store, which re-runs the router redirect and lets the user through.
class LegalConsentPage extends StatefulWidget {
  const LegalConsentPage({super.key, required this.consent});

  final LegalConsentStore consent;

  @override
  State<LegalConsentPage> createState() => _LegalConsentPageState();
}

class _LegalConsentPageState extends State<LegalConsentPage> {
  late final Future<List<String>> _docs = Future.wait([
    rootBundle.loadString(LegalDocuments.privacyAsset),
    rootBundle.loadString(LegalDocuments.termsAsset),
  ]);

  bool _accepting = false;

  Future<void> _accept() async {
    if (_accepting) return;
    setState(() => _accepting = true);
    // Persist + notify; the router's refreshListenable re-runs the redirect
    // and navigates past the gate (to splash → the normal boot flow).
    await widget.consent.accept();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.ink900,
      body: AnimatedArenaBackground(
        emberCount: 12,
        child: SafeArea(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('BEFORE YOU PLAY', style: textTheme.headlineSmall),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        'Please review and accept our Privacy Policy and Terms '
                        'to continue.',
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const TabBar(
                  labelColor: AppColors.amber300,
                  unselectedLabelColor: AppColors.ink300,
                  indicatorColor: AppColors.amber400,
                  tabs: [
                    Tab(text: 'PRIVACY POLICY'),
                    Tab(text: 'TERMS'),
                  ],
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.ink950.withValues(alpha: 0.82),
                      borderRadius: AppRadii.lgAll,
                      border: Border.all(color: AppColors.outlineFaint),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: FutureBuilder<List<String>>(
                      future: _docs,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Text(
                                'Could not load the legal documents. Please '
                                'restart the app and try again.',
                                textAlign: TextAlign.center,
                                style: textTheme.bodyMedium,
                              ),
                            ),
                          );
                        }
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.amber400,
                            ),
                          );
                        }
                        final docs = snapshot.data!;
                        return TabBarView(
                          children: [
                            MarkdownView(data: docs[0]),
                            MarkdownView(data: docs[1]),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _accepting ? null : _accept,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.amber500,
                            foregroundColor: AppColors.onAmber,
                            disabledBackgroundColor: AppColors.ink600,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadii.mdAll,
                            ),
                          ),
                          child: _accepting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.onAmber,
                                  ),
                                )
                              : Text(
                                  'AGREE & CONTINUE',
                                  style: textTheme.labelLarge
                                      ?.copyWith(color: AppColors.onAmber),
                                ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'By tapping Agree, you accept the Privacy Policy and '
                        'Terms (version ${LegalDocuments.version}).',
                        textAlign: TextAlign.center,
                        style: textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
