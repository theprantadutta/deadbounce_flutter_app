import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/util/open_external_link.dart';
import '../../../core/widgets/db_button.dart';
import '../../../core/widgets/meta_scaffold.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../domain/repositories/store_repository.dart';
import '../domain/store_catalog.dart';
import 'cubit/store_cubit.dart';

/// The real-money store.
class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StoreCubit(context.sessionDependencies.storeRepository)..load(),
      child: const _StoreView(),
    );
  }
}

class _StoreView extends StatelessWidget {
  const _StoreView();

  /// Guests may browse but not buy.
  ///
  /// A guest account lives and dies with the install, so a purchase made on one
  /// is unrecoverable — that is a refund and a one-star review, not a sale. We
  /// send them to link first rather than take their money.
  bool _isGuest(BuildContext context) {
    final auth = context.watch<AuthCubit>().state;
    return auth is AuthAuthenticated && auth.user.isAnonymous;
  }

  Future<void> _buy(BuildContext context, StoreProduct product) async {
    final messenger = ScaffoldMessenger.of(context);
    final outcome = await context.read<StoreCubit>().buy(product);

    final String? message = switch (outcome) {
      PurchaseSucceeded(:final coinsGranted) => coinsGranted > 0
          ? 'Purchase complete — $coinsGranted coins added.'
          : 'Purchase complete. Much obliged, partner.',
      // Dismissing the Play sheet is not an event worth narrating.
      PurchaseCancelled() => null,
      PurchasePending() =>
        'Your purchase is awaiting approval. It will unlock once it clears.',
      PurchaseFailed(:final message) => message,
    };

    if (message == null) return;
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ));
  }

  Future<void> _restore(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final error = await context.read<StoreCubit>().restore();
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(error ?? 'Purchases restored.'),
        behavior: SnackBarBehavior.floating,
      ));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isGuest = _isGuest(context);

    return MetaScaffold(
      title: 'SUPPLY RUN',
      child: BlocBuilder<StoreCubit, StoreState>(
        builder: (context, state) {
          return switch (state) {
            StoreLoading() => const Center(child: CircularProgressIndicator()),
            StoreUnavailable(:final message) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge,
                  ),
                ),
              ),
            StoreReady() => ListView(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                children: [
                  if (isGuest) const _GuestNotice(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                    child: Text(
                      'Everything here is optional. Every coin in the game can '
                      'still be earned by playing.',
                      style: textTheme.bodySmall
                          ?.copyWith(color: AppColors.ink200),
                    ),
                  ),
                  for (final offer in state.offers)
                    _OfferTile(
                      offer: offer,
                      owned: state.ownsProduct(offer.product),
                      expiresAt: state.expiryFor(offer.product),
                      busy: state.busyProductId == offer.product.id,
                      // Any purchase in flight locks the whole shelf.
                      enabled: state.busyProductId == null && !isGuest,
                      onBuy: () => _buy(context, offer.product),
                      onManage: () => openExternalLink(
                        context,
                        StoreCatalog.manageUrlFor(offer.product),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: DbSecondaryButton(
                      label: 'RESTORE PURCHASES',
                      icon: Icons.restore,
                      onPressed: () => _restore(context),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
          };
        },
      ),
    );
  }
}

class _GuestNotice extends StatelessWidget {
  const _GuestNotice();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.ink700,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.amber500),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, color: AppColors.amber300, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Secure your account first — link it in Profile so anything you '
              'buy survives a reinstall.',
              style: textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferTile extends StatelessWidget {
  const _OfferTile({
    required this.offer,
    required this.owned,
    required this.expiresAt,
    required this.busy,
    required this.enabled,
    required this.onBuy,
    required this.onManage,
  });

  final StoreOffer offer;
  final bool owned;

  /// Set only for an owned subscription.
  final DateTime? expiresAt;
  final bool busy;
  final bool enabled;
  final VoidCallback onBuy;
  final VoidCallback onManage;

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String _formatDate(DateTime utc) {
    final d = utc.toLocal();
    return '${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final product = offer.product;
    final highlight = product.highlight && !owned;

    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.ink800,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: highlight ? AppColors.amber500 : AppColors.ink500,
          width: highlight ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(product.title, style: textTheme.titleMedium),
              ),
              if (product.badge != null && !owned)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.amber500,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Text(
                    product.badge!,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.ink950,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            product.blurb,
            style: textTheme.bodySmall?.copyWith(color: AppColors.ink200),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  // An active subscription shows its window instead of a
                  // price — "what am I paying for" beats "what did it cost".
                  expiresAt != null
                      ? 'Active until ${_formatDate(expiresAt!)}'
                      // Play's localised price string, verbatim.
                      : (offer.available ? offer.price : 'Unavailable'),
                  style: textTheme.titleSmall
                      ?.copyWith(color: AppColors.amber300),
                ),
              ),
              if (owned && expiresAt != null)
                // An active subscription: Play policy wants an unobstructed
                // route to cancel, so the manage link IS the affordance here.
                DbSecondaryButton(
                  label: 'MANAGE',
                  icon: Icons.open_in_new,
                  onPressed: onManage,
                )
              else if (owned)
                Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppColors.success, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'OWNED',
                      style: textTheme.labelMedium
                          ?.copyWith(color: AppColors.success),
                    ),
                  ],
                )
              else
                DbSecondaryButton(
                  label: 'BUY',
                  loading: busy,
                  onPressed: (enabled && offer.available) ? onBuy : null,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
