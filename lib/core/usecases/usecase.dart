import 'package:dartz/dartz.dart' hide Task;
import 'package:todo_app/core/error/failures.dart';

/// Abstract base class for defining a Use Case in the Clean Architecture.
///
/// Use Cases encapsulate application-specific business rules. They orchestrate
/// the flow of data to and from the entities (via repositories) and are
/// invoked by the Presentation layer (e.g., BLoC/Riverpod).
///
/// [Type] represents the return type of the use case upon successful execution.
/// [Params] represents the input parameters required by the use case.
///
/// All concrete use cases should extend this class and implement the [call] method.
abstract class UseCase<Type, Params> {
  /// Executes the use case.
  ///
  /// This method defines the contract for all concrete use cases. It should
  /// return a [Future] that resolves to an [Either] type.
  ///
  /// The [Either] type represents a value that can be one of two types:
  /// - A [Failure] on the left side, indicating an error.
  /// - The [Type] on the right side, indicating a successful result.
  ///
  /// [params] are the input parameters necessary for the use case's operation.
  /// These parameters should be encapsulated in a specific class for each use case,
  /// inheriting from a common base if needed, or simply a `freezed` data class.
  Future<Either<Failure, Type>> call(Params params);
}

/// A class representing no parameters for use cases that do not require any input.
///
/// This is a simple, immutable class that serves as a placeholder for the
/// `Params` type in [UseCase] when no input is needed.
/// It uses a const constructor to ensure immutability and allow for compile-time
/// constant instances, adhering to Flutter's best practices.
class NoParams {
  /// Creates a [NoParams] instance.
  ///
  /// This const constructor ensures that [NoParams] instances are immutable
  /// and can be created as compile-time constants.
  const NoParams();

  /// Overrides the equality operator to compare [NoParams] instances.
  ///
  /// All [NoParams] instances are considered equal since they carry no state.
  /// This ensures that comparing two `NoParams` objects returns true, which is
  /// useful for testing and certain state management patterns.
  @override
  bool operator ==(Object other) => other is NoParams;

  /// Returns a hash code for this [NoParams] instance.
  ///
  /// Since all [NoParams] instances are equal, they should have the same hash code.
  /// A constant value is used to ensure consistency with the equality operator.
  @override
  int get hashCode => 0;
}