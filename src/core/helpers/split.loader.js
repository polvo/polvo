;(function( srcs, done ) {
  var i, loaded = 0, total = srcs.length;
  for( i=0; i<total; i++) {
    var s = document.createElement("script");
    s.type = "text/javascript";
    s.src = srcs[i];
    
    // ie
    if(window.attachEvent && document.all)
    {
      s.onreadystatechange = function () {
        if(/^(complete|loaded)$/m.test(this.readyState))
          if( ++loaded == total) {
            done()
          }
      };
    }

    // others
    else
    {
      s.onload = function(){
        if( ++loaded == total) {
          done();
        }
      }
    }

    document.getElementsByTagName("head")[0].appendChild(s);
  }
})(~SRCS, function(){
  ~BOOT
});