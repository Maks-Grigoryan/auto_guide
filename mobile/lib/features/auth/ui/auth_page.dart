import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/auth/auth_models.dart';
import '../../../core/widgets/language_picker.dart';
import '../../../core/widgets/segmented_toggle.dart';
import '../../../l10n/l10n.dart';

const _surface = Color(0xFF1C1F26);
const _card = Color(0xFF2A2D36);
const _accent = Color(0xFFF5A623);
const _outline = Color(0xFF3D4050);
const _textPrimary = Color(0xFFFFFFFF);
const _textSecondary = Color(0xFFE0E0E0);
const _error = Color(0xFFE53935);

/// Minimum tap target and field height used across the app (UI-SPEC, ACC).
const double _controlHeight = 56;

/// Sign-in and registration — the first screen of a signed-out session, shown
/// before any other screen.
///
/// Registration creates ordinary accounts only. There is no admin option here,
/// and adding one would not work: the server assigns the role, and the only
/// thing that can make an admin is `npm run admin:create`.
class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  /// 0 = sign in, 1 = register.
  int _tab = 0;
  bool _busy = false;
  AuthFailure? _failure;
  String? _localError;
  String? _notice;

  /// Set once a code has been sent: the identifier it went to. While this is
  /// non-null the page shows the code step instead of the forms, because the
  /// account does not exist until the code comes back.
  String? _awaitingCodeFor;

  final _identifier = TextEditingController();
  final _signInPassword = TextEditingController();
  final _signUpIdentifier = TextEditingController();
  final _signUpPassword = TextEditingController();
  final _repeatPassword = TextEditingController();
  final _code = TextEditingController();

  @override
  void dispose() {
    _identifier.dispose();
    _signInPassword.dispose();
    _signUpIdentifier.dispose();
    _signUpPassword.dispose();
    _repeatPassword.dispose();
    _code.dispose();
    super.dispose();
  }

  void _switchTab(int tab) {
    if (_busy || tab == _tab) return;
    setState(() {
      _tab = tab;
      // An error from the other form describes fields that are no longer on
      // screen, so it would read as a complaint about untouched inputs.
      _clearMessages();
    });
  }

  void _clearMessages() {
    _failure = null;
    _localError = null;
    _notice = null;
  }

  /// Leaves the code step and returns to the registration form.
  void _changeContact() {
    if (_busy) return;
    setState(() {
      _awaitingCodeFor = null;
      _code.clear();
      _clearMessages();
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final l10n = context.l10n;

    final validationError = _awaitingCodeFor != null
        ? _validateCode(l10n)
        : _tab == 0
            ? _validateSignIn(l10n)
            : _validateSignUp(l10n);
    if (validationError != null) {
      setState(() {
        _localError = validationError;
        _failure = null;
        _notice = null;
      });
      return;
    }

    setState(() {
      _busy = true;
      _clearMessages();
    });

    try {
      final controller = ref.read(authControllerProvider.notifier);

      if (_awaitingCodeFor != null) {
        await controller.confirmCode(
          identifier: _signUpIdentifier.text.trim(),
          code: _code.text.trim(),
        );
      } else if (_tab == 0) {
        await controller.signIn(
          identifier: _identifier.text.trim(),
          password: _signInPassword.text,
        );
      } else {
        // Registration stops here: the server sends a code and creates
        // nothing. The page swaps to the code step and stays put.
        final sentTo = await controller.startRegistration(
          identifier: _signUpIdentifier.text.trim(),
          password: _signUpPassword.text,
        );
        if (!mounted) return;
        setState(() => _awaitingCodeFor = sentTo);
        return;
      }

      if (!mounted) return;
      // Straight to the root; the router's redirect decides whether that means
      // the car selector or the home screen.
      context.go('/');
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() => _failure = error.failure);
    } catch (_) {
      if (!mounted) return;
      setState(() => _failure = AuthFailure.unknown);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String? _validateSignIn(AppLocalizations l10n) {
    if (_identifier.text.trim().isEmpty) return l10n.authIdentifierRequired;
    if (_signInPassword.text.isEmpty) return l10n.authPasswordRequired;
    return null;
  }

  String? _validateSignUp(AppLocalizations l10n) {
    final identifier = _signUpIdentifier.text.trim();
    if (identifier.isEmpty) return l10n.authIdentifierRequired;
    // Shape is checked here only to save a round trip on an obvious mistake;
    // the server decides for real, and this rule stays deliberately looser
    // than its so the two can never disagree about a valid address.
    if (!identifier.contains('@') &&
        identifier.replaceAll(RegExp(r'\D'), '').length < 6) {
      return l10n.authIdentifierInvalid;
    }
    if (_signUpPassword.text.length < 8) return l10n.authPasswordTooShort;
    if (_signUpPassword.text != _repeatPassword.text) {
      return l10n.authPasswordsDoNotMatch;
    }
    return null;
  }

  String? _validateCode(AppLocalizations l10n) {
    final code = _code.text.trim();
    if (code.length != 6 || int.tryParse(code) == null) {
      return l10n.authCodeRequired;
    }
    return null;
  }

  /// Asks for a fresh code. The server replaces the previous one, so an old
  /// message arriving late cannot be used afterwards.
  Future<void> _resendCode() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _clearMessages();
    });

    try {
      await ref.read(authControllerProvider.notifier).startRegistration(
            identifier: _signUpIdentifier.text.trim(),
            password: _signUpPassword.text,
          );
      if (!mounted) return;
      setState(() {
        _code.clear();
        _notice = context.l10n.authCodeResent;
      });
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() => _failure = error.failure);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _failureText(AppLocalizations l10n, AuthFailure failure) {
    switch (failure) {
      case AuthFailure.invalidCredentials:
        return l10n.authInvalidCredentials;
      case AuthFailure.invalidIdentifier:
        return l10n.authIdentifierInvalid;
      case AuthFailure.invalidCode:
        return l10n.authCodeInvalid;
      case AuthFailure.codeExpired:
        return l10n.authCodeExpired;
      case AuthFailure.accountExists:
        return l10n.authAccountExists;
      case AuthFailure.tooManyAttempts:
        return l10n.authTooManyAttempts;
      case AuthFailure.network:
        return l10n.authNetworkError;
      case AuthFailure.unknown:
        return l10n.authUnknownError;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final message =
        _localError ?? (_failure == null ? null : _failureText(l10n, _failure!));

    return Scaffold(
      backgroundColor: _surface,
      // The form grows taller than the viewport on short screens once the
      // keyboard is up; resizing lets the scroll view reach the button.
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _Backdrop(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.authTitle,
                          style: const TextStyle(
                            color: _textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            height: 1.15,
                          ),
                        ),
                      ),
                      // On this screen and nowhere earlier: someone who cannot
                      // read the interface has no way past sign-in, so the
                      // language has to be changeable before an account exists.
                      const LanguageButton(color: _textSecondary),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _awaitingCodeFor == null
                        ? l10n.authSubtitle
                        : l10n.authCodeSentTo(_awaitingCodeFor!),
                    style: const TextStyle(
                      color: _textSecondary,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // The tabs are hidden during confirmation: switching to
                  // «Вход» mid-way would silently drop a registration that has
                  // already sent someone a message.
                  if (_awaitingCodeFor == null) ...[
                    SegmentedToggle(
                      selectedIndex: _tab,
                      enabled: !_busy,
                      height: _controlHeight,
                      segments: [
                        SegmentedToggleItem(label: l10n.authSignInTab),
                        SegmentedToggleItem(label: l10n.authSignUpTab),
                      ],
                      onSelected: _switchTab,
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (message != null) ...[
                    _ErrorBanner(text: message),
                    const SizedBox(height: 16),
                  ],
                  if (_notice != null) ...[
                    _NoticeBanner(text: _notice!),
                    const SizedBox(height: 16),
                  ],
                  if (_awaitingCodeFor != null)
                    ..._codeFields(l10n)
                  else if (_tab == 0)
                    ..._signInFields(l10n)
                  else
                    ..._signUpFields(l10n),
                  const SizedBox(height: 24),
                  _SubmitButton(
                    label: _awaitingCodeFor != null
                        ? l10n.authConfirmButton
                        : _tab == 0
                            ? l10n.authSignInButton
                            : l10n.authSignUpButton,
                    busy: _busy,
                    onPressed: _submit,
                  ),
                  if (_awaitingCodeFor != null) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _busy ? null : _resendCode,
                      child: Text(
                        l10n.authResendCode,
                        style: const TextStyle(color: _accent, fontSize: 16),
                      ),
                    ),
                    TextButton(
                      onPressed: _busy ? null : _changeContact,
                      child: Text(
                        l10n.authChangeContact,
                        style: const TextStyle(
                          color: _textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _codeFields(AppLocalizations l10n) => [
        _Field(
          controller: _code,
          label: l10n.authCodeLabel,
          icon: Icons.pin_outlined,
          enabled: !_busy,
          keyboardType: TextInputType.number,
          // The one place a numeric keypad is right: this field takes six
          // digits and nothing else.
          autofillHints: const [AutofillHints.oneTimeCode],
          onSubmitted: (_) => _submit(),
        ),
      ];

  List<Widget> _signInFields(AppLocalizations l10n) => [
        _Field(
          controller: _identifier,
          label: l10n.authIdentifierLabel,
          icon: Icons.person_outline,
          enabled: !_busy,
          // One field for both identifiers, so the keyboard cannot commit to
          // digits or to letters; the plain keyboard types either.
          keyboardType: TextInputType.text,
          autofillHints: const [AutofillHints.username],
        ),
        const SizedBox(height: 14),
        _Field(
          controller: _signInPassword,
          label: l10n.authPasswordLabel,
          icon: Icons.lock_outline,
          enabled: !_busy,
          obscure: true,
          autofillHints: const [AutofillHints.password],
          onSubmitted: (_) => _submit(),
        ),
      ];

  List<Widget> _signUpFields(AppLocalizations l10n) => [
        // One field, not an email box beside a phone box. Two boxes read as a
        // request for both, and someone who has only one of them is left
        // guessing whether an empty field will be accepted.
        _Field(
          controller: _signUpIdentifier,
          label: l10n.authIdentifierLabel,
          icon: Icons.person_outline,
          enabled: !_busy,
          // Plain keyboard: the field takes digits or letters, so committing to
          // either would be wrong half the time.
          keyboardType: TextInputType.text,
          autofillHints: const [AutofillHints.username],
        ),
        const SizedBox(height: 14),
        _Field(
          controller: _signUpPassword,
          label: l10n.authPasswordLabel,
          icon: Icons.lock_outline,
          enabled: !_busy,
          obscure: true,
          autofillHints: const [AutofillHints.newPassword],
        ),
        const SizedBox(height: 14),
        _Field(
          controller: _repeatPassword,
          label: l10n.authPasswordRepeatLabel,
          icon: Icons.lock_outline,
          enabled: !_busy,
          obscure: true,
          onSubmitted: (_) => _submit(),
        ),
      ];
}

/// Backdrop under a scrim.
///
/// A black car under the strip lights of a dark parking garage — photographic,
/// low-key, and in the app's own palette without being tinted into it. The
/// plate is padded upward onto the surface colour rather than cropped to the
/// screen shape, so the car keeps its full width on a phone and the form still
/// gets quiet space above the subject.
///
/// Photo: Ville Kaisla, unsplash.com/photos/parked-black-car-HNCSCpWrVJA,
/// Unsplash License (free use, commercial included, no attribution required —
/// credited here anyway so the source of the asset stays traceable).
///
/// The scrim is not decoration: the ceiling lights are the one bright thing in
/// the frame, and white text over them would otherwise fall under the 4.5:1
/// contrast this app is held to.
class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/auth_background.jpg',
          fit: BoxFit.cover,
          // The asset is cropped so the car already sits in its lower third —
          // behind the form the scrim has to be heavy, and anything under it
          // ends up an indistinct smudge. Anchoring the bottom keeps the car
          // in the clear space below the button on any screen height.
          alignment: Alignment.bottomCenter,
          // A missing asset must not black out the whole screen — fall back to
          // the app's own background and carry on.
          errorBuilder: (_, __, ___) => const ColoredBox(color: _surface),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              // Heavy where the text is, light where it is not: the form ends
              // around the middle of the screen, so below that the render can
              // simply be seen.
              colors: [
                Color(0xB31C1F26),
                Color(0xA61C1F26),
                Color(0x591C1F26),
                Color(0x261C1F26),
              ],
              stops: [0, 0.42, 0.62, 1],
            ),
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    required this.enabled,
    this.obscure = false,
    this.keyboardType,
    this.autofillHints,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool enabled;
  final bool obscure;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: obscure,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      onSubmitted: onSubmitted,
      textInputAction:
          onSubmitted != null ? TextInputAction.done : TextInputAction.next,
      style: const TextStyle(color: _textPrimary, fontSize: 17),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _textSecondary, fontSize: 16),
        prefixIcon: Icon(icon, color: _textSecondary),
        filled: true,
        fillColor: _card,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _accent, width: 2),
        ),
      ),
    );
  }
}

/// Neutral counterpart to [_ErrorBanner], for confirmations rather than
/// problems — «the code was sent again». Same shape, amber rule instead of red,
/// and its own icon, so the two are told apart without relying on colour.
class _NoticeBanner extends StatelessWidget {
  const _NoticeBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: const Border(left: BorderSide(color: _accent, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.mark_email_read_outlined,
              color: _accent, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: _textSecondary, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

/// Icon plus text on an opaque band — never colour alone (ACC-02).
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: const Border(left: BorderSide(color: _error, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: _error, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: _textSecondary, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.label,
    required this.busy,
    required this.onPressed,
  });

  final String label;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _controlHeight,
      child: ElevatedButton(
        onPressed: busy ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: _surface,
          disabledBackgroundColor: _outline,
          disabledForegroundColor: _textSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: busy
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: _textSecondary,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
