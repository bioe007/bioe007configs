require("beautiful")

-- Markup helper functions
markup = {}

function markup.bg(color, text)
    if text ~= nil then
        return '<bg color="'..color..'" />'..text
    else
        return "niltexthere"
    end
end

function markup.fg(color, text)
    if text ~= nil then
        return '<span color="'..color..'">'..text..'</span>'
    else
        return "niltexthere"
    end
end

function markup.font(font, text)
    if text ~= nil then
        return '<span font_desc="'..font..'">'..text..'</span>'
    else
        return "niltexthere"
    end
end

function markup.title(t)
    return t
end

function markup.title_normal(t)
    return beautiful.title(t)
end

function markup.title_focus(t)
    return markup.bg(beautiful.bg_focus, markup.fg(beautiful.fg_focus, markup.title(t)))
end

function markup.title_urgent(t)
    return markup.bg(beautiful.bg_urgent, markup.fg(beautiful.fg_urgent, markup.title(t)))
end

function markup.bold(text)
    return '<b>'..text..'</b>'
end

function markup.heading(text)
    return markup.fg(beautiful.fg_focus, markup.bold(text))
end

-- vim:set filetype=lua fdm=marker tabstop=4 shiftwidth=4 expandtab smarttab autoindent smartindent: --
