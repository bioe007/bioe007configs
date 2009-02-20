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

print("cachedir= " .. awful.util.getdir("cache"))
-- volumous.init("/home/perry/.config/awesome/themes/bio/vol_images/", 30, 30)

-- {{{ Variable definitions
-- This is a file path to a theme file which will defines colors.
theme_path = "/home/perry/.config/awesome/themes/grey/theme"
-- Initialize theme (colors).
beautiful.init(theme_path)
icon_path = beautiful.iconpath 
settings = {}
settings.new_become_master = false
settings.showmwfact = true

settings.apps = {}
settings.apps.terminal = "urxvtc"
settings.apps.browser = "firefox"
settings.apps.mail = "thunderbird"
settings.apps.filemgr = "pcmanfm"
settings.apps.music = "mocp --server"
settings.apps.editor = os.getenv("EDITOR") or "vim"
settings.apps.editor_cmd = settings.apps.terminal .. " -e " .. settings.apps.editor

settings.sys = {}
settings.sys.battwarn = false

-- Default modkey.
modkey = "Mod4"
mytaglist = {}

-- Define if we want to use titlebar on all applications.
use_titlebar = false

-- Table of layouts to cover with awful.layout.inc, order matters.
-- layouts = {}
layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.max,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating
}

shifty.config.tags = {
    ["w1"] =     { layout = awful.layout.suit.tile.bottom,  mwfact=0.60, exclusive = false, solitary = false, init = true, position = 1, screen = 1, } ,
    ["ds"] =     { layout = awful.layout.suit.max,          mwfact=0.70, exclusive = false, solitary = false, position = 2, persist = false, nopopup = false,               } ,
    ["dz"] =     { layout = awful.layout.suit.tile,         mwfact=0.64, exclusive = false, nopopup = true, leave_kills = true,                                                               } ,
    ["web"] =    { layout = awful.layout.suit.tile.bottom,  mwfact=0.65, exclusive = true , solitary = true, position = 4, spawn = settings.apps.browser  } ,
    ["mail"] =   { layout = awful.layout.suit.tile.bottom,  mwfact=0.55, exclusive = false, solitary = false,position = 5,spawn = settings.apps.mail     } ,
    ["vbx"] =    { layout = awful.layout.suit.tile.bottom,  mwfact=0.75, exclusive = true , solitary = true,                                                                } ,
    ["media"] =  { layout = awful.layout.suit.float,                     exclusive = false, solitary = false,                                                           } ,
    ["office"] = { rel_index = 1, layout = awful.layout.suit.tile                                                                    } ,
}

shifty.config.apps = {
         { match = { "Navigator","Vimperator"                              } , tag = "web"                            } ,
         { match = { "Shredder.*"                                          } , tag = "mail",                          } ,
         { match = { "OpenOffice.*"                                        } , tag = "office",                        } ,
         { match = { "pcb","gschem","PCB_Log"                              } , tag = "dz",                            } ,
         { match = { "acroread","Apvlv"                                    } , tag = "ds",                            } ,
         { match = { "VBox.*","VirtualBox.*"                               } , tag = "vbx",                           } ,
         { match = { "Mplayer.*","Mirage","gimp","gtkpod","Ufraw"          } , tag = "media",         nopopup = true, } ,
         { match = { "XDosEmu", "MPlayer", "gimp", "Gnuplot", "galculator" } , float = true                           } ,
         { match = { "VirtualBox","glxgears",                              } , float = true,                           } ,
}

shifty.config.defaults = {
    layout = awful.layout.suit.tile.bottom, ncol = 1, floatBars=true,
    run = function(tag) 
        naughty.notify({ text = markup.fg( beautiful.fg_normal,  markup.font("monospace",markup.fg(beautiful.fg_sb_hi, 
                            "Shifty Created: "..shifty.tag2index(mouse.screen,tag).." : "..tag.name))) }) 
    end,
}

-- }}} 

