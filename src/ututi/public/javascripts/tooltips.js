$(document).ready(function() {
    $("span.tooltip").each(function() {
        $(this).qtip({
              content: $(this).children('.content').text(),
              show: 'mouseover',
              hide: 'mouseout',
              position: {
                  corner: {
                      target: 'topMiddle',
                      tooltip: 'bottomMiddle'
                  },
                  adjust: { screen: true }
              },
              style: {
                  name: 'cream',
                  border: {
                      width: 3,
                      radius: 8,
                  },
                  tip: 'bottomMiddle'
              }

        });
    });
});
