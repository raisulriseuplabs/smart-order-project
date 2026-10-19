import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_response.freezed.dart';
part 'api_response.g.dart';

@Freezed(genericArgumentFactories: true)
abstract class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse({
    required bool success,
    T? data,
    String? message,
    String? error,
  }) = _ApiResponse<T>;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);
}

// Response wrapper for lists
@Freezed(genericArgumentFactories: true)
abstract class ListResponse<T> with _$ListResponse<T> {
  const factory ListResponse({
    required List<T> items,
    required int total,
    required int page,
    required int limit,
  }) = _ListResponse<T>;

  factory ListResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$ListResponseFromJson(json, fromJsonT);
}
