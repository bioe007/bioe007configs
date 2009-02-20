--- Shifty: Dynamic tagging library for awesome3-git
-- @author koniu &lt;gkusnierz@gmail.com&gt;
--
-- http://awesome.naquadah.org/wiki/index.php?title=Shifty

-- this version of shifty has been modified by bioe007
-- (perry<dot>hargrave[at]gmail[dot]com)
--
-- TODO:
-- * pressing mod+esc to flip to previous tag after creating a new one.
--      - this 'merges' the two tags instead of flipping back to it
--
-- * if awesome reloads, some stray tags are initialized (eg urxvt ) but their
--      properties are left blank
--
-- * fix the prompt :S
--
--
-- package env

local type = type
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
local pairs = pairs
local io = io
local tostring = tostring
local tonumber = tonumber
local wibox = wibox
-- local print = print
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

-- matches string 'name' to return a tag object 
-- @param name : name of tag to find
-- @param scr : screen to look for tag on
-- @return the tag object, or nil
function name2tag(name, scr)
    local a, b = scr or 1, scr or screen.count()
    for s = a, b do
        for i, t in ipairs(tags[s]) do
            if name == t.name then
                return t 
            end 
        end
    end
end

-- finds index of a tag object
-- @param scr : screen number to look for tag on
-- @param tag : the tag object to find
-- @return the index or zero
function tag2index(scr, tag)
    local tags = screen[scr]:tags()
    for i = 1, #tags do
        if tags[i] == tag then
            return i
        end
    end
    return 0
end

function rename(tag, prefix, no_selectall, initial)
    local theme = beautiful.get()
    local scr = (tag and tag.screen) or mouse.screen or 1

    local t = tag or awful.tag.selected(scr)
    local bg = nil
    local fg = nil
    local text = prefix or t.name or ""
    local before = t.name

    prmptbx = taglist[scr][tag2index(scr,t)*2]

    if t == awful.tag.selected(scr) then 
        bg = theme.bg_focus or '#535d6c'
        fg = theme.fg_urgent or '#ffffff'
    else 
        bg = theme.bg_normal or '#222222'
        fg = theme.fg_urgent or '#ffffff'
    end
    text = '<span color="'..fg..'">'..text..'</span>'

    awful.prompt.run(
        { fg_cursor = fg, bg_cursor = bg, ul_cursor = "single",
          prompt = tag2index(scr,t)..": ", selectall = not no_selectall,  },
        prmptbx,
        function (name) if name:len() > 0 then 
            t.name = name; 
        end
        end, 
        completion,
        awful.util.getdir("cache") .. "/history_tags", nil,
        function ()
            if initial and t.name == before then
                del(t)
            else
                awful.tag.setproperty(t,"initial",true)
                set(t)
            end
            awful.hooks.user.call("tags", scr)
        end
    )
end

