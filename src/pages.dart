/**
 * The pages framework handles page navigation based on windows hashes.
 */
Pages _pages;
Pages get pages() {
  if(_pages === null) {
    _pages = new Pages();
  }
  return _pages;
}

class Pages {

  List<PageMapper> _pageMappers;
  
  Pages() {
    _pageMappers = [];
  }
  
  List<PageMapper> get pageMappers() => _pageMappers;
  
  Pages start() {
    PageMapping.start();
    return this;
  }
  
  Pages show(final String page) {
    window.open(page, '_self');
  }
  
  void set navigator(PageNavigator navigator) {
    PageMapping.navigator = navigator;
  }
  
}

/**
 * An object that handles mapping a page to a url hash.  Add to MobileApp instance using mobile.pageMappers.add(PageMapper)
 */
interface PageMapper {
  /**
   * Return a page instance for the given hash.  null if the mapper does not have a page for the hash
   */
  Page pageForHash(String hash);
}

/**
 * Listens for hashChange events and retrieves Pages for the hash from PageMapper(s).  If no custom page mapper contains the page, 
 * use DefaultPageMapper 
 */
class PageMapping {
  
  static PageNavigator _navigator;
  
  static String get _currentHash() {
    return _parseHash(window.location.toString());
  }
  
  static void set navigator(PageNavigator navigator) {
    _navigator = navigator;
  }
  
  static void start() {
    window.on.hashChange.add(_handleChange);
    _parseAndShow(window.location.toString());
  }
  
  static void stop() {
    window.on.hashChange.remove(_handleChange);
  }
  
  static mapAndShow(String hash) {
    
    if(hash === null) {
      window.console.log("cowardly not showing null page");
      return;
    }
    
    if(hash === _currentHash) {
      window.console.log("not going to ${hash}, already there!");
      return;
    }
    
    // get the first page that is not null
    var mappedPages = pages.pageMappers.map((m) => m.pageForHash(hash)).filter((p) => p != null);
    if(mappedPages.length == 0) {
      mappedPages.add(const DefaultPageMapper().pageForHash(hash));
    }
    
    if(mappedPages[0] != null) {
      window.console.log("showing ${mappedPages[0]} with ${_navigator}");
      _navigator.show(mappedPages[0]);
    } else {
      window.console.log("No page found for ${hash}");
    }
    
  }
  
  static void _handleChange(HashChangeEvent e) {
    _parseAndShow(e.newURL);
  }
  
  static _parseAndShow(String url) {
    window.console.log("parseAndShow(${url})");
    final hash = _parseHash(url);
    mapAndShow(hash);
  }
  
  static String _parseHash(String url) {
    var hash;
    if(!url.contains('#')) {
      hash = null;
    } else {
      hash = url.substring(url.indexOf("#") + 1);
      if(hash.contains("?")) {
        hash = hash.substring(0,hash.indexOf('?'));
      }
    }
    window.console.log("Parsed ${url} to ${hash}");
    return hash;
  }
}

/**
 * Page navigator handles the navigation between pages
 */
interface PageNavigator {
  show(Page page);
}

/**
 * DefaultPageMapper returns the the page that exists in the dom
 */
class DefaultPageMapper implements PageMapper {

  const DefaultPageMapper();
  
  Page pageForHash(String hash) {
    return null;
  }
  
}

interface Page extends HasElement { 
  String get hash();
}
