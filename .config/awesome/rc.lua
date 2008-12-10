-- just helps troubleshooting when re-loading rc.lua (see output on console) 
print("Entered rc.lua: " .. os.time())

-- Include awesome libraries, with lots of useful function!
require("awful")
require("beautiful")
require("wicked")
require("revelation")

-- {{{ Variable definitions
-- This is a file path to a theme file which will defines colors.
theme_path = "/home/perry/.config/awesome/themes/default"
-- Initialize theme (colors).
beautiful.init(theme_path)

settings = {}
settings.new_become_master = false
settings.showmwfact = true

settings.apps = {}
settings.apps.terminal = "urxvtc"
settings.apps.browser = "firefox"
settings.apps.mail = "thunderbird"
settings.apps.filemgr = "pcmanfm"
settings.apps.chat = "/home/perry/.bin/screen-start.sh"
settings.apps.music = "mocp --server"
settings.apps.editor = os.getenv("EDITOR") or "vim"
editor_cmd = settings.apps.terminal .. " -e " .. settings.apps.editor

settings.sys = {}
settings.sys.battwarn = false
settings.sys.musicstate = ""

-- Default modkey.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts = {}
layouts = {
  "tile",
  -- "tileleft",
  "tilebottom",
  -- "tiletop",
  -- "fairh",
  -- "fairv",
  -- "magnifier",
  "max",
  -- "fullscreen",
  -- "spiral",
  "dwindle",
  "floating"
}

-- Table of clients that should be set floating. The index may be either
-- the application class or instance. The instance is useful when running
-- a console app in a terminal like (Music on Console)
--    xterm -name mocp -e mocp
floatapps = {}
floatapps = {
    ["MPlayer"] = true,
    ["pinentry"] = true,
    ["gimp"] = true,
    ["Gnuplot"] = true,
    ["Figure 1"] = true,
    ["gnplt"] = true,
    ["galculator"] = true,
    ["XDosEmu"] = true
}

-- Applications to be moved to a pre-defined tag by class or instance.
-- Use the screen and tags indices.
apptags = {}
apptags = {
    ["Navigator"] = { screen = 1, tag = 4}, 
    ["Shredder"] = { screen = 1, tag = 5 },
    ["mocp"] = { screen = 1, tag = 7 },
    ["VBoxSDL"] = { screen = 1, tag = 6 },
    ["MPlayer"] ={ screen = 1, tag = 7 },
    ["gimp"] = { screen = 1, tag = 7, titlebar = true },
    ["OpenOffice"] = { screen = 1, tag = 8 },
    ["acroread"] = { screen = 1, tag = 2 },
    ["Apvlv"] = { screen = 1, tag = 2 },
    ["pcb"] = { screen = 1, tag = 3 },
    ["gschem"] = { screen = 1, tag = 3 },
    ["gtkpod"] = { screen = 1, tag = 7 },
    ["PCB_Log"] = { screen = 1, tag = 3 }
}

-- Define if we want to use titlebar on all applications.
use_titlebar = false
-- }}}

-- {{{ -- Markup helper functions
-- Inline markup is a tad ugly, so use these functions to dynamically create markup, we hook them into
-- the beautiful namespace for clarity.
beautiful.markup = {}

function beautiful.markup.bg(color, text)
    return '<bg color="'..color..'" />'..text
end

function beautiful.markup.fg(color, text)
    return '<span color="'..color..'">'..text..'</span>'
end

function beautiful.markup.font(font, text)
    return '<span font_desc="'..font..'">'..text..'</span>'
end

function beautiful.markup.title(t)
    return t
end

function beautiful.markup.title_normal(t)
    return beautiful.title(t)
end

function beautiful.markup.title_focus(t)
    return beautiful.markup.bg(beautiful.bg_focus, beautiful.markup.fg(beautiful.fg_focus, beautiful.markup.title(t)))
end

function beautiful.markup.title_urgent(t)
    return beautiful.markup.bg(beautiful.bg_urgent, beautiful.markup.fg(beautiful.fg_urgent, beautiful.markup.title(t)))
end

function beautiful.markup.bold(text)
    return '<b>'..text..'</b>'
end

function beautiful.markup.heading(text)
    return beautiful.markup.fg(beautiful.fg_focus, beautiful.markup.bold(text))
end

---- }}} 

