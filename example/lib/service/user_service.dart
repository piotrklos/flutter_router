import 'package:injectable/injectable.dart';

import '../domain/user.dart';

@Injectable()
class UserService {
  static var isInternal = true;

  Future<User> getUser() async {
    await Future.delayed(const Duration(milliseconds: 20));
    return User(isIntrnal: isInternal);
  }
}
