import '../../main/viewmodel/main_view_model.dart';
import '../model/auth_form_model.dart';

class AuthViewModel {
  const AuthViewModel(this._store);

  final DrameStore _store;

  Future<void> signIn(AuthFormModel form) {
    return _store.signIn(
      email: form.email,
      password: form.password,
    );
  }

  Future<void> signUp(AuthFormModel form) {
    return _store.signUp(
      email: form.email,
      password: form.password,
      name: form.name,
      nickname: form.nickname,
    );
  }
}
