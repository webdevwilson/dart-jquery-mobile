#import('../src/jqm.dart');
#import('dart:html');
#import('unittest/unittest.dart');

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
  
}