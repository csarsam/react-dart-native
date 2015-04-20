part of react;

JsObject _React = context['React'];
JsObject _StyleSheet = _React['StyleSheet'];
var _AppRegistry = _React['AppRegistry'];
var _Object = context['Object'];
JsObject _Date = context['Date'];

JsObject newJsObjectEmpty() {
  return new JsObject(_Object);
}

final emptyJsMap = newJsObjectEmpty();

JsObject newJsMap(Map map) {
  JsObject JsMap = newJsObjectEmpty();
  for (var key in map.keys) {
    if(map[key] is Map) {
      JsMap[key] = newJsMap(map[key]);
    } else {
      JsMap[key] = map[key];
    }
  }
  return JsMap;
}