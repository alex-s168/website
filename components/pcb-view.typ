#import "../common.typ": *

#let pcb(front,back, size-percent:100) = {
  context if is-html() {
    if is-web {
      html.elem("img", attrs:(draggable:"false", tite:"Click Me!", src:front, data-other:back, onclick:"swapFrontBack(this);", style:"width:"+str(size-percent)+"%; cursor:pointer;"))
    } else {
      html.elem("img", attrs:(src:front, style:"width:100%;"))
    }
  } else {
    [#image(front) #image(back)]
  }
  context if is-html() and is-web {
    html-script("
      function swapFrontBack(img) {
        let oldsrc = img.src;
        img.src = img.dataset.other; 
        img.dataset.other = oldsrc;
      }
    ")
  }
}


