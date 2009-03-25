-- just helps troubleshooting when re-loading rc.lua (see output on console) 
print("Entered rc.lua: " .. os.time())
require("awful")
require("beautiful")
require("wicked")
require("revelation")
require("naughty")
require("shifty")
require("mocp")
require("calendar")
require("battery")
require("markup")
require("fs")
require("volume")
print("cachedir= " .. awful.util.getdir("cache"))

-- {{{ Variable definitions
-- This is a file path to a theme file which will defines colors.
theme_path = "/home/perry/.config/awesome/themes/grey/theme"
-- Initialize theme (colors).
beautiful.init(theme_path)
icon_path = beautiful.iconpath 
settings = {}
settings.new_become_master = false

settings.apps = {}
settings.apps.terminal = "urxvtc"
settings.apps.browser = "firefox"
settings.apps.mail = "thunderbird"
settings.apps.filemgr = "pcmanfm"
settings.apps.music = "mocp --server"
settings.apps.editor = os.getenv("EDITOR") or "vim"
settings.apps.editor_cmd = settings.apps.terminal .. " -e " .. settings.apps.editor

-- Default modkey.
modkey = "Mod4"
shifty.modkey = modkey

--{{{ layouts
layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.max,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating
}
--}}}

--{{{ configured tags
shifty.config.tags = {
    ["w2"] =     { layout = awful.layout.suit.max,          mwfact=0.60, exclusive = false, solitary = false, position = 1, init = true, screen = 2} ,
    ["w1"] =     { layout = awful.layout.suit.max,          mwfact=0.60, exclusive = false, solitary = false, position = 1, init = true, screen = 1, slave = true } ,
    ["ds"] =     { layout = awful.layout.suit.max,          mwfact=0.70, exclusive = false, solitary = false, position = 2, persist = false, nopopup = false, slave = false } ,
    ["web"] =    { layout = awful.layout.suit.tile.bottom,  mwfact=0.65, exclusive = true , solitary = true , position = 4, spawn = settings.apps.browser  } ,
    ["dz"] =     { layout = awful.layout.suit.tile,         mwfact=0.64, exclusive = false, solitary = false, position = 3, nopopup = true, leave_kills = true, } ,
    ["mail"] =   { layout = awful.layout.suit.tile,         mwfact=0.55, exclusive = false, solitary = false, position = 5, spawn = settings.apps.mail, slave = true     } ,
    ["vbx"] =    { layout = awful.layout.suit.tile.bottom,  mwfact=0.75, exclusive = true , solitary = true , position = 6,} ,
    ["media"] =  { layout = awful.layout.suit.float,                     exclusive = false, solitary = false, position = 8 } ,
    ["office"] = { position = 9, layout = awful.layout.suit.tile} ,
}
--}}}

--{{{ application matching rules
shifty.config.apps = {
         { match = { "Navigator","Vimperator","Gran Paradiso"              } , tag = "web"                            } ,
         { match = { "Shredder.*"                                          } , tag = "mail"                           } ,
         { match = { "OpenOffice.*"                                        } , tag = "office"                         } ,
         { match = { "pcb","gschem"                                        } , tag = "dz", slave = false              } ,
         { match = { "PCB_Log","Status"                                    } , tag = "dz", slave = true               } ,
         { match = { "acroread","Apvlv"                                    } , tag = "ds",                            } ,
         { match = { "VBox.*","VirtualBox.*"                               } , tag = "vbx",                           } ,
         { match = { "Mplayer.*","Mirage","gimp","gtkpod","Ufraw","easytag"} , tag = "media",         nopopup = true, } ,
         { match = { "XDosEmu", "MPlayer", "Gnuplot", "galculator"         } , float = true                           } ,
         { match = { "VirtualBox",                                         } , float = true,                          } ,
         { match = { "urxvt","URxvt", "sakura"                             } , honorsizehints = false, slave = true   } ,
}
--}}}

shifty.config.defaults={  layout = awful.layout.suit.tile.bottom, ncol = 1, floatBars=true,
                            run = function(tag) 
                            naughty.notify({ 
                              text = markup.fg( beautiful.fg_normal,  markup.font("monospace",markup.fg(beautiful.fg_sb_hi, 
                                                "Shifty Created: "
                                                  ..(awful.tag.getproperty(tag,"position") or shifty.tag2index(mouse.screen,tag))..
                                                    " : "..tag.name))) 
                            }) end,
                       }

-- }}} 

