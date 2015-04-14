import 'package:react/react.dart';
import 'package:react/react_client.dart';

class darttest extends Component {
  render() {
    print('render darttest');
    return Text({}, 'Test');
  }
}

main() {
  setClientConfiguration();
  var geocodesApp = registerComponent(() => new darttest(), true);
}