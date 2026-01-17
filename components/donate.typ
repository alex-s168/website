#import "../common.typ": *

#let donate-cardano(address, mult:1) = {
  context if is-html() and is-web [
    #html.elem("a", attrs:(
      class:"donate",
      data-mult:str(mult),
      data-address:address,
      target:"_blank",
    ))
    #html-script("
      onCoffee((coffee) => {
        document.querySelectorAll('.donate').forEach((a) => {
          let mult = parseInt(a.dataset.mult);
          let amnt = (coffee.coffee_usd / coffee.ada_usd) * mult;
          console.log(mult);
          a.href = 'web+cardano:' + a.dataset.address + '?amount=' + amnt;
          a.innerHTML = 'Donate ' + Math.ceil(amnt * 10000) / 10000 + ' Ada';
        });
      });
    ")
  ]
}