-- {{{ -- OWN functions

--{{{ toggleTitlebar :: add a titlebar
-- toggles wether client has titlebar or not
function toggleTitlebar(c)
  if awful.layout.get(c.screen) == "floating" then 
    -- awful.titlebar.add(c, { modkey = modkey }) 
    awful.titlebar.add(c, { modkey = modkey } ) 
  else
    if c.titlebar then
      awful.titlebar.remove(c)
    end
  end
end
-- }}}

-- }}}

-- {{{ -- Statusbar, menus & Widgets
-- Create a systray
mysystray = widget({ type = "systray", align = "right" })

--{{{ -- WIBOX for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons =  { button({ }, 1, awful.tag.viewonly),
                      button({ modkey }, 1, awful.client.movetotag),
                      button({ }, 3, function () if instance then instance:hide() end instance = awful.menu.clients({ width=250 }) end),
                      -- button({ }, 3, function (tag) tag.selected = not tag.selected end),
                      button({ modkey }, 3, awful.client.toggletag),
                      button({ }, 4, awful.tag.viewnext),
                      button({ }, 5, awful.tag.viewprev) }
mytasklist = {}
mytasklist.buttons = { button({ }, 1, function (c) client.focus = c; c:raise() end),
                       button({ }, 3, function () awful.menu.clients({ width=250 }) end),
                       button({ }, 4, function () awful.client.focus.byidx(1); client.focus:raise() end),
                       button({ }, 5, function () awful.client.focus.byidx(-1); client.focus:raise() end) }

widget_spacer_l = widget({type = "textbox", name = "widget_spacer", align = "left" })
widget_spacer_l.width = 5 
widget_spacer_r  = widget({type = "textbox", name = "widget_spacer", align = "right" })
widget_spacer_r.width = 5 
---}}}

-- {{{ -- DATE widget
datewidget = widget({
    type = 'textbox',
    name = 'datewidget',
    align = 'right',
})

datewidget.mouse_enter = function() calendar.add_calendar() end
datewidget.mouse_leave = function() calendar.remove_calendar() end

datewidget:buttons({ 
  button({ }, 4, function() calendar.add_calendar(-1) end),
  button({ }, 5, function() calendar.add_calendar(1) end), 
})
wicked.register(datewidget, wicked.widgets.date,
   markup.fg(beautiful.fg_sb_hi, '%k:%M'))

-- }}}

-- {{{ -- CPU widget
cpuwidget = widget({ type = 'textbox', name = 'cpuwidget', align = 'right' })
cpuwidget.width = 40
wicked.register(cpuwidget, wicked.widgets.cpu, 'cpu:' .. markup.fg(beautiful.fg_sb_hi, '$1'))
-- }}}

-- {{{ -- MEMORY widgets
memwidget = widget({ type = 'textbox', name = 'memwidget', align = 'right' })
memwidget.width = 45

wicked.register(memwidget, wicked.widgets.mem, 'mem:' ..  markup.fg(beautiful.fg_sb_hi,'$1'))
-- }}}

-- {{{ -- MOCP Widget
mocpwidget = widget({ type = 'textbox', name = 'mocpwidget', align = 'right'})
mocp.setwidget(mocpwidget)
mocpwidget:buttons({
    button({ }, 1, function () mocp.play(); mocp.popup() end ),
    button({ }, 2, function () awful.util.spawn('mocp --toggle-pause') end),
    button({ }, 4, function () mocp.play(); mocp.popup() end),
    button({ }, 3, function () awful.util.spawn('mocp --previous'); mocp.popup() end),
    button({ }, 5, function () awful.util.spawn('mocp --previous'); mocp.popup() end)
})
mocpwidget.mouse_enter = function() awful.hooks.timer.register(1,mocp.popup) end
mocpwidget.mouse_leave = function() awful.hooks.timer.unregister(mocp.popup) end
---}}}

-- {{{ -- FSWIDGET
fswidget = widget({ type = "textbox", name = "fswidget", align = "right" })
fs.init( fswidget, 
        { interval = 59, 
          parts = {   ['sda7'] = {label = "/"},
                      ['sda5'] = {label = "d"} } })
-- }}}

-- {{{ -- BATTERY 
batterywidget = widget({ type = "textbox", name = "batterywidget", align = "right" })
battery.init(batterywidget)
awful.hooks.timer.register(50, battery.info)
-- }}}

-- {{{ volume widget
pb_volume =  widget({ type = "progressbar", name = "pb_volume", align = "right" })
volume.init(pb_volume)
pb_volume:buttons({
  button({ }, 1, function () volume.vol("up","5") end),
  button({ }, 4, function () volume.vol("up","1") end),
  button({ }, 3, function () volume.vol("down","5") end),
  button({ }, 5, function () volume.vol("down","1") end),
  button({ }, 2, function () volume.vol() end),
})
-- }}}

--{{{ -- STATUSBAR
for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = widget({ type = "textbox", align = "left" })

    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = widget({ type = "imagebox", align = "left" })
    mylayoutbox[s]:buttons({ button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                             button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                             button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                             button({ }, 5, function () awful.layout.inc(layouts, -1) end) })
    -- Create a taglist widget
    -- mytaglist[s] = shifty.taglist_new(s, shifty.taglist_label, mytaglist.buttons)
    mytaglist[s] = awful.widget.taglist.new(s, awful.widget.taglist.label.all, mytaglist.buttons)
    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist.new(function(c)
                                                  return awful.widget.tasklist.label.currenttags(c, s)
                                              end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = wibox({ position = "top", fg = beautiful.fg_normal, bg = beautiful.bg_normal })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = { 
        mypromptbox[s], widget_spacer_l,
        mylayoutbox[s], widget_spacer_l,
        mytaglist[s], widget_spacer_l,
        mytasklist[s], widget_spacer_r,
        s == 1 and fswidget or nil, s == 1 and widget_spacer_r,
        s == 1 and batterywidget, s == 1 and widget_spacer_r,
        s == 1 and memwidget, s == 1 and widget_spacer_r,
        s == 1 and cpuwidget, s == 1 and widget_spacer_r,
        s == 1 and mocpwidget, 
        s == 1 and pb_volume, s == 1 and widget_spacer_r,
        s == 1 and datewidget,s == 1 and widget_spacer_r, s == 1 and mysystray or nil
    } 
    mywibox[s].screen = s
end
-- }}}

-- shifty initialization needs to go after the taglist has been created
shifty.taglist = mytaglist
shifty.init()
-- }}}

-- {{{ Mouse bindings
root.buttons({
    button({ }, 4, awful.tag.viewnext),
    button({ }, 5, awful.tag.viewprev)
})
-- }}}

-- {{{ Key bindings
globalkeys = {}
clientkeys = {}

-- {{{ - TAGS BINDINGS
for i=1, ( shifty.config.maxtags or 9 ) do
  table.insert(globalkeys, key({ modkey }, i, function () local t =  awful.tag.viewonly(shifty.getpos(i)) end))
  table.insert(globalkeys, key({ modkey, "Control" }, i, function () local t = shifty.getpos(i); t.selected = not t.selected end))
  table.insert(globalkeys, key({ modkey, "Control", "Shift" }, i, function () if client.focus then awful.client.toggletag(shifty.getpos(i)) end end))
  table.insert(globalkeys, key({ modkey, "Shift" }, i,
    function () 
      if client.focus then 
        t = shifty.getpos(i)
        awful.client.movetotag(t)
        awful.tag.viewonly(t)
      end 
    end))
end

table.insert(globalkeys, key({ modkey }, "space", awful.tag.viewnext))  -- move to next tag
table.insert(globalkeys, key({ modkey, "Shift" }, "space", awful.tag.viewprev)) -- move to previous tag

-- revelation
table.insert(globalkeys, key({ modkey }, "e", revelation.revelation ))

-- shiftycentric
table.insert(globalkeys, key({ modkey }, "Escape",  awful.tag.history.restore)) -- move to prev tag by history
table.insert(globalkeys, key({ modkey, "Shift" }, "n", shifty.send_prev)) -- move client to prev tag
table.insert(globalkeys, key({ modkey }, "n", shifty.send_next))  -- move client to next tag
table.insert(globalkeys, key({ modkey,"Shift" }, "r",  shifty.rename)) -- rename a tag
table.insert(globalkeys, key({ modkey }, "d", shifty.del)) -- delete a tag
table.insert(globalkeys, key({ modkey }, "a",     shifty.add)) -- creat a new tag
table.insert(globalkeys, key({ modkey,"Shift"}, "a", function() shifty.add({ nopopup = true }) end)) -- nopopup new tag
---}}}

-- {{{ - APPLICATIONS
-- Standard program
table.insert(globalkeys, key({ modkey }, "Return", function () awful.util.spawn(settings.apps.terminal) end))

-- application launching and controlling, Win+Alt
table.insert(globalkeys, key({ modkey},"w", function () 
  for k,v in pairs(shifty.tags[1]) do
    if v.name == "web" then
      awful.tag.viewonly(v)
      return
    end
  end
  awful.util.spawn(settings.apps.browser) end))
table.insert(globalkeys, key({ modkey },"m", function () 
  for k,v in pairs(shifty.tags[1]) do
    if v.name == "mail" then
      awful.tag.viewonly(v)
      return
    end
  end
  awful.util.spawn(settings.apps.mail) end))
table.insert(globalkeys, key({ modkey, "Mod1" },"f", function () awful.util.spawn(settings.apps.filemgr) end))
table.insert(globalkeys, key({ modkey, "Mod1" },"c", function () awful.util.spawn("galculator") end))
table.insert(globalkeys, key({ modkey, "Mod1", "Shift" },"v", function ()
  for k,v in pairs(shifty.tags[1]) do
    if v.name == "vbox" then
      awful.tag.viewonly(v)
      return
    end
  end
  awful.util.spawn('VBoxSDL -vm xp2') end))
table.insert(globalkeys, key({ modkey },"g", function ()
  for k,v in pairs(shifty.tags[1]) do
    if v.name == "dz" then
      awful.tag.viewonly(v)
      return
    end
  end
  awful.util.spawn('gschem') end))
table.insert(globalkeys, key({ modkey, "Mod1", "Shift" } ,"g", function () awful.util.spawn('gimp') end))
table.insert(globalkeys, key({ modkey, "Mod1" },"o", function () awful.util.spawn('/home/perry/.bin/octave-start.sh') end))
table.insert(globalkeys, key({ modkey, "Mod1" },"v", function () awful.util.spawn('/home/perry/.bin/vim-start.sh') end))
table.insert(globalkeys, key({ modkey, "Mod1" },"i", function () awful.util.spawn('gtkpod') end))
-- }}}

-- {{{ - POWER
table.insert(globalkeys, key({ modkey, "Mod1" },"h", function () awful.util.spawn('sudo pm-hibernate') end))
table.insert(globalkeys, key({ modkey, "Mod1" },"s", function () 
  os.execute('sudo pm-suspend')
  awful.util.spawn('slock')
end))
table.insert(globalkeys, key({ modkey, "Mod1" },"r", function () awful.util.spawn('sudo reboot') end))
table.insert(globalkeys, key({ modkey, "Mod1" },"l", function () awful.util.spawn('slock') end))
-- }}} 

-- {{{ - MEDIA
table.insert(globalkeys, key({ modkey, "Mod1" },"p", mocp.play ))
table.insert(globalkeys, key({ },"XF86AudioPlay", mocp.play ))
table.insert(globalkeys, key({ modkey },"Down", function() mocp.play(); mocp.popup() end ))
table.insert(globalkeys, key({ modkey },"Up", function () awful.util.spawn('mocp --previous');mocp.popup() end))
table.insert(globalkeys, key({ }, "XF86AudioRaiseVolume", function() volume.vol("up","5") end))
table.insert(globalkeys, key({ }, "XF86AudioLowerVolume", function() volume.vol("down","5") end))
table.insert(globalkeys, key({ modkey }, "XF86AudioRaiseVolume",function() volume.vol("up","2")end))
table.insert(globalkeys, key({ modkey }, "XF86AudioLowerVolume", function() volume.vol("down","2")end))
table.insert(globalkeys, key({ },"XF86AudioMute", function() volume.vol() end))
table.insert(globalkeys, key({ },"XF86AudioPrev", function () awful.util.spawn('mocp -r') end))
table.insert(globalkeys, key({ },"XF86AudioNext", mocp.play ))
table.insert(globalkeys, key({ },"XF86AudioStop", function () awful.util.spawn('mocp --stop') end))
-- }}} 

-- {{{ - SPECIAL keys
table.insert(globalkeys, key({ modkey, "Control" }, "r", function ()
  mypromptbox[mouse.screen].text =
  awful.util.escape(awful.util.restart())
end))
table.insert(globalkeys, key({ modkey, "Shift" }, "q", awesome.quit))
-- }}} 

-- {{{ - CLIENT MANIPULATION
table.insert(clientkeys, key({ modkey, "Shift" },"t", function () toggleTitlebar(client.focus) end)) -- show client on all tags
table.insert(clientkeys, key({ modkey, "Shift" },"0", function () client.focus.sticky = not client.focus.sticky end)) -- show client on all tags
table.insert(clientkeys, key({ modkey }, "m", function (c) c.maximized_horizontal = not c.maximized_horizontal         -- maximize client
                                                           c.maximized_vertical = not c.maximized_vertical end))
table.insert(clientkeys, key({ modkey, "Shift" }, "c", function (c) c:kill() end))                                      -- kill client
table.insert(clientkeys, key({ modkey }, "j", function () awful.client.focus.byidx(1); client.focus:raise() end))       -- change focus
table.insert(clientkeys, key({ modkey }, "k", function () awful.client.focus.byidx(-1);  client.focus:raise() end))
table.insert(clientkeys, key({ modkey, "Shift" }, "j", function () awful.client.swap.byidx(1) end))     -- change order
table.insert(clientkeys, key({ modkey, "Shift" }, "k", function () awful.client.swap.byidx(-1) end))
table.insert(clientkeys, key({ modkey, }, "s", function () awful.screen.focus(1) end)) -- switch screen focus
table.insert(clientkeys, key({ modkey, "Control" }, "space", awful.client.togglefloating))              -- toggle client float
table.insert(clientkeys, key({ modkey, "Control" }, "Return", function () client.focus:swap(awful.client.master()) end))  -- switch focused client with master
table.insert(clientkeys, key({ modkey, "Shift" }, "s", awful.client.movetoscreen))   -- switch client to other screen
table.insert(clientkeys, key({ modkey }, "Tab", function() awful.client.focus.history.previous(); client.focus:raise() end )) -- toggle client focus history
table.insert(clientkeys, key({ modkey }, "u", awful.client.urgent.jumpto))      -- jump to urgent clients
-- table.insert(clientkeys, key({ modkey, "Shift" }, "r", function () client.focus:redraw() end))		-- redraw clients
-- cycle client focus and position
table.insert(clientkeys, key({ "Mod1" }, "Tab", function () 
  local allclients = awful.client.visible(client.focus.screen)
  for i,v in ipairs(allclients) do
    if allclients[i+1] then
      allclients[i+1]:swap(v)
    end
  end
  awful.client.focus.byidx(-1)
end))
shifty.config.clientkeys = clientkeys
-- }}}

-- {{{ - LAYOUT MANIPULATION
table.insert(globalkeys, key({ modkey }, "l", function () awful.tag.incmwfact(0.05) end))
table.insert(globalkeys, key({ modkey }, "h", function () awful.tag.incmwfact(-0.05) end))
table.insert(globalkeys, key({ modkey, "Control" }, "l", function () awful.tag.incmwfact(0.05) end))
table.insert(globalkeys, key({ modkey, "Control" }, "h", function () awful.tag.incmwfact(-0.05) end))

table.insert(globalkeys, key({ modkey, "Shift" }, "h", function () awful.tag.incnmaster(1) end))
table.insert(globalkeys, key({ modkey, "Shift" }, "l", function () awful.tag.incnmaster(-1) end))
-- table.insert(globalkeys, key({ modkey, "Control" }, "h", function () awful.tag.incncol(1) end))
-- table.insert(globalkeys, key({ modkey, "Control" }, "l", function () awful.tag.incncol(-1) end))
table.insert(globalkeys, key({ modkey, "Mod1" }, "l", function () awful.layout.inc(layouts, 1) end))
table.insert(globalkeys, key({ modkey, "Mod1","Shift" }, "l", function () awful.layout.inc(layouts, -1) end))
-- }}}

-- {{{ - PROMPT
table.insert(globalkeys, key({ modkey }, "F1", 
    function ()
        awful.prompt.run({ prompt = markup.fg( beautiful.fg_sb_hi," >> ") }, mypromptbox[mouse.screen], awful.util.spawn, awful.completion.shell,
        awful.util.getdir("cache") .. "/history")
    end))

table.insert(globalkeys, key({ modkey }, "F4", 
    function ()
        awful.prompt.run({ prompt = markup.fg( beautiful.fg_sb_hi," L> ") }, mypromptbox[mouse.screen], awful.util.eval, awful.prompt.bash,
        awful.util.getdir("cache") .. "/history_eval")
    end))
    
table.insert(globalkeys, key({ modkey, "Ctrl" }, "i", 
    function ()
        local s = mouse.screen
        if mypromptbox[s].text then
            mypromptbox[s].text = nil
        elseif client.focus then
            mypromptbox[s].text = nil
            if client.focus.class then
                mypromptbox[s].text = "Class: " .. client.focus.class .. " "
            end
            if client.focus.instance then
                mypromptbox[s].text = mypromptbox[s].text .. "Instance: ".. client.focus.instance .. " "
            end
            if client.focus.role then
                mypromptbox[s].text = mypromptbox[s].text .. "Role: ".. client.focus.role
            end
        end
    end))

-- }}}

-- Set keys
root.keys(globalkeys)

--- }}}

-- {{{ Hooks
-- Hook function to execute when focusing a client.
awful.hooks.focus.register(function (c)
  c.urgent = false
  if not awful.client.ismarked(c) then
      c.border_color = beautiful.border_focus
  end
end)

-- Hook function to execute when unfocusing a client.
awful.hooks.unfocus.register(function (c)
  if not awful.client.ismarked(c) then
      c.border_color = beautiful.border_normal
  end
end)

-- Hook function to execute when marking a client
awful.hooks.marked.register(function (c)
  c.border_color = beautiful.border_marked
end)

-- Hook function to execute when unmarking a client.
awful.hooks.unmarked.register(function (c)
  c.border_color = beautiful.border_focus
end)

-- Hook function to execute when the mouse enters a client.
awful.hooks.mouse_enter.register(function (c)
  -- Sloppy focus, but disabled for magnifier layout
  if awful.layout.get(c.screen) ~= "magnifier"
    and awful.client.focus.filter(c) then
    client.focus = c
  end
end)

-- Hook function to execute when arranging the screen (tag switch, new client, etc)
awful.hooks.arrange.register(function (screen)
  local layout = awful.layout.getname(awful.layout.get(screen))
  if layout and beautiful["layout_" ..layout] then
    mylayoutbox[screen].image = image(beautiful["layout_" .. layout])
  else
    mylayoutbox[screen].image = nil
  end
  -- Give focus to the latest client in history if no window has focus
  -- or if the current window is a desktop or a dock one.
  if not client.focus then
    local c = awful.client.focus.history.get(screen, 0)
    if c then client.focus = c end
  end
  -- dwm border mod
  local tiledclients = awful.client.tiled(screen)
  if (#tiledclients == 0 ) then return end
  if (#tiledclients == 1) or (layout == 'max') then
    tiledclients[1].border_width = 0
  else
    for unused, current in pairs(tiledclients) do
      current.border_width = beautiful.border_width
    end
  end

end)

-- }}}

-- vim:set filetype=lua fdm=marker tabstop=2 shiftwidth=2 expandtab smarttab autoindent smartindent: --
