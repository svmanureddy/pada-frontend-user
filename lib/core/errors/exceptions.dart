class AppException implements Exception {
  AppException({
    this.message = 'Something went wrong',
    this.response,
    this.statusCode,
  });

  final String? message;
  final dynamic response;
  final int? statusCode;
}

class ServerException extends AppException {
  ServerException({
    String message = 'Something went wrong',
  }) : super(message: message);
}

class ClientException extends AppException {
  ClientException({super.message = null, super.response, super.statusCode});
}

class HttpException extends AppException {
  HttpException({super.message = null, super.statusCode});
}
class TimeOutException extends AppException {
  TimeOutException({ super.statusCode})
      : super(message: "Connection time out");
}

/*class ErrorToast extends StatefulWidget {
  const ErrorToast({super.key, this.message});
  final String? message;

  @override
  State<ErrorToast> createState() => _ErrorToastState(this.message!);
}


class _ErrorToastState extends State<ErrorToast> {
  String? message;

  _ErrorToastState(String message);

   showToast(BuildContext context, String message){
    return showTopSnackBar(
      context,
      CustomSnackBar.success(
        message: message,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
     debugPrint("toast::: $message");
    return  showToast(context, message!);
  }
}*/
