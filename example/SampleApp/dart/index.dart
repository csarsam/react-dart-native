import 'package:react/react.dart';
import 'package:react/react_client.dart';

class SampleApp extends Component {
  render() {
    return View({'style': containerStyle}, [
      Text({'style': welcomeStyle}, 'Welcome to Dart React Native!'),
      Text({'style': instructionsStyle}, 'To get started, edit index.dart'),
      Text({'style': instructionsStyle}, 'Press Cmd+R to reload,\nCmd+Control+Z for dev menu')
    ]);
  }
}

main() {
  setClientConfiguration();
  registerComponent('SampleApp', () => new SampleApp(), true);
}

Map containerStyle = {
  'flex': 1,
  'justifyContent': 'center',
  'alignItems': 'center',
  'backgroundColor': '#F5FCFF'
};

Map welcomeStyle = {
  'fontSize': 20,
  'textAlign': 'center',
  'margin': 10
};

Map instructionsStyle = {
  'textAlign': 'center',
  'color': '#333333',
  'marginBottom': 5
};