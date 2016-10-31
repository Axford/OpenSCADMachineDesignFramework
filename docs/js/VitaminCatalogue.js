
function polish() {
      // add ids to headings to accommodate anchor links
      $('h1').each(function(index) {
        $(this).attr('id', $(this).text().replace(/[\s]+/g, "-").replace(/[\.]+/g,"").toLowerCase());
      });
      $('h2').each(function(index) {
        $(this).attr('id', $(this).text().replace(/[\s]+/g, "-").replace(/[\.]+/g,"").toLowerCase());
      });
      $('h3').each(function(index) {
        $(this).attr('id', $(this).text().replace(/[\s]+/g, "-").replace(/[\.]+/g,"").toLowerCase());
      });
}


$(document).ready(function(){


    $.get(VitaminCatalogueFilename,function(data,status){

          $('#mdcontent').html(markdown.toHTML(data, markdown.Markdown.dialects.Maruku));
          $('#mdcontent').append('<div style="clear:both;"></div>');

          // expand linked markdown
          $("a[href$='.md?include']").each(function(index) {
              var a = this;
              var href = $(a).attr('href');
              var parts = href.split('/');
              var relPath = '', filename = parts[parts.length-1];
              for (var i=0; i < parts.length-1; i++) {
                if (relPath > '') relPath += '/';
                relPath += parts[i];
              }
              $.get(href, function(data2, status2) {

                var md = markdown.toHTML(data2, markdown.Markdown.dialects.Maruku);
                md = $(md);

                // rewrite anchor urls with correct relative path
                md.find('a').each(function(data3, status3) {
                    var href = $(this).attr('href');
                    if (href[0] == '#') {
                        $(this).attr('href', href.replace(/[\s]+/g, "-").replace(/[\.]+/g,"").toLowerCase());
                    } else {
                        $(this).attr('href', relPath + '/' + href);
                    }
                });

                // rewrite image urls with correct relative path
                md.find('img').each(function(data3, status3) {
                    $(this).attr('src', relPath + '/' + $(this).attr('src'));
                });

                $(a).replaceWith(md);

                polish();
              });
          });

          polish();

          // hide broken images
      $(window).load(function() {
           $("img").each(function(){
              var image = $(this);
              if(image.context.naturalWidth == 0 || image.readyState == 'uninitialized'){
                 $(image).unbind("error").hide();
              }
           });
        });

    });

});
