/// Single source of truth for the legal documents shown on first launch.
///
/// **Bump [version] whenever `assets/legal/privacy.md`, `assets/legal/terms.md`,
/// or `assets/legal/refund.md` change in a way that requires fresh consent.**
/// The number here must match the `**Version N**` line at the top of ALL THREE
/// markdown files. When it increases, every user is asked to review and accept
/// again on the next launch (see [LegalConsentStore]).
abstract final class LegalDocuments {
  /// Current legal version. Privacy Policy, Terms, and Refund Policy always
  /// share one version — bumping it re-prompts consent for all three together.
  static const int version = 2;

  static const String privacyAsset = 'assets/legal/privacy.md';
  static const String termsAsset = 'assets/legal/terms.md';
  static const String refundAsset = 'assets/legal/refund.md';
}
