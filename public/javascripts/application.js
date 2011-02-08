/* Function for closing the flash*/
document.observe('dom:loaded', function() {
    setTimeout(hideFlashes, 1000);
});

var hideFlashes = function() {
    $$('.notice', '.warning', '.error').each(function(e) {
        if (e) Effect.Fade(e, {
            duration: 10.5
        });
    })
}

var closeFlashes = function() {
    $$('.notice', '.warning', '.error').each(function(e) {
        if (e) Effect.Fade(e, {
            duration: 1.0
        });
    })
}
