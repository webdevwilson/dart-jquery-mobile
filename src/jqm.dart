/**
 * JQuery Mobile implementations
 */
final String _JQM_EVENT_PREFIX = "jqm-dart-";
JQM _jqm;
JQM get jqm() {
  if(_jqm === null) {
    _jqm = const JQM();
  }
  return _jqm;
}

class JQM {
  
  final JQMEvents on = const JQMEvents();
  
  final List<PageMapper> pageMappers = const [];
  
  const JQM();
  
  init() {
    pages.navigator = const JQMPageNavigator();
    pages.pageMappers.add(const JQMPageMapper());
  }
  
  changePage(String to, [Map options]) {
    return _invokeJQM('changePage', [to, options]);
  }
  
  loadPage(String url, [Map options]) {
    return _invokeJQM('loadPage', [url, options]);
  }
  
  showPageLoadingMsg([String theme = 'a', String msgText = 'loading', bool textonly = false]) {
    return _invokeJQM('showPageLoadingMsg', [theme, msgText, textonly]);
  }
  
  hidePageLoadingMsg() {
    return _invokeJQM('hidePageLoadingMsg');
  }
  
  _invokeJQM(name, [args]) {
    return invoke('jqm_dart_invokeJQM', [name, args]);
  }
  
}

class JQMEvents {
  const JQMEvents();
  JQMEventList get beforePageCreate() => const JQMEventList('pagebeforecreate');
}

class JQMEventList implements EventListenerList {
  
  final String _name;
  
  final List _listeners = const [];
  
  const JQMEventList(this._name);
  
  EventListenerList add(void handler(Event event), [bool useCapture]) {
    _event().add(handler);
    return this;
  }
  
  bool dispatch(Event evt) {
    return _event().dispatch(evt);
  }
  
  EventListenerList remove(void handler(Event event), [bool useCapture]) {
    _event().remove(handler);
  }
  
  EventListenerList _event() {
    return window.on["${_JQM_EVENT_PREFIX}-${this._name}"];
  }
  
}
 
class JQMPageNavigator implements PageNavigator {
  const JQMPageNavigator();
  void show(final Page page) {
    var id=page.getElement().attributes['id'];
    window.console.log("jqm.changePage(#${id})");
    jqm.changePage("#${id}");
  }
}

class JQMPageMapper implements PageMapper {
  const JQMPageMapper();
  
  Page pageForHash(final hash) {
    return new JQMPage(hash);
  }
}

class JQMPage implements Page {
  
  final String _elementId;
  
  const JQMPage(this._elementId);
  
  Element getElement() {
    return query("#${this._elementId}");
  }
  
  String get hash() {
    return _elementId;
  }
}