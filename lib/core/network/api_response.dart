import 'package:equatable/equatable.dart';

enum Status { initial, loading, completed, error }

/// Generic wrapper for API response states in MVVM + BLoC architecture
class ApiResponse<T> extends Equatable {
  final Status status;
  final T? data;
  final String? message;

  const ApiResponse.initial()
      : status = Status.initial,
        data = null,
        message = null;

  const ApiResponse.loading([this.message])
      : status = Status.loading,
        data = null;

  const ApiResponse.completed(this.data)
      : status = Status.completed,
        message = null;

  const ApiResponse.error(this.message)
      : status = Status.error,
        data = null;

  bool get isInitial => status == Status.initial;
  bool get isLoading => status == Status.loading;
  bool get isCompleted => status == Status.completed;
  bool get isError => status == Status.error;

  @override
  List<Object?> get props => [status, data, message];

  @override
  String toString() {
    return 'ApiResponse(status: $status, message: $message, data: $data)';
  }
}
