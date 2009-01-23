--- Shifty: Dynamic tagging library for awesome3-git
-- @author koniu &lt;gkusnierz@gmail.com&gt;
--
-- http://awesome.naquadah.org/wiki/index.php?title=Shifty

-- package env

local tag = tag
local ipairs = ipairs
local table = table
local client = client
local image = image
local hooks = hooks
local string = string
local widget = widget
local screen = screen
local button = button
local mouse = mouse
local capi = { hooks = hooks, client = client }
local beautiful = require("beautiful")
local awful = require("awful")
local image = image
local otable = otable
local pairs = pairs
local io = io
local tostring = tostring
local tonumber = tonumber

module("shifty")

tags = {}
index_cache = {}
config = {}
config.tags = {}
config.apps = {}
config.defaults = {}
config.guess_name = true
config.guess_position = true
config.remember_index = true

for s = 1, screen.count() do tags[s] = {} end
local data = otable()


function name2tag(name, scr)
    local a, b = scr or 1, scr or screen.count()
    for s = a, b do
        for i, t in ipairs(tags[s]) do
            if name == t.name then
            return t end
        end
    end
end

function tag2index(tag)
    for i, t in ipairs(tags[tag.screen]) do
        if tag == t then return i end
    end
end

function viewidx(i, screen)
    local screen = screen or mouse.screen or 1
    local tags = tags[screen]
    local sel = awful.tag.selected()
    awful.tag.viewnone()
    for k, t in ipairs(tags) do
        if t == sel then
            tags[awful.util.cycle(#tags, k + i)].selected = true
        end
    end
end

function next() viewidx(1) end
function prev() viewidx(-1) end

function rename(tag, prefix, no_selectall, initial)
    local theme = beautiful.get()
    local scr = (tag and tag.screen) or mouse.screen or 1
    local t = tag or awful.tag.selected(scr)
    local bg = nil
    local text = prefix or t.name or ""
    local before = t.name
    if t == awful.tag.selected(scr) then bg = theme.bg_focus or '#535d6c'
        else bg = theme.bg_normal or '#222222' end

    awful.prompt.run({
        fg_cursor = "orange",
        bg_cursor = bg,
        ul_cursor = "single",
        text = text,
        selectall = not no_selectall,
        prompt = '<bg color="'..bg..'" /> ' },
        taglist[scr][tag2index(t) * 2],
        function (name) if name:len() > 0 then t.name = name end end,
        completion,
        awful.util.getdir("cache") .. "/history_tags", nil,
        function ()
            if initial and t.name == before then
                del(t)
            else
                data[t].initial = true
                set(t)
            end
            awful.hooks.user.call("tags", scr)
        end
    )
end

function send(idx)
    local scr = client.focus.screen or mouse.screen
    local sel = awful.tag.selected(scr)
    local sel_idx = tag2index(sel)
    local target = awful.util.cycle(#tags[scr], sel_idx + idx)
    awful.tag.viewonly(tags[scr][target])
    awful.client.movetotag(tags[scr][target], client.focus)
end

function send_next() send(1) end
function send_prev() send(-1) end

function shift_next() set(awful.tag.selected(), { rel_index = 1 }) end
function shift_prev() set(awful.tag.selected(), { rel_index = -1 }) end

function pos2idx(pos, scr)
    local v = 1
    if pos and scr then
        for i = #tags[scr] , 1, -1 do
            local t = tags[scr][i]
            if data[t].position and data[t].position <= pos then v = i + 1; break end
        end
    end
    return v
end

function select(args)
    for i, a in pairs(args) do
        if a ~= nil then
            return a
        end
    end
end

function set(t, args)
    if not t then return end
    if not args then args = {} end
    local guessed_position = nil

    -- get the name and preset
    local name = args.name or t.name
    local preset = config.tags[name] or {}

    -- try to get position from then name
    if not (args.position or preset.position) and config.guess_position then
        local num = name:find('^[1-9]')
        if num then guessed_position = tonumber(name:sub(1,1)) end
    end

    -- set tag attributes
    t.layout = args.layout or preset.layout or config.defaults.layout
    t.mwfact = args.mwfact or preset.mwfact or config.defaults.mwfact or t.mwfact
    t.nmaster = args.nmaster or preset.nmaster or config.defaults.nmaster or t.nmaster
    t.ncol = args.ncol or preset.ncol or config.defaults.ncol or t.ncol
    t.screen = args.screen or preset.screen or t.screen or mouse.screen
    t.name = name
    data[t].matched = select{ args.matched, data[t].matched }
    data[t].notext = select{ args.notext, preset.notext, data[t].notext, config.defaults.notext }
    data[t].exclusive = select{ args.exclusive, preset.exclusive, data[t].exclusive, config.defaults.exclusive }
    data[t].persist = select{ args.persist, preset.persist, data[t].persist, config.defaults.persist }
    data[t].nopopup = select{ args.nopopup, preset.nopopup, data[t].nopopup, config.defaults.nopopup }
    data[t].leave_kills = select{ args.leave_kills, preset.leave_kills, data[t].leave_kills, config.defaults.leave_kills }
    data[t].solitary = select{ args.solitary, preset.solitary, data[t].solitary, config.defaults.solitary }
    data[t].position = select{ args.position, preset.position, guessed_position, data[t].position }
    data[t].skip_taglist = select{ args.skip_taglist, preset.skip_taglist, data[t].skip_taglist }
    data[t].icon = select{ args.icon and image(args.icon), preset.icon and image(preset.icon), data[t].icon, config.defaults.icon and image(config.defaults.icon) }

    -- calculate desired taglist index
    local index = args.index or preset.index or config.defaults.index
    local rel_index = args.rel_index or preset.rel_index or config.defaults.rel_index
    local sel = awful.tag.selected(t.screen)
    local sel_idx = (sel and tag2index(sel)) or 0 --TODO: what happens with rel_idx if no tags selected
    local t_idx = tag2index(t)
    local limit = (not t_idx and #tags[t.screen] + 1) or #tags[t.screen]
    local idx = nil

    if rel_index then
        idx = awful.util.cycle(limit, (t_idx or sel_idx) + rel_index)
    elseif index then
        idx = awful.util.cycle(limit, index)
    elseif data[t].position then
        idx = pos2idx(data[t].position, t.screen)
        if t_idx and t_idx < idx then idx = idx - 1 end
    elseif config.remember_index and index_cache[t.name] then
        idx = index_cache[t.name]
    elseif not t_idx then
        idx = #tags[t.screen] + 1
    end

    -- if tag already in the table, remove it
    if idx and t_idx then table.remove(tags[t.screen], t_idx) end

    -- if we have an index, insert the notification
    if idx then
        index_cache[t.name] = idx
        table.insert(tags[t.screen], idx, t)
    end


    -- if set()ting upon tag creation, spawn/run
    if data[t].initial then
        local spawn = args.spawn or preset.spawn
        local run = args.run or preset.run or config.defaults.run
        if spawn and not data[t].matched then awful.util.spawn(spawn, scr) end
        if run then run(t) end
        data[t].initial = nil
    end

    -- refresh taglist and return
    awful.hooks.user.call("tags", t.screen)
    return t
end

function add(args)
    if not args then args = {} end
    local scr = args.screen or mouse.screen --FIXME test handling of screen arg more
    local name = args.name or ( args.rename and args.rename .. "_" ) or "_" --FIXME: pretend prompt '_'

    -- initialize a new tag object and its data structure
    local t = tag({ name = name, })
    data[t] = {}
    data[t].initial = true

    -- apply tag settings
    set(t, args)

    -- unless forbidden or if first tag on the screen, show the tag
    if not (data[t].nopopup or args.noswitch) or #tags[scr] == 1 then awful.tag.viewonly(t) end

    -- get the name or rename
    if args.name then t.name = args.name
    elseif args.position then rename(t, args.position .. ":", true, true)
    else rename(t, "", nil, true)
    end

    -- return the tag
    return t
end

function del(tag)
    local scr = (tag and tag.screen) or mouse.screen or 1
    local sel = awful.tag.selected(scr)
    local t = tag or sel
    local idx = tag2index(t)
    if #(t:clients()) > 0 then return end
    index_cache[t.name] = idx
    table.remove(tags[scr], idx)
    data[t] = nil
    t.screen = nil
    if t == sel and #tags[scr] > 0 then
        awful.tag.history.restore(scr)
        if not awful.tag.selected(scr) then awful.tag.viewonly(tags[scr][awful.util.cycle(#tags[scr], idx - 1)])  end
    end
end

function match(c)
    local target_tag, target_screen, target, nopopup, intrusive = nil
    local cls = c.class
    local inst = c.instance
    local role = c.role
    local typ = c.type

    -- try matching client to config.apps
    for i, a in ipairs(config.apps) do
        if a.match then
            for k, w in ipairs(a.match) do
                if
                    (role and role:find(w)) or
                    (inst and inst:find(w)) or
                    (cls and cls:find(w)) or
                    (typ and typ:find(w))
                then
                    if a.tag and config.tags[a.tag] and config.tags[a.tag].screen then
                        target_screen = config.tags[a.tag].screen
                    elseif a.screen then
                        target_screen = a.screen
                    else
                        target_screen = c.screen
                    end
                    if a.tag then target_tag = a.tag end
                    if a.float then c.floating = a.float end
                    if a.geometry then c:fullgeometry(a.geometry) end
                    if a.slave then awful.client.setslave(c) end
                    if a.nopopup then nopopup = true end
                    if a.intrusive then intrusive = true end
                    if a.fullscreen then c.fullscreen = a.fullscreen end
                    if a.honorsizehints then c.honorsizehints = a.honorsizehints end
                end
            end
        end
    end

    -- if not matched or matches currently selected, see if we can leave at the current tag
    local sel = awful.tag.selected(c.screen)
    if #tags[c.screen] > 0 and (not target_tag or (sel and target_tag == sel.name)) then
        if not (data[sel].exclusive or data[sel].solitary) or intrusive then return end
    end

    -- if still unmatched, try guessing the tag
    if not target_tag then
        if config.guess_name and cls then target_tag = cls:lower() else target_tag = "new" end
    end

    -- get/create target tag and move the client
    if target_tag then
        target = name2tag(target_tag, target_screen)
        if not target or (data[target].solitary and #target:clients() > 0 and not intrusive) then
            target = add({ name = target_tag, noswitch = true, matched = true, screen = target_screen }) end
        awful.client.movetotag(target, c)
    end
    if target_screen and c.screen ~= target_screen then c.screen = target_screen end

    -- if target different from current tag, switch unless nopopup
    if target and (not (data[target].nopopup or nopopup) and target ~= sel) then
        awful.tag.viewonly(target)
    end
end

function taglist_label(t, args)
    if not args then args = {} end
    local theme = beautiful.get()
    local fg_focus = args.fg_focus or theme.taglist_fg_focus or theme.fg_focus
    local bg_focus = args.bg_focus or theme.taglist_bg_focus or theme.bg_focus
    local fg_urgent = args.fg_urgent or theme.taglist_fg_urgent or theme.fg_urgent
    local bg_urgent = args.bg_urgent or theme.taglist_bg_urgent or theme.bg_urgent
    local taglist_squares_sel = args.squares_sel or theme.taglist_squares_sel
    local taglist_squares_unsel = args.squares_unsel or theme.taglist_squares_unsel
    local taglist_squares_resize = theme.taglist_squares_resize or args.squares_resize or "true"
    local text
    local background = ""
    local sel = capi.client.focus
    local bg_color = nil
    local fg_color = nil
    if t.selected then
        bg_color = bg_focus
        fg_color = fg_focus
    end
    if sel and sel:tags()[t] then
        if taglist_squares_sel then
            background = "resize=\"" .. taglist_squares_resize .. "\" image=\"" .. taglist_squares_sel .. "\""
        end
    else
        local cls = t:clients()
        if #cls > 0 and taglist_squares_unsel then
            background = "resize=\"" .. taglist_squares_resize .. "\" image=\"" .. taglist_squares_unsel .. "\""
        end
        for k, c in ipairs(cls) do
            if c.urgent then
                if bg_urgent then bg_color = bg_urgent end
                if fg_urgent then fg_color = fg_urgent end
                break
            end
        end
    end
    if bg_color and fg_color then
        text = "<bg "..background.." color='"..bg_color.."'/> <span color='"..awful.util.color_strip_alpha(fg_color).."'>"..awful.util.escape(t.name).."</span> "
    else
        text = " <bg "..background.." />"..awful.util.escape(t.name).." "
    end
    return text, bg_color
end

function taglist_new(scr, label, buttons)
    local w = {}
    local function taglist_update (screen)
        -- Return right now if we do not care about this screen
        if scr ~= screen then return end
        local tags = tags[screen]
        -- Hack: if it has been registered as a widget in a wibox,
        -- it's w.len since __len meta does not work on table until Lua 5.2.
        -- Otherwise it's standard #w.
        local len = (w.len or #w)/2
        -- Add more widgets
        if len < #tags then
            for i = 2*len + 1, 2*#tags, 2 do
                w[i] = widget({ type = "imagebox", name = "taglisti" .. i })
                w[i+1] = widget({ type = "textbox", name = "taglist" .. i })
            end
        -- Remove widgets
        elseif len > #tags then
            for i = 2*#tags + 1, 2*len, 2 do
                w[i] = nil
                w[i+1] = nil
            end
        end
        -- Update widgets text
        for k = 1, 2*#tags, 2 do
            local a, b = label(tags[(k+1)/2])
            if not data[tags[(k+1)/2]].skip_taglist then
                if data[tags[(k+1)/2]] and data[tags[(k+1)/2]].icon then
                    w[k].image = data[tags[(k+1)/2]].icon
                    w[k].bg = b
                else
                    w[k].image = nil
                end
                if not data[tags[(k+1)/2]].notext then
                    w[k+1].text = a
                else
                    w[k+1].text = ""
                end
            else
                w[k+1].text = ""
                w[k].image = nil
            end
            if buttons then
                -- Replace press function by a new one calling with tags as
                -- argument.
                -- This is done here because order of tags can change
                local mbuttons = {}
                for kb, b in ipairs(buttons) do
                    -- Copy object
                    mbuttons[kb] = button(b)
                    mbuttons[kb].press = function () b.press(tags[(k+1)/2]) end
                end
                w[k]:buttons(mbuttons)
                w[k+1]:buttons(mbuttons)
            end
        end
    end
    awful.hooks.arrange.register(taglist_update)
    awful.hooks.tags.register(taglist_update)
    awful.hooks.tagged.register(function (c, tag) taglist_update(c.screen) end)
    awful.hooks.property.register(function (c, prop)
        if c.screen == scr and prop == "urgent" then
            taglist_update(c.screen)
        end
    end)
    taglist_update(scr)
    return w
end

function sweep()
    for s = 1, screen.count() do
        for i, t in ipairs(tags[s]) do
            if #t:clients() == 0 then
                if not data[t].persist and data[t].used then
                    if data[t].deserted or not data[t].leave_kills then
                        del(t)
                    else
                        if not t.selected and data[t].visited then data[t].deserted = true end
                    end
                end
            else
                data[t].used = true
            end
            if data[t] and t.selected then data[t].visited = true end
        end
    end
end

function getpos(pos, switch)
    local v = nil
    local existing = {}
    local selected = nil
    local scr = mouse.screen or 1
    for i = 1, screen.count() do
        local s = awful.util.cycle(screen.count(), scr + i - 1)
        for j, t in ipairs(tags[s]) do
            if data[t].position == pos then
                table.insert(existing, t)
                if t.selected and s == scr then selected = #existing end
            end
        end
    end
    if #existing > 0 then
       if selected then v = existing[awful.util.cycle(#existing, selected + 1)] else v = existing[1] end
    end
    if not v then
        for i, j in pairs(config.tags) do
            if j.position == pos then v = add({ name = i, position = pos, noswitch = not switch }) end
        end
    end
    if not v then
        v = add({ position = pos, rename = pos .. ':', no_selectall = true, noswitch = not switch })
    end
    if switch then
        if mouse.screen ~= v.screen then mouse.screen = v.screen end
        awful.tag.viewonly(v)
        local a = awful.client.focus.history.get(v.screen, 0) --FIXME
        if a then client.focus = a end
    end
    return v
end

function init()
    for i, j in pairs(config.tags) do
        if j.init then add({ name = i, persist = true, screen = j.screen }) end
    end
end

function count(table, element)
    local v = 0
    for i, e in pairs(table) do
        if element == e then v = v + 1 end
    end
    return v
end

function remove_dup(table)
    local v = {}
    for i, entry in ipairs(table) do
        if count(v, entry) == 0 then v[#v+ 1] = entry end
    end
    return v
end

function completion(cmd, cur_pos, ncomp)
    local list = {}

    -- gather names from config.tags
    for n, p in pairs(config.tags) do table.insert(list, n) end

    -- gather names from config.apps
    for i, p in pairs(config.apps) do
        if p.tag then table.insert(list, p.tag) end
    end

    -- gather names from existing tags, starting with the current screen
    for i = 1, screen.count() do
        local s = awful.util.cycle(screen.count(), mouse.screen + i - 1)
        for j, t in pairs(tags[s]) do table.insert(list, t.name) end
    end

    -- gather names from history
    f = io.open(awful.util.getdir("cache") .. "/history_tags")
    for name in f:lines() do table.insert(list, name) end
    f:close()

    -- do nothing if it's pointless
    if cur_pos ~= #cmd + 1 and cmd:sub(cur_pos, cur_pos) ~= " " then
        return cmd, cur_pos
    elseif #cmd == 0 then
        return cmd, cur_pos
    end

    -- find matching indices
    local matches = {}
    for i, j in ipairs(list) do
        if list[i]:find("^" .. cmd:sub(1, cur_pos)) then
            table.insert(matches, list[i])
        end
    end

    -- no matches
    if #matches == 0 then return cmd, cur_pos end

    -- remove duplicates
    matches = remove_dup(matches)

    -- cycle
    while ncomp > #matches do ncomp = ncomp - #matches end

    -- return match and position
    return matches[ncomp], cur_pos
end

function info(t)
    if not t then return end

    local v = "<b>     [ " .. t.name .." ]</b>\n\n" ..
        "  screen = " .. t.screen .. "\n" ..
        "selected = " .. tostring(t.selected) .. "\n" ..
        "  layout = " .. t.layout .. "\n" ..
        "  mwfact = " .. t.mwfact .. "\n"  ..
        " nmaster = " .. t.nmaster .. "\n" ..
        "    ncol = " .. t.ncol .. "\n" ..
        "#clients = " .. #t:clients() .. "\n"

    for op, val in pairs(data[t]) do
        v = v .. "\n" .. op .. " = " .. tostring(val)
    end

    return v
end

awful.hooks.tags.register(sweep)
awful.hooks.arrange.register(sweep)
awful.hooks.clients.register(sweep)
awful.hooks.manage.register(match)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