-- {{{ -- OWN functions

function hideFloats()
    local currtag = {}
    local clients = {}
    currtag = awful.tag.selectedlist(1)
    clients = awful.client.visible(1)
end


-- {{{ setMwbox - someday this may work :(
local mwbox = nil
function setMwbox(s)
    print("creating box: " .. s)
    if mwbox ~= nil then 
        -- print("mwbox == " .. mwbox.box.screen)
        naughty.destroy(mwbox) 
        mwbox = nil
    else
        print("mwbox == nil")
    end 
    mwbox = naughty.notify({ 
        text=s,
        timeout = 1,
        hover_timeout = 0.5,
        screen = 1,
        width = 120,
        bg = beautiful.bg_focus
    })
    print("post box: ")
    print(mwbox)
end
---}}}

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

-- {{{ Wibox & WIDGETS
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", settings.apps.terminal .. " -e man awesome" },
   { "edit config", settings.apps.editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu.new({ items = { { "awesome", myawesomemenu, icon_path.."/awesome16.png" },
                                        { "open terminal", terminal } }
                           })

mylauncher = awful.widget.launcher({ image = icon_path.."awesome48.png",
                                     menu = mymainmenu })

-- Create a systray
mysystray = widget({ type = "systray", align = "right" })


---{{{ WIBOX for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
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
   markup.fg(beautiful.fg_sb_hi, '%k:%M %D'))

-- }}}

-- {{{ -- CPU widgets
cpuwidget = widget({ type = 'textbox', name = 'cpuwidget', align = 'right' })
cpuwidget.width = 51
wicked.register(cpuwidget, wicked.widgets.cpu, 'cpu:' .. markup.fg(beautiful.fg_sb_hi, '$1'))

cpugraphwidget1 = widget({ type = 'graph',
    name = 'cpugraphwidget1',
    align = 'right'
})

cpugraphwidget1.height = 0.85
cpugraphwidget1.width = 40
cpugraphwidget1.bg = beautiful.bg_normal
cpugraphwidget1.border_color = beautiful.bg_normal
cpugraphwidget1.grow = 'left'

cpugraphwidget1:plot_properties_set('cpu', {
    fg = beautiful.widg_cpu_st ,
    fg_center = beautiful.widg_cpu_mid ,
    fg_end = beautiful.widg_cpu_end, 
    vertical_gradient = true
})

wicked.register(cpugraphwidget1, wicked.widgets.cpu, '$2', 1, 'cpu')

cpugraphwidget2 = widget({
    type = 'graph',
    name = 'cpugraphwidget2',
    align = 'right'
})

cpugraphwidget2.height = 0.85
cpugraphwidget2.width = 40
cpugraphwidget2.bg = beautiful.bg_normal
cpugraphwidget2.border_color = beautiful.bg_normal
cpugraphwidget2.grow = 'left'

cpugraphwidget2:plot_properties_set('cpu', {
    fg = beautiful.widg_cpu_st ,
    fg_center = beautiful.widg_cpu_mid ,
    fg_end = beautiful.widg_cpu_end, 
    vertical_gradient = true
})

wicked.register(cpugraphwidget2, wicked.widgets.cpu, '$3', 1, 'cpu')
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
    button({ }, 4, function () awful.util.spawn('mocp --toggle-pause') end),
    button({ }, 3, function () awful.util.spawn('mocp --previous'); mocp.popup() end),
    button({ }, 5, function () awful.util.spawn('mocp --previous'); mocp.popup() end)
})
mocpwidget.mouse_enter = function() mocp.popup() end
---}}}

--- {{{ FSWIDGET
fswidget = widget({ type = "textbox", name = "fswidget", align = "right" })

function fs()
  fh = io.popen('df -h | grep -w \'sda7\\|sda5\' | awk \'{print $5}\' | tr -d \'%\'')
  fswidget.text = '/: ' .. markup.fg(beautiful.fg_sb_hi,fh:read()) .. ' dat: ' .. markup.fg(beautiful.fg_sb_hi,fh:read())
  fh:close()
end
awful.hooks.timer.register (59,fs)
--- }}} 

-- {{{ -- BATTERY 
batterywidget = widget({ type = "textbox", name = "batterywidget", align = "right" })
batterywidget.width = 56
battery.setwidget(batterywidget)
awful.hooks.timer.register(10, battery.info)
-- }}}

---{{{ STATUSBAR
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
        mylauncher,
        mypromptbox[s], widget_spacer_l,
        mylayoutbox[s], widget_spacer_l,
        mytaglist[s], widget_spacer_l,
        mytasklist[s], widget_spacer_r,
        fswidget, widget_spacer_r,
        batterywidget, widget_spacer_r,
        memwidget, widget_spacer_r,
        cpuwidget, widget_spacer_r,
        cpugraphwidget1,
        cpugraphwidget2, widget_spacer_r,
        mocpwidget, widget_spacer_r,
        datewidget, s == 1 and mysystray or nil
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
    button({ }, 3, function () mymainmenu:toggle() end),
    button({ }, 4, awful.tag.viewnext),
    button({ }, 5, awful.tag.viewprev)
})
-- }}}

-- {{{ Key bindings
globalkeys = {}
clientkeys = {}

-- {{{ - TAGS BINDINGS
for i=1, ( shifty.config.maxtags or 9 ) do
  table.insert(globalkeys, key({ modkey }, i,
          function () local t =  awful.tag.viewonly(shifty.getpos(i)) end))
  table.insert(globalkeys, key({ modkey, "Control" }, i,
          function () local t = shifty.getpos(i); t.selected = not t.selected end))
  table.insert(globalkeys, key({ modkey, "Shift" }, i,
          function () 
              if client.focus then 
                  t = shifty.getpos(i)
                  awful.client.movetotag(t)
                  awful.tag.viewonly(t)
              end 
          end))
  table.insert(globalkeys, key({ modkey, "Control", "Shift" }, i,
          function () if client.focus then awful.client.toggletag(shifty.getpos(i)) end end))
end

table.insert(globalkeys, key({ modkey }, "Left", awful.tag.viewprev))
table.insert(globalkeys, key({ modkey }, "Right", awful.tag.viewnext))
table.insert(globalkeys, key({ modkey, "Mod1" }, "j", awful.tag.viewprev))
table.insert(globalkeys, key({ modkey, "Mod1" }, "k", awful.tag.viewnext))
table.insert(globalkeys, key({ modkey }, "Escape", awful.tag.history.restore))
table.insert(globalkeys, key({ modkey }, "e", revelation.revelation ))

table.insert(globalkeys, key({ modkey,"Shift", "Control"}, "j", shifty.prev))
table.insert(globalkeys, key({ modkey,"Shift", "Control"}, "k",   shifty.next))
table.insert(globalkeys, key({ modkey,"Shift", "Mod1"   }, "j",     shifty.shift_prev))
table.insert(globalkeys, key({ modkey,"Shift", "Mod1"   }, "k",     shifty.shift_next))
table.insert(globalkeys, key({ modkey,"Shift", "Mod1"   }, "h",     shifty.send_prev))
table.insert(globalkeys, key({ modkey,"Shift", "Mod1"   }, "l",     shifty.send_next))
table.insert(globalkeys, key({ modkey,"Shift", "Control"}, "r",  shifty.rename))
table.insert(globalkeys, key({ modkey,"Shift", "Control"}, "w", shifty.del))
table.insert(globalkeys, key({ modkey,"Shift", "Mod1"   }, "t",     shifty.add))
table.insert(globalkeys, key({ modkey,"Shift", "Control"}, "t", function() shifty.add({ nopopup = true }) end))
---}}}

-- {{{ - APPLICATIONS
-- Standard program
table.insert(globalkeys, key({ modkey }, "Return", function () awful.util.spawn(settings.apps.terminal) end))

-- application launching and controlling, Win+Alt
table.insert(globalkeys, key({ modkey, "Mod1" },"w", function () awful.util.spawn(settings.apps.browser) end))
table.insert(globalkeys, key({ modkey, "Mod1" },"m", function () awful.util.spawn(settings.apps.mail) end))
table.insert(globalkeys, key({ modkey, "Mod1" },"f", function () awful.util.spawn(settings.apps.filemgr) end))
table.insert(globalkeys, key({ modkey, "Mod1" },"c", function () awful.util.spawn("galculator") end))
table.insert(globalkeys, key({ modkey, "Mod1", "Shift" },"v", function () awful.util.spawn('VBoxSDL -vm xp2') end))
table.insert(globalkeys, key({ modkey, "Mod1" },"g", function () awful.util.spawn('gschem') end))
table.insert(globalkeys, key({ modkey, "Mod1", "Shift" } ,"g", function () awful.util.spawn('gimp') end))
table.insert(globalkeys, key({ modkey, "Mod1" },"o", function () awful.util.spawn('/home/perry/.bin/octave-start.sh') end))
table.insert(globalkeys, key({ modkey, "Mod1" },"v", function () awful.util.spawn('TERM=rxvt-256color ' .. settings.apps.terminal..' -name vim -e sh -c vim') end))
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
table.insert(globalkeys, key({ modkey, "Ctrl" },"j", function() mocp.play(); mocp.popup() end ))
table.insert(globalkeys, key({ modkey, "Ctrl" },"k", function () awful.util.spawn('mocp --previous');mocp.popup() end))
table.insert(globalkeys, key({ "" }, "XF86AudioRaiseVolume", function () awful.util.spawn('/home/perry/.bin/volume.py +5') end))
table.insert(globalkeys, key({ "" }, "XF86AudioLowerVolume", function () awful.util.spawn('/home/perry/.bin/volume.py -5') end))
table.insert(globalkeys, key({ modkey }, "XF86AudioRaiseVolume", function () awful.util.spawn('/home/perry/.bin/volume.py +1') end))
table.insert(globalkeys, key({ modkey }, "XF86AudioLowerVolume", function () awful.util.spawn('/home/perry/.bin/volume.py -1') end))
table.insert(globalkeys, key({ "" },"XF86AudioMute", function () awful.util.spawn('/home/perry/.bin/volume.py') end))
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
hiddenClient = nil
table.insert(clientkeys, key({modkey, "Shift"},"q", function ()
    local c = client.focus()

    if hiddenClient == nil then
        hiddenClient= c
        c.hide = true
    else
        c.hide = false
        hiddenClient = nil
    end
end))


table.insert(clientkeys, key({ modkey, "Shift" },"t", function () toggleTitlebar(client.focus) end)) -- show client on all tags
table.insert(clientkeys, key({ modkey, "Shift" },"0", function () client.focus.sticky = not client.focus.sticky end)) -- show client on all tags
table.insert(clientkeys, key({ modkey }, "m", function (c) c.maximized_horizontal = not c.maximized_horizontal         -- maximize client
                                                           c.maximized_vertical = not c.maximized_vertical end))
table.insert(clientkeys, key({ modkey, "Shift" }, "c", function (c) c:kill() end))                                      -- kill client
table.insert(clientkeys, key({ modkey }, "j", function () awful.client.focus.byidx(1); client.focus:raise() end))       -- change focus
table.insert(clientkeys, key({ modkey }, "k", function () awful.client.focus.byidx(-1);  client.focus:raise() end))
table.insert(clientkeys, key({ modkey, "Shift" }, "j", function () awful.client.swap.byidx(1) end))     -- change order
table.insert(clientkeys, key({ modkey, "Shift" }, "k", function () awful.client.swap.byidx(-1) end))
table.insert(clientkeys, key({ modkey, "Control" }, "j", function () awful.screen.focus(1) end))        -- switch monitor focus
table.insert(clientkeys, key({ modkey, "Control" }, "k", function () awful.screen.focus(-1) end))
table.insert(clientkeys, key({ modkey, "Control" }, "space", awful.client.togglefloating))              -- toggle client float
table.insert(clientkeys, key({ modkey, "Control" }, "Return", function () client.focus:swap(awful.client.master()) end))  -- switch focused client with master
table.insert(clientkeys, key({ modkey }, "o", awful.client.movetoscreen))   -- switch client to other screen
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
-- }}}

-- {{{ - LAYOUT MANIPULATION
table.insert(globalkeys, key({ modkey }, "l", 
    function () 
        awful.tag.incmwfact(0.05) 
        -- setMwbox(markup.font("Verdana 10", "MWFact: " .. awful.tag.selected().mwfact ))
    end))
table.insert(globalkeys, key({ modkey }, "h", 
    function () 
        awful.tag.incmwfact(-0.05) 
        -- setMwbox(markup.font("Verdana 10", "MWFact: " .. awful.tag.selected().mwfact ))
    end))

table.insert(globalkeys, key({ modkey, "Shift" }, "h", function () awful.tag.incnmaster(1) end))
table.insert(globalkeys, key({ modkey, "Shift" }, "l", function () awful.tag.incnmaster(-1) end))
table.insert(globalkeys, key({ modkey, "Control" }, "h", function () awful.tag.incncol(1) end))
table.insert(globalkeys, key({ modkey, "Control" }, "l", function () awful.tag.incncol(-1) end))
table.insert(globalkeys, key({ modkey }, "space", function () awful.layout.inc(layouts, 1) end))
table.insert(globalkeys, key({ modkey, "Shift" }, "space", function () awful.layout.inc(layouts, -1) end))
-- }}}

-- {{{ - PROMPT
table.insert(globalkeys, key({ modkey }, "F1", 
    function ()
        awful.prompt.run({ prompt = markup.fg( beautiful.fg_sb_hi," >> ") }, mypromptbox[mouse.screen], awful.util.spawn, awful.completion.bash,
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
    if not awful.client.ismarked(c) then
        if #(awful.tag.selected().clients(awful.tag.selected())) > 1 then
            c.border_width = beautiful.border_width
            c.border_color = beautiful.border_focus
        else
            c.border_width = 0
        end
    end
end)

-- Hook function to execute when unfocusing a client.
awful.hooks.unfocus.register(function (c)
    if not awful.client.ismarked(c) then
        if #(awful.tag.selected().clients(awful.tag.selected())) > 1 then
            c.border_width = beautiful.border_width
            c.border_color = beautiful.border_normal
        else
            c.border_width = 0
        end
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

-- Hook function to execute when a new client appears.
awful.hooks.manage.register( function (c)
    -- If we are not managing this application at startup, move it to the screen where the mouse is.
    -- We only do it for filtered windows (i.e. no dock, etc).
    if not startup and awful.client.focus.filter(c) then
        c.screen = mouse.screen
    end

    if use_titlebar then
        -- Add a titlebar
        awful.titlebar.add(c, { modkey = modkey })
    end
    -- Add mouse bindings
    c:buttons({
        button({ }, 1, function (c) client.focus = c; c:raise() end),
        button({ modkey }, 1, function (c) awful.mouse.client.move() end),
        button({ modkey }, 3, awful.mouse.client.resize ),
        -- button({ modkey, "Shift" }, 1, function (c) revelation.revelation()
            -- end )
    })
    -- New client may not receive focus
    -- if they're not focusable, so set border anyway.
    if #(awful.tag.selected().clients(awful.tag.selected())) > 1 then
        c.border_width = beautiful.border_width
    else
        c.border_width = 0
    end
    c.border_color = beautiful.border_normal

    -- Check if the application should be floating.
    local cls = c.class
    local inst = c.instance
    if ( string.find( c.name,"Preferences" ) ) ~= nil then
        -- a fix for ffx's preferences window. should clean this up
        awful.titlebar.add( c, { modkey = modkey } )
        awful.client.floating.set( c,true )
    end

    if c.name == "glxgears" then 
        awful.client.floating.set( c,true )
        awful.titlebar.add( c, { modkey = modkey } )
    end

    if not settings.new_become_master then
        awful.client.setslave(c)
    end

    -- Honor size hints: for all but terminals
    if c.class == "urxvt" or c.class == "URxvt" then
        c.size_hints_honor = false
    else
        c.size_hints_honor = true
    end

    -- Do this after tag mapping, so you don't see it on the wrong tag for a split second.
    client.focus = c

    -- Set key bindings
    c:keys(clientkeys)

    -- awful.placement.no_overlap(c)
    awful.placement.no_offscreen(c) -- this always seems to stick the client at 0,0 (incl titlebar)
    if awful.client.floating.get(c) then
        awful.client.moveresize(10,43,0,0,c)
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
end)

-- }}}

-- local hks = awful.hooks.registered() 
-- for i,h in pairs(hks) do
    -- print("hook name " .. h)
-- end
-- hks = nil

-- print("calling findhook")
-- if findhook("timer","fs")==true then 
    -- print("found fs: ")
-- else
    -- print("not found")
-- end
-- vim:set filetype=lua fdm=marker tabstop=4 shiftwidth=4 expandtab smarttab autoindent smartindent: --
