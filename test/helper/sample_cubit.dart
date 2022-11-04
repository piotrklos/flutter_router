import 'package:app_router/src/bloc_provider.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SampleCubitState extends Equatable {
  final String message;

  const SampleCubitState(this.message);

  @override
  List<Object?> get props => [message];
}

class SampleCubit extends Cubit<SampleCubitState>
    with AppRouterBlocProvider<SampleCubit> {
  final VoidCallback? onClose;

  SampleCubit({
    String? message,
    this.onClose,
  }) : super(SampleCubitState(message ?? ""));

  void setMessage(String messaeg) {
    emit(SampleCubitState(messaeg));
  }

  @override
  Future<void> close() {
    onClose?.call();
    return super.close();
  }
}

class SampleCubit2 extends Cubit<SampleCubitState>
    with AppRouterBlocProvider<SampleCubit2> {
  final VoidCallback? onClose;

  SampleCubit2({
    String? message,
    this.onClose,
  }) : super(SampleCubitState(message ?? ""));

  void setMessage(String messaeg) {
    emit(SampleCubitState(messaeg));
  }

  @override
  Future<void> close() {
    onClose?.call();
    return super.close();
  }
}

class SampleCubit3 extends Cubit<SampleCubitState>
    with AppRouterBlocProvider<SampleCubit3> {
  final VoidCallback? onClose;
  SampleCubit3({
    String? message,
    this.onClose,
  }) : super(SampleCubitState(message ?? ""));

  void setMessage(String messaeg) {
    emit(SampleCubitState(messaeg));
  }

  @override
  Future<void> close() {
    onClose?.call();
    return super.close();
  }
}

class SampleCubitWithDependency extends Cubit<SampleCubitState>
    with AppRouterBlocProvider<SampleCubitWithDependency> {
  final SampleCubit? sampleCubit;
  final VoidCallback? onClose;

  SampleCubitWithDependency({
    required String message,
    this.sampleCubit,
    this.onClose,
  }) : super(SampleCubitState(message));

  void setMessage(String messaeg) {
    emit(SampleCubitState(messaeg));
  }

  @override
  Future<void> close() {
    onClose?.call();
    return super.close();
  }
}

class MockSampleCubit extends MockCubit<SampleCubitState>
    implements SampleCubit {}
