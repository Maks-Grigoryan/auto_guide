// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_car_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Must outlive any single screen.
///
/// As an autoDispose provider this was torn down whenever no widget happened to
/// be watching it between selector steps, taking the in-progress draft with it.
/// pickModel then rebuilt an empty draft via `??=`, so the model and generation
/// were recorded while the make was silently lost — and confirm() blew up on
/// `makeId!`, leaving the button looking dead.

@ProviderFor(SelectedCarNotifier)
const selectedCarProvider = SelectedCarNotifierProvider._();

/// Must outlive any single screen.
///
/// As an autoDispose provider this was torn down whenever no widget happened to
/// be watching it between selector steps, taking the in-progress draft with it.
/// pickModel then rebuilt an empty draft via `??=`, so the model and generation
/// were recorded while the make was silently lost — and confirm() blew up on
/// `makeId!`, leaving the button looking dead.
final class SelectedCarNotifierProvider
    extends $NotifierProvider<SelectedCarNotifier, SelectedCar?> {
  /// Must outlive any single screen.
  ///
  /// As an autoDispose provider this was torn down whenever no widget happened to
  /// be watching it between selector steps, taking the in-progress draft with it.
  /// pickModel then rebuilt an empty draft via `??=`, so the model and generation
  /// were recorded while the make was silently lost — and confirm() blew up on
  /// `makeId!`, leaving the button looking dead.
  const SelectedCarNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'selectedCarProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$selectedCarNotifierHash();

  @$internal
  @override
  SelectedCarNotifier create() => SelectedCarNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SelectedCar? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SelectedCar?>(value),
    );
  }
}

String _$selectedCarNotifierHash() =>
    r'bff2e1a23656af5b68c61420b2b3fbe3fd8bead5';

/// Must outlive any single screen.
///
/// As an autoDispose provider this was torn down whenever no widget happened to
/// be watching it between selector steps, taking the in-progress draft with it.
/// pickModel then rebuilt an empty draft via `??=`, so the model and generation
/// were recorded while the make was silently lost — and confirm() blew up on
/// `makeId!`, leaving the button looking dead.

abstract class _$SelectedCarNotifier extends $Notifier<SelectedCar?> {
  SelectedCar? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SelectedCar?, SelectedCar?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SelectedCar?, SelectedCar?>,
        SelectedCar?,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
