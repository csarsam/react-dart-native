import 'package:react/react.dart';
import 'package:react/react_client.dart';

import 'dart:js';

class SampleApp extends Component {
  render() {
    return View({'style': styleSheet['containerStyle']}, [
      Text({'style': styleSheet['welcomeStyle']}, 'Welcome to Dart React Native!'),
      Text({'style': styleSheet['instructionsStyle']}, 'To get started, edit index.dart'),
      Text({'style': styleSheet['instructionsStyle']}, 'Press Cmd+R to reload,\nCmd+Control+Z for dev menu')
    ]);
  }
}

main() {
  setClientConfiguration();
  styleSheet = StyleSheet.create({
      'welcomeStyle': {
          'fontSize': 20,
          'textAlign': 'center',
          'margin': 10
      },
      'containerStyle': {
        'flex': 1,
        'justifyContent': 'center',
        'alignItems': 'center',
        'backgroundColor': '#F5FCFF'
      },
      'instructionsStyle': {
        'textAlign': 'center',
        'color': '#333333',
        'marginBottom': 5
      }
  });

  registerComponent('SampleApp', () => new SampleApp(), true);
}

JsObject styleSheet;