// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/diagnostic/diagnostic.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/src/dart/ast/extensions.dart';
import 'package:analyzer/src/dart/element/type.dart';
import 'package:analyzer/src/dart/element/type_system.dart';
import 'package:analyzer/src/error/codes.dart';

/// Helper for checking potentially nullable dereferences.
class NullableDereferenceVerifier {
  final TypeSystemImpl _typeSystem;
  final ErrorReporter _errorReporter;

  NullableDereferenceVerifier({
    required TypeSystemImpl typeSystem,
    required ErrorReporter errorReporter,
  })   : _typeSystem = typeSystem,
        _errorReporter = errorReporter;

  bool expression(Expression expression,
      {DartType? type, ErrorCode? errorCode}) {
    if (!_typeSystem.isNonNullableByDefault) {
      return false;
    }

    type ??= expression.typeOrThrow;
    return _check(expression, type, errorCode: errorCode);
  }

  void report(AstNode errorNode, DartType receiverType,
      {ErrorCode? errorCode,
      List<String> arguments = const <String>[],
      List<DiagnosticMessage>? messages}) {
    if (receiverType == _typeSystem.typeProvider.nullType) {
      errorCode = CompileTimeErrorCode.INVALID_USE_OF_NULL_VALUE;
    } else {
      errorCode ??= CompileTimeErrorCode.UNCHECKED_USE_OF_NULLABLE_VALUE;
    }
    _errorReporter.reportErrorForNode(
        errorCode, errorNode, arguments, messages);
  }

  /// If the [receiverType] is potentially nullable, report it.
  ///
  /// The [errorNode] is usually the receiver of the invocation, but if the
  /// receiver is the implicit `this`, the name of the invocation.
  ///
  /// Returns whether [receiverType] was reported.
  bool _check(AstNode errorNode, DartType receiverType,
      {ErrorCode? errorCode}) {
    if (identical(receiverType, DynamicTypeImpl.instance) ||
        !_typeSystem.isPotentiallyNullable(receiverType)) {
      return false;
    }

    report(errorNode, receiverType, errorCode: errorCode);
    return true;
  }
}
