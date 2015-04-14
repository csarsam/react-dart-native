library react.transformer;

import 'package:barback/barback.dart';
import 'dart:async';

class ReactNativeIfy extends Transformer {
  String environment =  "var React = require('react-native');"
                      + "var window = this;"
                      + "var self = this;"
                      + "window.React = React;"
                      + "window.ua = '';"
                      + "navigator = undefined;\n";

  ReactNativeIfy.asPlugin();

  String get allowedExtensions => ".js";

  Future apply(Transform transform) async {
    var content = await transform.primaryInput.readAsString();
    var id = transform.primaryInput.id;
    var newContent = environment + content;
    transform.addOutput(new Asset.fromString(id, newContent));
  }
}