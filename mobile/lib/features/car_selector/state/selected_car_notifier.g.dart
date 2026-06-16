// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_car_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedCarNotifier)
const selectedCarProvider = SelectedCarNotifierProvider._();

final class SelectedCarNotifierProvider
    extends $NotifierProvider<SelectedCarNotifier, SelectedCar?> {
  const SelectedCarNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'selectedCarProvider',
          isAutoDispose: true,
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
    r'2551c2f7bf8b9ba357498601d718a06f91ef7195';

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