-- {{{ -- PWN functions
function mocplay() 
  if settings.sys.musicstate == "STOP" then
    awful.util.spawn('mocp --play') 
  elseif settings.sys.musicstate == "PLAY" then
    awful.util.spawn('mocp --next')
  else 
    awful.util.spawn('mocp --toggle-pause')
  end
end

-- toggles wether client has titlebar or not
function toggleTitlebar(c)
  if awful.layout.get(c.screen) == "floating" then 
    -- awful.titlebar.add(c, { modkey = modkey }) 
    awful.titlebar.add(c, {} ) 
  else
    if c.titlebar then
      awful.titlebar.remove(c)
    end
  end
end

-- puts text on screen using osdcat
function printOsd(text,pos,color)
    local font='-bitstream-bitstream\\ vera\\ sans-bold-r-*-*-17-*-*-*-*-*-*-*'
    local osdcmd='osd_cat --align=center --delay=1 --font=' .. font

    -- kill any already running osd_cat
    os.execute("kill $(/usr/bin/pgrep osd_cat) > /dev/null 2>&1 ")
    awful.util.spawn("echo "..text..' | '..osdcmd .. " --pos=" .. pos .. " " ..  "--color=" .. color )
end 


-- }}}

-- {{{ Tags
-- Define tags table.
settings.tags = {
    { name="w1"  , layout="tilebottom" , mwfact="0.60"} , 
    { name="ds"  , layout="max"}       , 
    { name="dz"  , layout="tile"       , mwfact="0.64"} , 
    { name="web" , layout="tilebottom" , mwfact="0.65"} , 
    { name="mal" , layout="tile"       , mwfact="0.65"} , 
    { name="vbx" , layout="tilebottom" , mwfact="0.75"} , 
    { name="mda" , layout="floating"   , mwfact="0.75"} , 
    { name="off" , layout="tilebottom" , mwfact="0.75"}
    }

tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = {}
    -- Create 9 tags per screen.
    for tagnumber = 1, 8 do
        tags[s][tagnumber] = tag({ name   = settings.tags[tagnumber].name,
                                   layout = settings.tags[tagnumber].layout,
                                   mwfact = settings.tags[tagnumber].mwfact
                                 })
        -- Add tags to screen one by one
        tags[s][tagnumber].screen = s
    end
    -- I'm sure you want to see at least one tag.
    tags[s][1].selected = true
end
-- }}}

-- {{{ Wibox & WIDGETS
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", settings.apps.terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu.new({ items = { { "awesome", myawesomemenu, "/usr/share/awesome/icons/awesome16.png" },
                                        { "open terminal", terminal } }
                           })

mylauncher = awful.widget.launcher({ image = "/home/perry/.config/awesome/icons/awesome48.png",
                                     menu = mymainmenu })

-- Create a systray
mysystray = widget({ type = "systray", align = "right" })


---{{{ WIBOX for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = { button({ }, 1, awful.tag.viewonly),
                      button({ modkey }, 1, awful.client.movetotag),
                      button({ }, 3, function (tag) tag.selected = not tag.selected end),
                      button({ modkey }, 3, awful.client.toggletag),
                      button({ }, 4, awful.tag.viewnext),
                      button({ }, 5, awful.tag.viewprev) }
mytasklist = {}
mytasklist.buttons = { button({ }, 1, function (c) client.focus = c; c:raise() end),
                       button({ }, 3, function () awful.menu.clients({ width=250 }) end),
                       button({ }, 4, function () awful.client.focus.byidx(1) end),
                       button({ }, 5, function () awful.client.focus.byidx(-1) end) }

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

wicked.register(datewidget, wicked.widgets.date,
    ' <span color="#cfcfff"> %k:%M %D\ </span>')

-- }}}

-- {{{ -- CPU widgets
cpuwidget = widget({ type = 'textbox', name = 'cpuwidget', align = 'right' })
cpuwidget.width = 51
wicked.register(cpuwidget, wicked.widgets.cpu, 'cpu:<span color="#cfcfff"> $1</span>')

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
    fg = '#AEC6D8',
    fg_center = '#285577',
    fg_end = '#285577',
    vertical_gradient = false
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
    fg = '#AEC6D8',
    fg_center = '#285577',
    fg_end = '#285577',
    vertical_gradient = false
})

wicked.register(cpugraphwidget2, wicked.widgets.cpu, '$3', 1, 'cpu')
-- }}}

