// Copyright (c) 2013, the Clean project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library react_client;

import "package:react/react.dart";
import "dart:js";
import "dart:async";

var _React = context['React'];
var _AppRegistry = _React['AppRegistry'];
var _Object = context['Object'];

const PROPS = 'props';
const INTERNAL = '__internal__';
const COMPONENT = 'component';
const IS_MOUNTED = 'isMounted';
const REFS = 'refs';

newJsObjectEmpty() {
  return new JsObject(_Object);
}

final emptyJsMap = newJsObjectEmpty();
newJsMap(Map map) {
  var JsMap = newJsObjectEmpty();
  for (var key in map.keys) {
    if(map[key] is Map) {
      JsMap[key] = newJsMap(map[key]);
    } else {
      JsMap[key] = map[key];
    }
  }
  return JsMap;
}

/**
 * Type of [children] must be child or list of childs, when child is JsObject or String
 */
typedef JsObject ReactComponentFactory(Map props, [dynamic children]);
typedef Component ComponentFactory();

class ReactComponentFactoryProxy implements Function {
  final ReactComponentFactory _call;
  final JsFunction reactComponentFactory;
  ReactComponentFactoryProxy(this._call, [this.reactComponentFactory]);

  JsObject call(Map props, [dynamic children]) {
    return this._call(props, children);
  }
}

/** TODO Think about using Expandos */
_getInternal(JsObject jsThis) => jsThis[PROPS][INTERNAL];
_getProps(JsObject jsThis) => _getInternal(jsThis)[PROPS];
_getComponent(JsObject jsThis) => _getInternal(jsThis)[COMPONENT];
_getInternalProps(JsObject jsProps) => jsProps[INTERNAL][PROPS];

