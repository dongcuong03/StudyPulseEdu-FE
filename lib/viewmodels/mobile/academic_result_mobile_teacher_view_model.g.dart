// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'academic_result_mobile_teacher_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$academicResultMobileTeacherViewModelHash() =>
    r'a5686ac4178d12b0a3916729914e1fc3df5c0f8a';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$AcademicResultMobileTeacherViewModel
    extends BuildlessAutoDisposeAsyncNotifier<List<AcademicResult>> {
  late final String classId;

  FutureOr<List<AcademicResult>> build(
    String classId,
  );
}

/// See also [AcademicResultMobileTeacherViewModel].
@ProviderFor(AcademicResultMobileTeacherViewModel)
const academicResultMobileTeacherViewModelProvider =
    AcademicResultMobileTeacherViewModelFamily();

/// See also [AcademicResultMobileTeacherViewModel].
class AcademicResultMobileTeacherViewModelFamily
    extends Family<AsyncValue<List<AcademicResult>>> {
  /// See also [AcademicResultMobileTeacherViewModel].
  const AcademicResultMobileTeacherViewModelFamily();

  /// See also [AcademicResultMobileTeacherViewModel].
  AcademicResultMobileTeacherViewModelProvider call(
    String classId,
  ) {
    return AcademicResultMobileTeacherViewModelProvider(
      classId,
    );
  }

  @override
  AcademicResultMobileTeacherViewModelProvider getProviderOverride(
    covariant AcademicResultMobileTeacherViewModelProvider provider,
  ) {
    return call(
      provider.classId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'academicResultMobileTeacherViewModelProvider';
}

/// See also [AcademicResultMobileTeacherViewModel].
class AcademicResultMobileTeacherViewModelProvider
    extends AutoDisposeAsyncNotifierProviderImpl<
        AcademicResultMobileTeacherViewModel, List<AcademicResult>> {
  /// See also [AcademicResultMobileTeacherViewModel].
  AcademicResultMobileTeacherViewModelProvider(
    String classId,
  ) : this._internal(
          () => AcademicResultMobileTeacherViewModel()..classId = classId,
          from: academicResultMobileTeacherViewModelProvider,
          name: r'academicResultMobileTeacherViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$academicResultMobileTeacherViewModelHash,
          dependencies:
              AcademicResultMobileTeacherViewModelFamily._dependencies,
          allTransitiveDependencies: AcademicResultMobileTeacherViewModelFamily
              ._allTransitiveDependencies,
          classId: classId,
        );

  AcademicResultMobileTeacherViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.classId,
  }) : super.internal();

  final String classId;

  @override
  FutureOr<List<AcademicResult>> runNotifierBuild(
    covariant AcademicResultMobileTeacherViewModel notifier,
  ) {
    return notifier.build(
      classId,
    );
  }

  @override
  Override overrideWith(
      AcademicResultMobileTeacherViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: AcademicResultMobileTeacherViewModelProvider._internal(
        () => create()..classId = classId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        classId: classId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<AcademicResultMobileTeacherViewModel,
      List<AcademicResult>> createElement() {
    return _AcademicResultMobileTeacherViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AcademicResultMobileTeacherViewModelProvider &&
        other.classId == classId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, classId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AcademicResultMobileTeacherViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<List<AcademicResult>> {
  /// The parameter `classId` of this provider.
  String get classId;
}

class _AcademicResultMobileTeacherViewModelProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<
        AcademicResultMobileTeacherViewModel,
        List<AcademicResult>> with AcademicResultMobileTeacherViewModelRef {
  _AcademicResultMobileTeacherViewModelProviderElement(super.provider);

  @override
  String get classId =>
      (origin as AcademicResultMobileTeacherViewModelProvider).classId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
