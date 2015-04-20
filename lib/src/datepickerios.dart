part of react;

dynamic DatePickerIOS(Map props) {
  if (props.containsKey('style')) {
    if (props['style'].runtimeType is Map)
      props['style'] = new JsObject.jsify(props['style']);
  }

  if (props.containsKey('onDateChange')) {
    dynamic onDateChange = props['onDateChange'];
    props['onDateChange'] = (date) {
      DateTime convertedDate = _convertDate(date);
      onDateChange(convertedDate);
    };
  }

  return _React['createElement'].apply([_React['DatePickerIOS'], newJsMap(props)]);
}

DateTime _convertDate(String date) {
  JsObject jsDate = new JsObject(_Date, [date]);
  DateTime dartDate = DateTime.parse(jsDate.callMethod('toISOString', []));
  return dartDate;
}

