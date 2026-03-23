// lib/core/network/api_response.dart

class ApiResponse<T> {
  final bool status;
  final String message;
  final T? data;

  ApiResponse({
    required this.status,
    this.message = '',
    this.data,
  });

  // 성공 시 호출하는 생성자
  factory ApiResponse.success(T data, {String message = ''}) => ApiResponse(
        status: true,
        data: data,
        message: message,
      );

  // 실패 시 호출하는 생성자
  factory ApiResponse.error(String message) => ApiResponse(
        status: false,
        message: message,
      );
}