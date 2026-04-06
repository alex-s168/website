#import "../common.typ": *

#let geizhals-price(id, at-time-of-writing) = {
  context if is-html() and is-web [
    #html.elem("a", attrs:(
      class:"geizhals-price-"+str(id),
      href:"https://geizhals.at/truthear-hexa-a"+str(id)+".html",
    ))[
      #at-time-of-writing € (at time of writing)
    ]
    #html-script("
      fetch('https://geizhals.at/api/gh0/price_history',{
        'body': JSON.stringify({'id':"+str(id)+", 'params':{'days':31,'loc':'at'}}),
        'method': 'POST'
      }).then((x) => x.json().then((x) => {
        let price = x.meta.current_best;
        if (price != null) {
          document.querySelectorAll('.geizhals-price-"+str(id)+"').forEach((a) => {
            a.innerHTML = price+' €';
          });
        }
      }));
    ")
  ] else [
    #at-time-of-writing € (at time of writing)
  ]
}


