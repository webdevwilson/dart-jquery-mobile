#import('../src/jqm.dart');
#import('dart:html');
#import('unittest/unittest.dart');

void main() {
  
  jqm.on.beforePageCreate.add((e) => print("${e}"));
  
  query('#changePageLink').on.click.add((e) => jqm.changePage('#changePage', {'transition': 'slideup'}));
  
  jqm.loadPage('loadpagetest.html');
  query('#loadPageLink').on.click.add((e) => jqm.changePage('loadpagetest.html'));
  
}