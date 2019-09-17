(function () {
    window.wpfront_scroll_top = function (data) {
        var $ = jQuery;

        var container = $("#wpfront-scroll-top-container").css("opacity", 0);

        if (data.hide_iframe) {
            if ($(window).attr("self") !== $(window).attr("top"))
                return;
        }

        var mouse_over = false;
        var hideEventID = 0;

        var fnHide = function () {
            clearTimeout(hideEventID);
            if (container.is(":visible")) {
                container.stop().fadeTo(data.button_fade_duration, 0, function () {
                    container.hide();
                    mouse_over = false;
                });
            }
        };

        var fnHideEvent = function () {
            clearTimeout(hideEventID);
            hideEventID = setTimeout(function () {
                fnHide();
            }, data.auto_hide_after * 1000);
        };

        var scrollHandled = false;
        var fnScroll = function () {
            if (scrollHandled)
                return;

            scrollHandled = true;

            if ($(window).scrollTop() > data.scroll_offset) {
                container.stop().css("opacity", mouse_over ? 1 : data.button_opacity).show();
                if (!mouse_over && data.auto_hide) {
                    fnHideEvent();
                }
            } else {
                fnHide();
            }

            scrollHandled = false;
        };

        $(window).scroll(fnScroll);
        $(document).scroll(fnScroll);

        container
                .hover(function () {
                    clearTimeout(hideEventID);
                    mouse_over = true;
                    $(this).css("opacity", 1);
                }, function () {
                    $(this).css("opacity", data.button_opacity);
                    mouse_over = false;
                    fnHideEvent();
                })
                .click(function () {
                    $("html, body").animate({scrollTop: 0}, data.scroll_duration);
                    return false;
                });
    };
})();