-- {{{ -- MEMORY widgets
memwidget = widget({ type = 'textbox', name = 'memwidget', align = 'right' })
memwidget.width = 45

wicked.register(memwidget, wicked.widgets.mem, 'mem: <span color="#cfcfff">$1</span>')
-- }}}

-- {{{ -- MOCP Widget
mocpwidget = widget({ type = 'textbox', name = 'mocpwidget', align = 'right'})
mocpwidget.width = 112
mocpwidget:buttons({
    button({ }, 1, mocplay ),
    button({ }, 2, function () awful.util.spawn('mocp --toggle-pause') end),
    button({ }, 3, function () awful.util.spawn('mocp --previous') end)
})
-- {{{ mocp function
iScroller = 1
MAXCH = 15
function mocp()
    local np = {}
    np.file = {}
    np.file = io.popen('pgrep mocp')

    if np.file == nil then
        np.file:close()
        mocpwidget.text = "moc stopped"
        settings.sys.musicstate = "-"
    else
        np.file:close()

        -- pgrep returned something so we can now check for play|pause
        np.file = io.popen('mocp -Q %state')
        np.strng = np.file:read()
        np.file:close()

        -- this just helps my keybindings work better 
        settings.sys.musicstate = np.strng

        -- this sets the symbolic prefix based on where moc is playing | (stopped or paused)
        if np.strng == "PAUSE" or np.strng == "STOP" then
            prefix = "|| "
        else
            prefix = ">> "
        end

        -- moc is runngin and playing, so grab track info
        np.file = io.popen('mocp -Q %title')

        -- some song titles include a subtitle, which i think is stupid to show
        -- i also think track # is a stupid thing to show :P
        np.strng = string.gsub(np.file:read(),"^%d*","")
        np.file:close()
        np.strng = string.gsub(np.strng,"%(.*","")

        -- extract a substring, putting it after the 
        np.rtn = string.sub(np.strng,iScroller,MAXCH+iScroller-1) 

        -- if our index and MAXCH count are bigger than the string, wrap around to the beginning and
        -- add enough to make it look circular
        if MAXCH+iScroller > (np.strng):len() then
            np.rtn = np.rtn .. string.sub(np.strng,1,(MAXCH+iScroller-1)-np.strng:len())
        end

        np.rtn = awful.util.escape(np.rtn)
        mocpwidget.text = beautiful.markup.fg(beautiful.fg_normal,prefix) .. beautiful.markup.fg("#cfcfff",np.rtn) 

        if iScroller <= np.strng:len() then
            iScroller = iScroller +1
        else
            iScroller = 1
        end
    end
end
-- }}}
awful.hooks.timer.register (.75,mocp)
---}}}

--- {{{ FSWIDGET
fswidget = widget({ type = "textbox", name = "fswidget", align = "right" })

function fs()
  fh = io.popen('df -h | grep -w \'sda7\\|sda5\' | awk \'{print $5}\' | tr -d \'%\'')
  fswidget.text = '/: ' .. beautiful.markup.fg("#cfcfff",fh:read()) .. ' dat: ' .. beautiful.markup.fg("#cfcfff",fh:read())
  fh:close()
end

awful.hooks.timer.register (59,fs)
--- }}} 

-- {{{ -- BATTERY 
batterywidget = widget({ type = "textbox", name = "batterywidget", align = "right" })
batterywidget.width = 49
awful.hooks.timer.register(10, function ()
-- function batteryInfo()
  -- paths to the relevant files for battery statistics and state
  local capFile = "/proc/acpi/battery/BAT0/info"
  local stateFile = "/proc/acpi/battery/BAT0/state"

  -- open the file containg the battery's capacity, and read
  local tmpFile = io.open(capFile)
  local capacity = tmpFile:read("*a"):match("last full capacity:%s+(%d+)")
  io.close(tmpFile)

  -- get the current remaining batter capacity
  tmpFile = io.open(stateFile)
  local tCurrent = tmpFile:read("*all")
  io.close(tmpFile)
  local current = string.match(tCurrent,"remaining capacity:%s+(%d+)")

  -- calculate remaining %
  local battery = math.floor(((current * 100) / capacity))

  -- colorize based on remaining battery chargevalue
  if battery < 10 then
    battery = beautiful.markup.fg("#ff0000", battery)

    -- check that we arent continuosly issue the battery warning
    if settings.sys.battwarn == false then
        printOsd("Battery low: " .. battery, "middle", "red")
        battwarn = true
    end
  elseif battery < 25 then
    settings.sys.battwarn = false
    battery = beautiful.markup.fg("#f8700a", battery)
  elseif battery < 50 then
    settings.sys.battwarn = false
    battery = beautiful.markup.fg("#e6f21d", battery)
  elseif battery < 75 then
    settings.sys.battwarn = false
    battery = beautiful.markup.fg("#00cb00", battery)
  else
    battery = beautiful.markup.fg("#cfcfff", battery)
  end
  
  -- decide where to put the charging state indicator
  local state = string.match(tCurrent,"charging state:%s+(%w+)")
  if state:match("charged") then
      batterywidget.text = "bat: "..battery
  elseif state:match("discharging") then
      batterywidget.text = "bat: "..battery.."-"
  else
      batterywidget.text = "bat: +"..battery
  end
end)
-- }}}

