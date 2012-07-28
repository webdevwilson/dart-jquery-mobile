#import('../src/mobile.dart');
#import('dart:html');

void main() {
  
  jqm.on.beforePageCreate.add((e) => window.alert("${e}"));
  
  query('#changePageLink').on.click.add((e) => jqm.changePage('#changePage', {'transition': 'slideup'}));
  
  jqm.loadPage('loadpagetest.html');
  query('#loadPageLink').on.click.add((e) => jqm.changePage('loadpagetest.html'));
  
  query('#showLoadingButton').on.click.add(function(e) {
    var msg = query('#loadingText').value;
    var theme = query('#loadingTheme').value;
    var textOnly = query('#loadingTextOnly').value == 'true';
    jqm.showPageLoadingMsg(theme, msg, textOnly);
  });
  
  query('#hideLoadingButton').on.click.add((e) => jqm.hidePageLoadingMsg());
  
  query('a[href="#dynamicallyLoadingPages"]').on.click.add(void handler(e) {
    if(query('#dynamicallyLoadingPages') == null) {
      query('div[data-role="page"]').parent.nodes.add(const DynamicPage().element);
      jqm.changePage("#dynamicallyLoadingPages");
    }
  });
}

class DynamicPage {
  
  final String text = """
    <div data-role="page" id="dynamicallyLoadingPages">
      <div data-role="header"><a data-rel="back" data-icon="back">Back</a><h3>Dynamically Loaded</h3></div>
      <div data-role="content">I was dynamically loaded</div>
    </div>    
""";
  
  const DynamicPage();
  
  Element get element() {
    
    return new Element.html(text);
    
  }
  
}