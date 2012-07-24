#library('dart:jqm');
#import('dart:html');
#import('dart:json');
#source('js.dart');

final String JQM_EVENT_PREFIX = "jqm-dart-";
final JQM jqm = const JQM();

class JQM {
  final JQMEvents on = const JQMEvents();
  const JQM();
  
  void changePage(String to, [Map options]) {
    invoke('jqm_dart_invokeJQM', ['changePage', [to, options]]);
  }
  
  void loadPage(String url, [Map options]) {
    invoke('jqm_dart_invokeJQM', ['loadPage', [url, options]]);
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
    return window.on["${JQM_EVENT_PREFIX}-${this._name}"];
  }
  
}