---{{{ STATUSBAR
for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = widget({ type = "textbox", align = "left" })

    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = widget({ type = "imagebox", align = "left" })
    mylayoutbox[s].image = image("/home/perry/.config/awesome/icons/layouts/tilew.png")
    mylayoutbox[s]:buttons({ button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                             button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                             button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                             button({ }, 5, function () awful.layout.inc(layouts, -1) end) })
    -- Create a taglist widget
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

-- }}}

-- {{{ Mouse bindings
awesome.buttons({
    button({ }, 3, function () mymainmenu:toggle() end),
    button({ }, 4, awful.tag.viewnext),
    button({ }, 5, awful.tag.viewprev)
})
-- }}}

-- {{{ Key bindings

--{{{ Bind keyboard digits
-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

for i = 1, keynumber do
    keybinding({ modkey }, i,
                   function ()
                       local screen = mouse.screen
                       if tags[screen][i] then
                           awful.tag.viewonly(tags[screen][i])
                       end
                   end):add()
    keybinding({ modkey, "Control" }, i,
                   function ()
                       local screen = mouse.screen
                       if tags[screen][i] then
                           tags[screen][i].selected = not tags[screen][i].selected
                       end
                   end):add()
    keybinding({ modkey, "Shift" }, i,
                   function ()
                       if client.focus then
                           if tags[client.focus.screen][i] then
                               awful.client.movetotag(tags[client.focus.screen][i])
                           end
                       end
                   end):add()
    keybinding({ modkey, "Control", "Shift" }, i,
                   function ()
                       if client.focus then
                           if tags[client.focus.screen][i] then
                               awful.client.toggletag(tags[client.focus.screen][i])
                           end
                       end
                   end):add()
end
---}}}

keybinding({ modkey }, "Left", awful.tag.viewprev):add()
keybinding({ modkey }, "Right", awful.tag.viewnext):add()
keybinding({ modkey }, "Escape", awful.tag.history.restore):add()

-- {{{ - APPLICATIONS
-- Standard program
keybinding({ modkey }, "Return", function () awful.util.spawn(settings.apps.terminal) end):add()

-- application launching and controlling, Win+Alt
keybinding({ modkey, "Mod1" },"w", function () awful.util.spawn(settings.apps.browser) end):add()
keybinding({ modkey, "Mod1" },"m", function () awful.util.spawn(settings.apps.mail) end):add()
keybinding({ modkey, "Mod1" },"f", function () awful.util.spawn(settings.apps.filemgr) end):add()
keybinding({ modkey, "Mod1" },"c", function () awful.util.spawn("galculator") end):add()
keybinding({ modkey, "Mod1", "Shift" },"v", function () awful.util.spawn('VBoxSDL -vm xp2') end):add()
keybinding({ modkey, "Mod1" },"g", function () awful.util.spawn('gschem') end):add()
-- keybinding({ modkey, "Mod1" },"p", function () awful.util.spawn('pcb') end):add()
keybinding({ modkey, "Mod1", "Shift" } ,"g", function () awful.util.spawn('gimp') end):add()
keybinding({ modkey, "Mod1" },"o", function () awful.util.spawn('/home/perry/.bin/octave-start.sh') end):add()
keybinding({ modkey, "Mod1" },"v", function () awful.util.spawn('TERM=rxvt-256color ' .. settings.apps.terminal..' -name vim -e sh -c vim') end):add()
keybinding({ modkey, "Mod1" },"i", function () awful.util.spawn('gtkpod') end):add()
-- }}}

-- {{{ - POWER
keybinding({ modkey, "Mod1" },"h", function () awful.util.spawn('sudo pm-hibernate') end):add()
keybinding({ modkey, "Mod1" },"s", function () 
  os.execute('sudo pm-suspend')
  -- os.execute('sleep 1')
  awful.util.spawn('slock')
end):add()
keybinding({ modkey, "Mod1" },"r", function () awful.util.spawn('sudo reboot') end):add()
keybinding({ modkey, "Mod1" },"l", function () awful.util.spawn('slock') end):add()
-- }}} 

-- {{{ - MEDIA
keybinding({ modkey, "Mod1" },"p", mocplay ):add()
keybinding({ },"XF86AudioPlay", mocplay ):add()
keybinding({ modkey, "Mod1" },"j", mocplay ):add()
keybinding({ modkey, "Mod1" },"k", function () awful.util.spawn('mocp --previous') end):add()
keybinding({ "" }, "XF86AudioRaiseVolume", function () awful.util.spawn('/home/perry/.bin/volume.py +5') end):add()
keybinding({ "" }, "XF86AudioLowerVolume", function () awful.util.spawn('/home/perry/.bin/volume.py -5') end):add()
keybinding({ modkey }, "XF86AudioRaiseVolume", function () awful.util.spawn('/home/perry/.bin/volume.py +1') end):add()
keybinding({ modkey }, "XF86AudioLowerVolume", function () awful.util.spawn('/home/perry/.bin/volume.py -1') end):add()
keybinding({ "" },"XF86AudioMute", function () awful.util.spawn('/home/perry/.bin/volume.py') end):add()
keybinding({ },"XF86AudioPrev", function () awful.util.spawn('mocp -r') end):add()
keybinding({ },"XF86AudioNext", mocplay ):add()
keybinding({ },"XF86AudioStop", function () awful.util.spawn('mocp --stop') end):add()
-- }}} 

-- {{{ - SPECIAL keys
keybinding({ modkey, "Control" }, "r", awesome.restart):add()
keybinding({ modkey, "Shift" }, "q", awesome.quit):add()
-- }}} 

-- {{{ - WM bindings
keybinding({ modkey }, "Left", awful.tag.viewprev):add()
keybinding({ modkey }, "Right", awful.tag.viewnext):add()
keybinding({ modkey }, "Escape", awful.tag.history.restore):add()
keybinding({ modkey }, "e", revelation.revelation ):add()
-- }}} 

-- {{{ - CLIENT MANIPULATION
keybinding({ modkey, "Shift" },"0", function () 
    if client.focus.sticky then 
        client.focus.sticky = false
    else
        client.focus.sticky = true
    end
end ):add()

keybinding({ modkey }, "m", awful.client.maximize):add()
keybinding({ modkey, "Shift" }, "c", function () client.focus:kill() end):add()
keybinding({ modkey }, "j", function () awful.client.focus.byidx(1); client.focus:raise() end):add()
keybinding({ modkey }, "k", function () awful.client.focus.byidx(-1);  client.focus:raise() end):add()
keybinding({ modkey, "Shift" }, "j", function () awful.client.swap.byidx(1) end):add()
keybinding({ modkey, "Shift" }, "k", function () awful.client.swap.byidx(-1) end):add()
keybinding({ modkey, "Control" }, "j", function () awful.screen.focus(1) end):add()
keybinding({ modkey, "Control" }, "k", function () awful.screen.focus(-1) end):add()
keybinding({ modkey, "Control" }, "space", awful.client.togglefloating):add()
keybinding({ modkey, "Control" }, "Return", function () client.focus:swap(awful.client.master()) end):add()
keybinding({ modkey }, "o", awful.client.movetoscreen):add()
keybinding({ modkey }, "Tab", awful.client.focus.history.previous):add()
keybinding({ modkey }, "u", awful.client.urgent.jumpto):add()
keybinding({ modkey, "Shift" }, "r", function () client.focus:redraw() end):add()
-- }}}

-- {{{ - LAYOUT MANIPULATION
keybinding({ modkey }, "l", function () awful.tag.incmwfact(0.05) printOsd('MWFact= '..awful.tag.selected().mwfact ,"middle","blue") end):add()
keybinding({ modkey }, "h", function () awful.tag.incmwfact(-0.05) printOsd('MWFact= '..awful.tag.selected().mwfact ,"middle","blue") end):add()
keybinding({ modkey, "Shift" }, "h", function () awful.tag.incnmaster(1) end):add()
keybinding({ modkey, "Shift" }, "l", function () awful.tag.incnmaster(-1) end):add()
keybinding({ modkey, "Control" }, "h", function () awful.tag.incncol(1) end):add()
keybinding({ modkey, "Control" }, "l", function () awful.tag.incncol(-1) end):add()
keybinding({ modkey }, "space", function () awful.layout.inc(layouts, 1) end):add()
keybinding({ modkey, "Shift" }, "space", function () awful.layout.inc(layouts, -1) end):add()
-- }}}

-- {{{ - PROMPT
keybinding({ modkey }, "F1", function ()
                                 awful.prompt.run({ prompt = "Run: " }, mypromptbox, awful.util.spawn, awful.completion.bash,
os.getenv("HOME") .. "/.cache/awesome/history") end):add()
keybinding({ modkey }, "F4", function ()
                                 awful.prompt.run({ prompt = "Run Lua code: " }, mypromptbox, awful.eval, awful.prompt.bash,
os.getenv("HOME") .. "/.cache/awesome/history_eval") end):add()
keybinding({ modkey, "Ctrl" }, "i", function ()
    if mypromptbox.text then
        mypromptbox.text = nil
    else
        mypromptbox.text = nil
        if client.focus.class then
            mypromptbox.text = "Class: " .. client.focus.class .. " "
        end
        if client.focus.instance then
            mypromptbox.text = mypromptbox.text .. "Instance: ".. client.focus.instance .. " "
        end
        if client.focus.role then
            mypromptbox.text = mypromptbox.text .. "Role: ".. client.focus.role
        end
        mypromptbox.text = "Class: " .. client.focus.class .. " Instance: ".. client.focus.instance

    end
end):add()

-- }}}

--- }}}