ReactComponentFactory _registerComponent(ComponentFactory componentFactory, [bool registerApp, Iterable<String> skipMethods = const []]) {

  var zone = Zone.current;

  /**
   * wrapper for getDefaultProps.
   * Get internal, create component and place it to internal.
   *
   * Next get default props by component method and merge component.props into it
   * to update it with passed props from parent.
   *
   * @return jsProsp with internal with component.props and component
   */
  var getDefaultProps = new JsFunction.withThis((jsThis) => zone.run(() {
    return newJsObjectEmpty();
  }));

  /**
   * get initial state from component.getInitialState, put them to state.
   *
   * @return empty JsObject as default state for javascript react component
   */
  var getInitialState = new JsFunction.withThis((jsThis) => zone.run(() {
    jsThis[PROPS][INTERNAL] = newJsMap({});
    var internal = _getInternal(jsThis);
    var redraw = () {
      if (internal[IS_MOUNTED]) {
        jsThis.callMethod('setState', [emptyJsMap]);
      }
    };

    Component component = componentFactory();

    internal[COMPONENT] = component;
    internal[IS_MOUNTED] = false;
    internal[PROPS] = component.props;

    _getComponent(jsThis).initStateInternal();
    return newJsObjectEmpty();
  }));
//
  /**
   * only wrap componentWillMount
   */
  var componentWillMount = new JsFunction.withThis((jsThis) => zone.run(() {
    _getInternal(jsThis)[IS_MOUNTED] = true;
    _getComponent(jsThis)
        ..componentWillMount()
        ..transferComponentState();
  }));
//
//  /**
//   * only wrap componentDidMount
//   */
//  var componentDidMount = new JsFunction.withThis((JsObject jsThis) => zone.run(() {
//    //you need to get dom node by calling getDOMNode
//    _getComponent(jsThis).componentDidMount(/* TODO */);
//  }));
//
  _getNextProps(Component component, newArgs) {
    var newProps = _getInternalProps(newArgs);
    return {};
//      ..addAll(component.getDefaultProps())
//      ..addAll(newProps != null ? newProps : {});
  }
//
  _afterPropsChange(Component component, newArgs) {
    /** add component to newArgs to keep component in internal */
    newArgs[INTERNAL][COMPONENT] = component;
//
//    /** update component.props */
//    component.props = _getNextProps(component, newArgs);
//
//    /** update component.state */
//    component.transferComponentState();
  }
//
//  /**
//   * Wrap componentWillReceiveProps
//   */
//  var componentWillReceiveProps =
//      new JsFunction.withThis((jsThis, newArgs, [reactInternal]) => zone.run(() {
//    var component = _getComponent(jsThis);
//    component.componentWillReceiveProps(_getNextProps(component, newArgs));
//  }));
//
//  /**
//   * count nextProps from jsNextProps, get result from component,
//   * and if shoudln't update, update props and transfer state.
//   */
//  var shouldComponentUpdate =
//      new JsFunction.withThis((jsThis, newArgs, nextState, nextContext) => zone.run(() {
//    Component component  = _getComponent(jsThis);
//    /** use component.nextState where are stored nextState */
//    if (component.shouldComponentUpdate(_getNextProps(component, newArgs),
//                                        component.nextState)) {
//      return true;
//    } else {
//      /**
//       * if component shouldnt update, update props and tranfer state,
//       * becasue willUpdate will not be called and so it will not do it.
//       */
//      _afterPropsChange(component, newArgs);
//      return false;
//    }
//  }));
//
  /**
   * wrap component.componentWillUpdate and after that update props and transfer state
   */
  var componentWillUpdate = new JsFunction.withThis((jsThis, newArgs, nextState, [reactInternal]) => zone.run(() {
    Component component  = _getComponent(jsThis);
    component.componentWillUpdate(_getNextProps(component, newArgs),
                                  component.nextState);
    _afterPropsChange(component, newArgs);
  }));

//  /**
//   * wrap componentDidUpdate and use component.prevState which was trasnfered from state in componentWillUpdate.
//   */
//  var componentDidUpdate =
//      new JsFunction.withThis((JsObject jsThis, prevProps, prevState, prevContext) => zone.run(() {
//    var prevInternalProps = _getInternalProps(prevProps);
//    //you don't get root node as parameter but need to get it directly
//    var rootNode = jsThis.callMethod("getDOMNode");
//    Component component = _getComponent(jsThis);
//    component.componentDidUpdate(prevInternalProps, component.prevState, rootNode);
//  }));
//
//  /**
//   * only wrap componentWillUnmount
//   */
//  var componentWillUnmount =
//      new JsFunction.withThis((jsThis, [reactInternal]) => zone.run(() {
//    _getInternal(jsThis)[IS_MOUNTED] = false;
//    _getComponent(jsThis).componentWillUnmount();
//  }));

  /**
   * only wrap render
   */
  var render = new JsFunction.withThis((jsThis) => zone.run(() {
    return _getComponent(jsThis).render();
  }));

  var skipableMethods = ['componentDidMount', 'componentWillReceiveProps',
                         'shouldComponentUpdate', 'componentDidUpdate',
                         'componentWillUnmount'];

  removeUnusedMethods(Map originalMap, Iterable removeMethods) {
    removeMethods.where((m) => skipableMethods.contains(m)).forEach((m) => originalMap.remove(m));
    return originalMap;
  }

  /**
   * create reactComponent with wrapped functions
   */
  JsFunction reactComponentFactory = new JsFunction.withThis(([jsThis, args, children]) {
    return _React.callMethod('createClass', [newJsMap(
        {
        'componentWillMount': componentWillMount,
//        'componentDidMount': componentDidMount,
//        'componentWillReceiveProps': componentWillReceiveProps,
//        'shouldComponentUpdate': shouldComponentUpdate,
        'componentWillUpdate': componentWillUpdate,
//        'componentDidUpdate': componentDidUpdate,
//        'componentWillUnmount': componentWillUnmount,
           'getDefaultProps': getDefaultProps,
          'getInitialState': getInitialState,
            'render': render
        }
    )]);
  });

  var call = (Map props, [dynamic children]) {
    if (children == null) {
      children = [];
    } else if (children is! Iterable) {
      children = [children];
    }
    var extendedProps = new Map.from(props);
    extendedProps['children'] = children;

    var convertedArgs = newJsObjectEmpty();

    /**
     * add key to args which will be passed to javascript react component
     */
    if (extendedProps.containsKey('key')) {
      convertedArgs['key'] = extendedProps['key'];
    }

    /**
     * put props to internal part of args
     */
    convertedArgs[INTERNAL] = {PROPS: extendedProps};

    return reactComponentFactory.apply([context['Object'].apply([]), convertedArgs, new JsArray.from(children)]);
  };

  /**
   * return ReactComponentFactory which produce react component with set props and children[s]
   */
  if (registerApp)
    _AppRegistry.callMethod('registerComponent', ['darttest', reactComponentFactory]);
  return new ReactComponentFactoryProxy(call);
}

/**
 * create dart-react registered component for html tag.
 */
dynamic _reactDom(String name) {
  return (Map props, [dynamic children]) {
    if (props.containsKey('style')) {
      props['style'] = new JsObject.jsify(props['style']);
    }
    if (children is Iterable) {
      children = new JsArray.from(children);
    }
    return _React['createElement'].apply([_React[name], newJsMap(props), children]);
  };
}

void _render(JsObject component, var element) {
  _React.callMethod('render', [component, element]);
}

bool _unmountComponentAtNode(var element) {
  return _React.callMethod('unmountComponentAtNode', [element]);
}

void setClientConfiguration() {
  setReactConfiguration(_reactDom, _registerComponent, _render, null, _unmountComponentAtNode);
}
