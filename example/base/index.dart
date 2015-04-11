import 'package:react/react.dart';
import 'package:react/react_client.dart';

class darttest extends Component {
  render() {
    return Text(
        {'style': {
            'fontSize': 20,
            'textAlign': 'center',
            'backgroundColor': 'white',
            'margin': 10}
        }, 'Test');
  }
}

main() {
  setClientConfiguration();
  var geocodesApp = registerComponent(() => new darttest());
}