-- {{{ Hooks


-- Hook function to execute when focusing a client.
awful.hooks.focus.register(function (c)
    if not awful.client.ismarked(c) then
        c.border_color = beautiful.border_focus
    end
    -- toggleTitlebar(c)
end)

-- Hook function to execute when unfocusing a client.
awful.hooks.unfocus.register(function (c)
    if not awful.client.ismarked(c) then
        c.border_color = beautiful.border_normal
    end
    -- toggleTitlebar(c)
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

    if use_titlebar then
        -- Add a titlebar
        awful.titlebar.add(c, { modkey = modkey })
    end
    -- Add mouse bindings
    c:buttons({
        button({ }, 1, function (c) client.focus = c; c:raise() end),
        button({ modkey }, 1, function (c) c:mouse_move() end),
        button({ modkey }, 3, function (c) c:mouse_resize() end)
    })
    -- New client may not receive focus
    -- if they're not focusable, so set border anyway.
    c.border_width = beautiful.border_width
    c.border_color = beautiful.border_normal
    client.focus = c

    -- Check if the application should be floating.
    local cls = c.class
    local inst = c.instance
    if floatapps[cls] then
        awful.titlebar.add(c, { modkey = modkey })
        c.floating = floatapps[cls]
    elseif floatapps[inst] then
        awful.titlebar.add(c, { modkey = modkey })
        c.floating = floatapps[inst]
    end

    -- Check application->screen/tag mappings, if the app is left
    -- on the current tag, set it as slave
    local target
      if apptags[cls] then
        target = apptags[cls]
      elseif apptags[inst] then
        target = apptags[inst]
      end
      -- dont move floating dialogs 
      if c.type ~= "dialog" and target then
        c.screen = target.screen
        awful.client.movetotag(tags[target.screen][target.tag], c)

        -- if the new client is not moved to another tag, it becomes a slave
        -- this assumes we dont want new apps to become master
      elseif not settings.new_become_master then
        awful.client.setslave(c)
      end

    -- Honor size hints: for all but terminals
    c.honorsizehints = true
    if c.class == "urxvt" or c.class == "URxvt" or c.class == "Apvlv" or c.class == "apvlv" then
        -- print("found urxvt")
        c.honorsizehints = false
    end
    awful.placement.no_overlap(c)
    awful.placement.no_offscreen(c)
end)

-- Hook function to execute when arranging the screen.
-- (tag switch, new client, etc)
awful.hooks.arrange.register(function (screen)
    local layout = awful.layout.get(screen)
    if layout then
        mylayoutbox[screen].image = image("/home/perry/.config/awesome/icons/layouts/" .. layout .. "w.png")
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

-- 
-- vim: set filetype=lua fdm=marker tabstop=4 shiftwidth=4 expandtab smarttab autoindent smartindent
