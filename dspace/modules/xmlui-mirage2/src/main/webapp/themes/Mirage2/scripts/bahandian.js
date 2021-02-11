$(function () {
    $('h4 > a').each(function (i) {
        if ($(this).attr("href") == "/handle/20.500.12852/1") {
            $(this).parent().parent().parent().addClass('open');
        }
    });
});

$(function() {
    $("#tree").treeview({
        collapsed: true,
        animated: "medium",
        control:"#sidetreecontrol",
        persist: "location"
    });
});
