// Copyright (c) 2013, the Clean project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/**
 * A Dart library for building user interfaces.
 */
library react;

abstract class Component {
  Map props;

  dynamic ref;
  dynamic getDOMNode;
  dynamic _jsRedraw;

  /**
   * Bind the value of input to [state[key]].
   */
  bind(key) => [state[key], (value) => setState({key: value})];

  initComponentInternal(props, _jsRedraw, [ref = null, getDOMNode = null]) {
    this._jsRedraw = _jsRedraw;
    this.ref = ref;
    this.getDOMNode = getDOMNode;
    _initProps(props);
  }

  _initProps(props) {
    this.props = {}
      ..addAll(getDefaultProps())
      ..addAll(props);
  }

  initStateInternal() {
    this.state = new Map.from(getInitialState());
    /** Call transferComponent to get state also to _prevState */
    transferComponentState();
  }

  Map state = {};

  /**
   * private _nextState and _prevState are usefull for methods shouldComponentUpdate,
   * componentWillUpdate and componentDidUpdate.
   *
   * Use of theese private variables is implemented in react_client or react_server
   */
  Map _prevState = null;
  Map _nextState = null;
  /**
   * nextState and prevState are just getters for previous private variables _prevState
   * and _nextState
   *
   * if _nextState is null, then next state will be same as actual state,
   * so return state as nextState
   */
  Map get prevState => _prevState;
  Map get nextState => _nextState == null ? state : _nextState;

  /**
   * Transfers component _nextState to state and state to _prevState.
   * This is only way how to set _prevState.
   */
  void transferComponentState() {
    _prevState = state;
    if (_nextState != null) {
      state = _nextState;
    }
    _nextState = new Map.from(state);
  }

  void redraw() {
    setState({});
  }

  /**
   * set _nextState to state updated by newState
   * and call React original setState method with no parameter
   */
  void setState(Map newState) {
    if (newState != null) {
      _nextState.addAll(newState);
    }

    _jsRedraw();
  }

  /**
   * set _nextState to newState
   * and call React original setState method with no parameter
   */
  void replaceState(Map newState) {
    Map nextState = newState == null ? {} : new Map.from(newState);
    _nextState = nextState;
    _jsRedraw();
  }

  void componentWillMount() {}

  void componentDidMount(/*DOMElement */ rootNode) {}

  void componentWillReceiveProps(newProps) {}

  bool shouldComponentUpdate(nextProps, nextState) => true;

  void componentWillUpdate(nextProps, nextState) {}

  void componentDidUpdate(prevProps, prevState, /*DOMElement */ rootNode) {}
  
  void componentWillUnmount() {}

  Map getInitialState() => {};

  Map getDefaultProps() => {};

  dynamic render();

}

/**
 * client side rendering
 */
var render;

/**
 * server side rendering
 */
var renderToString;


/**
 * bool unmountComponentAtNode(HTMLElement);
 * 
 * client side derendering - reverse operation to render
 * 
 */
var unmountComponentAtNode;

/**
 * register component method to register component on both, client-side and server-side.
 */
var registerComponent;

/** 
 * Basic UI elements
 */
var Text, View;


/**
 * Create DOM components by creator passed
 */
_createDOMComponents(creator){
  Text = creator('Text');
  View = creator('View');
}

/**
 * set configuration based on passed functions.
 *
 * It pass arguments to global variables and run DOM components creation by dom Creator.
 */
setReactConfiguration(domCreator, customRegisterComponent, customRender, customRenderToString, customUnmountComponentAtNode){
  registerComponent = customRegisterComponent;
  render = customRender;
  renderToString = customRenderToString;
  unmountComponentAtNode = customUnmountComponentAtNode;
  // HTML Elements
  _createDOMComponents(domCreator);
}

