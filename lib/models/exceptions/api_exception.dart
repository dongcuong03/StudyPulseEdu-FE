import 'base_exception.dart';

class ApiException extends BaseException {
  ApiException({super.code, super.message});
}
