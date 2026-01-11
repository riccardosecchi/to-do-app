/// A file defining failure types for error handling in the application.
/// This adheres to the Clean Architecture's data layer, providing a structured way
/// to represent different kinds of errors that can occur within the domain or infrastructure.
///
/// This file is part of the `core/error` directory, emphasizing its foundational
/// role in error management across the application.

/// Abstract base class for all failure types in the application.
///
/// Failures represent error conditions that prevent an operation from succeeding.
/// Each failure can optionally carry a [message] to provide more detailed
/// information about the error.
///
/// This class is immutable, ensuring that failure instances do not change
/// after creation.
abstract class Failure {
  /// An optional message providing more details about the failure.
  ///
  /// This message can be used for logging, debugging, or displaying
  /// user-friendly error messages.
  final String? message;

  /// Creates a [Failure] instance with an optional [message].
  ///
  /// The constructor is `const` to allow for compile-time constants
  /// when the failure message is also a constant, promoting efficient
  /// memory usage for common failure scenarios.
  const Failure({this.message});

  /// Overrides the equality operator to compare two [Failure] instances.
  ///
  /// Two [Failure] instances are considered equal if they are of the same
  /// runtime type and their [message] properties are identical.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Failure && other.message == message;
  }

  /// Overrides the [hashCode] method to generate a hash code for [Failure] instances.
  ///
  /// The hash code is based on the runtime type and the [message] property,
  /// ensuring consistency with the overridden `==` operator.
  @override
  int get hashCode => runtimeType.hashCode ^ message.hashCode;

  /// Returns a string representation of the failure.
  ///
  /// Includes the runtime type and the message, if available.
  @override
  String toString() => '$runtimeType(message: $message)';
}

/// Represents a failure specifically related to local data caching operations.
///
/// This failure type is typically used when there are issues with reading from,
/// writing to, or otherwise interacting with local storage mechanisms
/// (e.g., SharedPreferences, Hive, SQLite database).
class CacheFailure extends Failure {
  /// Creates a [CacheFailure] instance with an optional [message].
  ///
  /// The constructor is `const` to allow for compile-time constants
  /// when the failure message is also a constant.
  const CacheFailure({super.message});
}

/// Represents a failure specifically related to input validation.
///
/// This failure type is used when user input or data passed to a method
/// does not meet the required criteria or format. It signals that the
/// input itself is invalid, rather than an external system error.
class ValidationFailure extends Failure {
  /// Creates a [ValidationFailure] instance with an optional [message].
  ///
  /// The constructor is `const` to allow for compile-time constants
  /// when the failure message is also a constant.
  const ValidationFailure({super.message});
}

/// Represents a failure when a requested resource is not found.
///
/// This failure type is used when an entity (e.g., a task) cannot be
/// located by its identifier in the data source.
class NotFoundFailure extends Failure {
  /// Creates a [NotFoundFailure] instance with an optional [message].
  const NotFoundFailure({super.message});
}

/// Represents a failure related to server/remote API operations.
///
/// This failure type is used when there are issues communicating with
/// remote services like Supabase, REST APIs, or other backend services.
class ServerFailure extends Failure {
  /// Creates a [ServerFailure] instance with an optional [message].
  const ServerFailure([String? message]) : super(message: message);
}