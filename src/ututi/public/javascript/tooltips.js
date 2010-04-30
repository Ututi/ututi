$(document).ready(function() {
    $("div.tooltip").each(function() {
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
                  background: '#F9F9F9',
                  color: '#d45500',
                  'font-size': '12px',
                  'font-weight': 'normal',
                  border: {
                      width: 1,
                      radius: 3,
                      color: '#cacabb'
                  },
                  tip: 'bottomMiddle'
              }

        });
    });
    $("img.tooltip").each(function() {
        $(this).qtip({
              content: $(this).attr('alt'),
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
                  background: '#F9F9F9',
                  color: '#d45500',
                  'font-size': '12px',
                  'font-weight': 'normal',
                  border: {
                      width: 1,
                      radius: 3,
                      color: '#cacabb'
                  },
                  tip: 'bottomMiddle'
              }

        });
    });
});