-- send a client to tag[idx]
-- @param idx the tag number to send a client to
function send(idx)
    local scr = client.focus.screen or mouse.screen
    local sel = awful.tag.selected(scr)
    local sel_idx = tag2index(scr,sel)
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
    -- local a_tags = screen[scr]:tags()
    if pos and scr then
        for i = #tags[scr] , 1, -1 do
            local t = tags[scr][i]
            if awful.tag.getproperty(t,"position") and awful.tag.getproperty(t,"position") <= pos then v = i + 1; break end
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
    -- FIXME: ? can t.screen not be set with setproperty? seems to break
    t.screen = args.screen or preset.screen or t.screen or mouse.screen -- using .setproperty() seems to break name2index
    
    layout = args.layout or preset.layout or config.defaults.layout
    if layout == nil then
        -- have to have a layout, or else change layout by idx fails later?
        layout = awful.layout.suit.tile
    end
    mwfact = args.mwfact or preset.mwfact or config.defaults.mwfact or t.mwfact
    nmaster = args.nmaster or preset.nmaster or config.defaults.nmaster or t.nmaster
    ncol = args.ncol or preset.ncol or config.defaults.ncol or t.ncol

    -- new using setproperty way
    awful.tag.setproperty(t,"matched", 
                            select{ args.matched, awful.tag.getproperty(t,"matched") } )
    awful.tag.setproperty(t,"notext", 
                            select{ args.notext, preset.notext, 
                                    awful.tag.getproperty(t,"notext"), config.defaults.notext })
    awful.tag.setproperty(t,"exclusive", 
                            select{ args.exclusive, preset.exclusive, 
                                    awful.tag.getproperty(t,"exclusive"), config.defaults.exclusive })
    awful.tag.setproperty(t,"persist", 
                            select{ args.persist, preset.persist, 
                                    awful.tag.getproperty(t,"persist"), config.defaults.persist })
    awful.tag.setproperty(t,"nopopup", 
                            select{ args.nopopup, preset.nopopup, 
                                    awful.tag.getproperty(t,"nopopup"), config.defaults.nopopup })
    awful.tag.setproperty(t,"leave_kills", 
                            select{ args.leave_kills, preset.leave_kills, 
                                    awful.tag.getproperty(t,"leave_kills"), config.defaults.leave_kills })
    awful.tag.setproperty(t,"solitary", 
                            select{ args.solitary, preset.solitary, 
                                    awful.tag.getproperty(t,"solitary"), config.defaults.solitary })
    awful.tag.setproperty(t,"position", 
                            select{ args.position, preset.position, 
                                    guessed_position, awful.tag.getproperty(t,"position" )})
    awful.tag.setproperty(t,"skip_taglist", 
                            select{ args.skip_taglist, preset.skip_taglist, awful.tag.getproperty(t,"skip_taglist") })
    awful.tag.setproperty(t,"icon", 
                            select{ args.icon and image(args.icon), preset.icon and image(preset.icon),
                                    awful.tag.getproperty(t,"icon"), config.defaults.icon and image(config.defaults.icon) })
    awful.tag.setproperty(t, "name", name)
    awful.layout.set(layout,t)
    awful.tag.setmwfact((mwfact or 0.6),t)
    awful.tag.setnmaster((nmaster or 1),t)
    awful.tag.setncol(ncol, t)

    -- calculate desired taglist index
    local index = args.index or preset.index or config.defaults.index
    local rel_index = args.rel_index or preset.rel_index or config.defaults.rel_index
    local sel = awful.tag.selected(scr)
    local sel_idx = (sel and tag2index(t.screen,sel)) or 0 --TODO: what happens with rel_idx if no tags selected
    local t_idx = tag2index(t.screen,t)
    local limit = (not t_idx and #tags[t.screen] + 1) or #tags[t.screen]
    local idx = nil

    if rel_index then
        idx = awful.util.cycle(limit, (t_idx or sel_idx) + rel_index)
    elseif index then
        idx = awful.util.cycle(limit, index)
    elseif awful.tag.getproperty(t,"position") then
        idx = pos2idx(awful.tag.getproperty(t,"position"), t.screen)
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

    -- refresh taglist and return
    awful.hooks.user.call("tags", t.screen)
    return t
end

-- to resort awesomes tags to follow shifty's config positions
--  @param scr : optional screen number [default one]
function tsort(scr)
    local scr = scr or 1
    local a_tags = screen[scr]:tags()

    -- print(#a_tags, #tags[scr])  -- debug
    for i,t in ipairs(a_tags) do
        cfg_t = config.tags[awful.tag.getproperty(t,"name")]
        if cfg_t ~= nil then
            if awful.tag.getproperty(a_tags[i+1], "position") ~= nil then
                if cfg_t.position > awful.tag.getproperty(a_tags[i+1], "position") then
                    -- print("misorderd tag " .. awful.tag.getproperty(t,"name") .. " pos= " ..
                                                -- awful.tag.getproperty(t,"position") .. " index= "..i) -- debug
                    set(t,{rel_index=1})
                end
            end
        end
    end

    -- tags[scr] = screen[scr]:tags()
    -- debugging
    for k,t in pairs(a_tags) do
        -- print("tag " .. awful.tag.getproperty(t,"name") .. " pos= " .. (awful.tag.getproperty(t,"position") or 20) .. " index= "..k)
    end

    for k,t in pairs(tags[scr]) do
        -- print("tag " .. k .. " name= ")
    end
end

function add(args)
    if not args then args = {} end
    local scr = args.screen or mouse.screen --FIXME test handling of screen arg more
    local name = args.name or ( args.rename and args.rename .. "_" ) or "_" --FIXME: pretend prompt '_'

    -- initialize a new tag object and its data structure
    local t = tag( name )
    -- initial flag is used in set() so it must be initialized here
    awful.tag.setproperty(t,"initial", true)

    -- apply tag settings
    set(t, args)

    if config.tags[name] ~= nil then
        local spawn = config.tags[name].spawn or config.defaults.spawn or nil
    end
    local run = args.run or config.defaults.run
    if spawn and args.matched ~= true then awful.util.spawn(spawn, scr) end
    if run then run(t) end
    -- unless forbidden or if first tag on the screen, show the tag
    if not (awful.tag.getproperty(t,"nopopup") or args.noswitch) or #tags[scr] == 1 then awful.tag.viewonly(t) end

    -- get the name or rename
    if args.name then t.name = args.name
    elseif args.position then rename(t, args.position .. ":", true, true)
    else rename(t, "", nil, true)
    end

    -- return the tag
    return t
end

function del(tag)
    -- should a tag ever be deleted if #tags[scr] < 1 ?
    local scr = mouse.screen or 1
    local sel = awful.tag.selected(scr)
    local t = tag or sel
    local idx = tag2index(scr,t)

    -- print("shifty.del():380: number of tags= ", #screen[scr]:tags())
    if #screen[scr]:tags() > 1 then
        -- don't wipe tags if active clients on them?
        -- if #(t:clients()) > 0 then print("clients here"); return end

        index_cache[t.name] = idx

        if t == sel and #screen[scr]:tags() > 0 then
            awful.tag.history.restore(scr)
            if not awful.tag.selected(scr) then awful.tag.viewonly(tags[scr][awful.util.cycle(#tags[scr], idx - 1)])  end
        end

        table.remove(tags[scr], idx)
        t.screen = nil
        t = nil
        awful.tag.history.update(scr)
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
                    if a.tag then
                        target_tag = a.tag
                    end
                    if a.float then  -- set client floating
                        awful.client.floating.set( c, true)
                        if config.defaults.floatBars then       -- add a titlebar if requested in config.defaults
                            awful.titlebar.add( c, { modkey = modkey } )
                        end
                    end
                    if a.geometry ~=nil then c:fullgeometry(a.geometry) end
                    if a.slave ~=nil then awful.client.setslave(c) end
                    if a.nopopup ~=nil then nopopup = true end
                    if a.intrusive ~=nil then intrusive = true end
                    if a.fullscreen ~=nil then c.fullscreen = a.fullscreen end
                    if a.honorsizehints ~=nil then c.honorsizehints = a.honorsizehints end
                end
            end
        end
    end

    -- if not matched or matches currently selected, see if we can leave at the current tag
    local sel = awful.tag.selected(c.screen)
    if #tags[c.screen] > 0 and (not target_tag or (sel and target_tag == sel.name)) then
        if not (awful.tag.getproperty(sel,"exclusive") or awful.tag.getproperty(sel,"solitary")) or intrusive or typ == "dialog" then 
            return
        end 
    end

    -- if still unmatched, try guessing the tag
    if not target_tag then
        if config.guess_name and cls then target_tag = cls:lower() else target_tag = "new" end
    end

    -- get/create target tag and move the client
    if target_tag then
        target = name2tag(target_tag, target_screen)
        if not target or (awful.tag.getproperty(target,"solitary") and #target:clients() > 0 and not intrusive) then
            target = add({ name = target_tag, noswitch = true, matched = true, screen = target_screen }) end
        awful.client.movetotag(target, c)
    end
    if target_screen and c.screen ~= target_screen then c.screen = target_screen end

    -- if target different from current tag, switch unless nopopup
    if target and (not (awful.tag.getproperty(target,"nopopup") or nopopup) and target ~= sel) then
        awful.tag.viewonly(target)
    end
end

function sweep()
    for s = 1, screen.count() do
        for i, t in ipairs(tags[s]) do
            if #t:clients() == 0 then
                if not awful.tag.getproperty(t,"persist") and awful.tag.getproperty(t,"used") then
                    if awful.tag.getproperty(t,"deserted") or not awful.tag.getproperty(t,"leave_kills") then
                        del(t)
                    else
                        if not t.selected and awful.tag.getproperty(t,"visited") then awful.tag.setproperty(t,"deserted", true) end
                    end
                end
            else
                awful.tag.setproperty(t,"used",true)
            end
            if t.selected then awful.tag.setproperty(t,"visited",true) end
        end
    end
end

-- getpos - returns a tag to match position
--      * originally this function did a lot of client stuff, i think its
--      * better to leave what can be done by awful to be done by awful
--      *           -perry
-- @param pos : the index to find
-- @return v : the tag (found or created) at position == 'pos'
function getpos(pos)
    local v = nil
    local existing = {}
    local selected = nil
    local scr = mouse.screen or 1
    -- search for existing tag assigned to pos
    for i = 1, screen.count() do
        local s = awful.util.cycle(screen.count(), scr + i - 1)
        for j, t in ipairs(screen[s]:tags()) do
            if awful.tag.getproperty(t,"position") == pos then
                table.insert(existing, t)
                if t.selected and s == scr then selected = #existing end
            end
        end
    end
    if #existing > 0 then
        -- if makeing another of an existing tag, return the end of the list
       if selected then v = existing[awful.util.cycle(#existing, selected + 1)] else v = existing[1] end
    end
    if not v then
        -- search for preconf with 'pos' and create it
        for i, j in pairs(config.tags) do
            if j.position == pos then v = add({ name = i, position = pos, noswitch = not switch }) end
        end
    end
    if not v then
        -- not existing, not preconfigured
        v = add({ position = pos, rename = pos .. ':', no_selectall = true, noswitch = not switch })
    end
    return v
end

-- init :: search shifty.config.tags for initial set of tags to open
function init()
    for i, j in pairs(config.tags) do
        if j.init then 
            add({ name = i, persist = true, screen = j.screen, layout = j.layout, mwfact = j.mwfact }) 
        end
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

-- function info(t)
    -- if not t then return end
-- 
    -- local v = "<b>     [ " .. t.name .." ]</b>\n\n" ..
        -- "  screen = " .. t.screen .. "\n" ..
        -- "selected = " .. tostring(t.selected) .. "\n" ..
        -- "  layout = " .. t.layout .. "\n" ..
        -- "  mwfact = " .. t.mwfact .. "\n"  ..
        -- " nmaster = " .. t.nmaster .. "\n" ..
        -- "    ncol = " .. t.ncol .. "\n" ..
        -- "#clients = " .. #t:clients() .. "\n"
-- 
    -- for op, val in pairs(data[t]) do
        -- v = v .. "\n" .. op .. " = " .. tostring(val)
    -- end
-- 
    -- return v
-- end

awful.hooks.tags.register(sweep)
awful.hooks.arrange.register(sweep)
awful.hooks.clients.register(sweep)
awful.hooks.manage.register(match)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
