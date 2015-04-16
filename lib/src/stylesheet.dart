part of react;

class StyleSheet {
  static JsObject create(Map stylesheet) {
    JsObject jsStyleSheet = new JsObject.jsify(stylesheet);
    JsObject registeredStyleSheet = _StyleSheet.callMethod('create', [jsStyleSheet]);
    return registeredStyleSheet;
  }
}