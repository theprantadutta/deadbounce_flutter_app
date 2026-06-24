/// Single source of truth for the legal documents shown on first launch.
///
/// **Bump [version] whenever `assets/legal/privacy.md` or
/// `assets/legal/terms.md` change in a way that requires fresh consent.**
/// The number here must match the `**Version N**` line at the top of BOTH
/// markdown files. When it increases, every user is asked to review and accept
/// again on the next launch (see [LegalConsentStore]).
abstract final class LegalDocuments {
  /// Current legal version. Privacy Policy and Terms always share one version.
  static const int version = 1;

  static const String privacyAsset = 'assets/legal/privacy.md';
  static const String termsAsset = 'assets/legal/terms.md';
}
