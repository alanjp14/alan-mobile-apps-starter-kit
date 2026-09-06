// AMDS · Result<T> + Failure — the currency between layers.
// Data sources never throw to callers; they return Result. See
// docs/starter-template/error-handling-and-logging.md.

import 'package:meta/meta.dart' show immutable;

/// A typed failure. Field/UI layers map this to the standard states.
@immutable
sealed class Failure {
  const Failure({this.traceId});

  /// Present on server (`Server`) failures — surface it in error UIs for support.
  final String? traceId;

  String get message;
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super();
  @override
  String get message => 'No connection.';
}

class TimeoutFailure extends Failure {
  const TimeoutFailure() : super();
  @override
  String get message => 'The request timed out.';
}

class OfflineFailure extends Failure {
  const OfflineFailure() : super();
  @override
  String get message => "You're offline.";
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure() : super();
  @override
  String get message => 'Your session has expired.';
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure({this.detail}) : super();
  final String? detail;
  @override
  String get message => detail ?? "You don't have permission to do this.";
}

class NotFoundFailure extends Failure {
  const NotFoundFailure() : super();
  @override
  String get message => 'This item no longer exists.';
}

/// The server resource changed since it was loaded. [current] holds the server's
/// version so the UI can offer a conflict resolution.
class ConflictFailure<T> extends Failure {
  const ConflictFailure(this.current) : super();
  final T current;
  @override
  String get message => 'This was updated by someone else.';
}

/// Field-level validation errors, keyed by field name.
class ValidationFailure extends Failure {
  const ValidationFailure(this.fieldErrors) : super();
  final Map<String, String> fieldErrors;
  @override
  String get message => fieldErrors.values.isNotEmpty ? fieldErrors.values.first : 'Please check the form.';
}

class ServerFailure extends Failure {
  const ServerFailure({super.traceId, this.status});
  final int? status;
  @override
  String get message => 'Something went wrong on our side.';
}

class UnknownFailure extends Failure {
  const UnknownFailure([this._message]) : super();
  final String? _message;
  @override
  String get message => _message ?? 'Something went wrong.';
}

/// `Success(value)` | `ResultError(failure)`. Fold with [fold] / [when].
@immutable
sealed class Result<T> {
  const Result();

  const factory Result.success(T value) = Success<T>;
  const factory Result.failure(Failure failure) = ResultError<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is ResultError<T>;

  T? get valueOrNull => switch (this) { Success<T>(:final value) => value, _ => null };
  Failure? get failureOrNull => switch (this) { ResultError<T>(:final failure) => failure, _ => null };

  R fold<R>({required R Function(T value) onSuccess, required R Function(Failure failure) onFailure}) =>
      switch (this) {
        Success<T>(:final value) => onSuccess(value),
        ResultError<T>(:final failure) => onFailure(failure),
      };

  Result<R> map<R>(R Function(T value) transform) => switch (this) {
        Success<T>(:final value) => Success<R>(transform(value)),
        ResultError<T>(:final failure) => ResultError<R>(failure),
      };

  /// Wrap a throwing async computation into a `Result`, mapping via [onError].
  static Future<Result<T>> guard<T>(
    Future<T> Function() run, {
    Failure Function(Object error, StackTrace stack)? onError,
  }) async {
    try {
      return Success(await run());
    } catch (e, s) {
      return ResultError(onError?.call(e, s) ?? UnknownFailure(e.toString()));
    }
  }
}

@immutable
final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

@immutable
final class ResultError<T> extends Result<T> {
  const ResultError(this.failure);
  final Failure failure;
}
