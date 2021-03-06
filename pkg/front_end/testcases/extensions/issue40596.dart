// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
// @dart=2.9
import 'dart:async';

void main() {
  var controller = StreamController<String>();
  controller.stream((s) {
    print(s);
  });
}

extension Extension<T> on Stream<T> {
  StreamSubscription<T> call(Function onData) {
    return listen((d) {
      onData(d);
    });
  }
}
