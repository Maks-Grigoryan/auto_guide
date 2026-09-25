// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repair_params.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RepairParams)
const repairParamsProvider = RepairParamsProvider._();

final class RepairParamsProvider
    extends $NotifierProvider<RepairParams, RepairQuery?> {
  const RepairParamsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'repairParamsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$repairParamsHash();

  @$internal
  @override
  RepairParams create() => RepairParams();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RepairQuery? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RepairQuery?>(value),
    );
  }
}

String _$repairParamsHash() => r'bafb3880068c8b80c2466e2419b4628c59480c32';

abstract class _$RepairParams extends $Notifier<RepairQuery?> {
  RepairQuery? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<RepairQuery?, RepairQuery?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<RepairQuery?, RepairQuery?>,
        RepairQuery?,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
