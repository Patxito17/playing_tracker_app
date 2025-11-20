import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/firebase_error_mapper.dart';
import '../../domain/repositories/auth_repository.dart';
import 'forgot_password_state.dart';

/// Cubit encargado de gestionar el envío del correo de recuperación.
class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit(this._authRepository)
    : super(const ForgotPasswordInitial());

  final AuthRepository _authRepository;

  /// Envía el enlace de recuperación al [email] proporcionado.
  Future<void> sendResetLink(String email) async {
    emit(const ForgotPasswordLoading());
    try {
      await _authRepository.sendPasswordResetEmail(email);
      emit(ForgotPasswordSuccess(email));
    } catch (error) {
      emit(ForgotPasswordError(FirebaseErrorMapper.map(error)));
    }
  }

  /// Restablece el estado para permitir nuevos envíos.
  void reset() => emit(const ForgotPasswordInitial());
}
