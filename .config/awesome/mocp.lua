local io = io
local string = string
local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
local markup = require("markup")

module("mocp")

local mocbox = nil
settings = {}
settings.iScroller = 1
settings.MAXCH = 15
settings.interval = 0.75

---{{{ local function state()
local function state()

    local np = {}
    np.file = {}
    np.file = io.popen('pgrep mocp')

    if np.file == nil then
        np.file:close()
        settings.widget.text = "moc stopped"
        settings.musicstate = "-"
        settings.interval = 2
        return false
    else
        np.file:close()

        -- pgrep returned something so we can now check for play|pause
        np.file = io.popen('mocp -Q %state')
        np.strng = np.file:read()
        np.file:close()

        settings.musicstate = np.strng
        return np.strng
    end
end
---}}}

---{{{ local function title(delim)
local function title(delim)

    local eol = delim or " "
    local np = {}

    -- grab artist
    np.file = io.popen('mocp -Q %artist')
    np.artist = np.file:read() .. ":" .. eol
    np.file:close()

    -- grab song
    np.file = io.popen('mocp -Q %song')
    np.song =string.gsub( string.gsub(np.file:read(),"^%d*",""),"%(.*","") .. eol
    np.file:close()

    -- return for widget text
    if not delim then return np.artist..np.song end

    -- get time, etc for notify
    np.file = io.popen('mocp -Q %album')
    np.strng = "Artist: "..string.gsub(np.artist,":","").."Song:   "..np.song.."Album:  "..np.file:read()..eol
    np.file:close()

    np.file = io.popen('mocp -Q %ct')
    np.strng = np.strng.."Time:   "..np.file:read() .." [ " 
    np.file:close()

    np.file = io.popen('mocp -Q %tt')
    np.strng = np.strng..np.file:read() .." ]" 
    np.file:close()

    return np.strng
end
---}}}

---{{{ local function notdestroy()
local function notdestroy()
    if mocbox ~= nil then
        naughty.destroy(mocbox)
        mocbox = nil
    end
end
---}}}

---{{{ function popup(args)
function popup(args)
    
    notdestroy()

    local np = {}
    np.state = nil
    np.strng = ""
    np.state = state()
    if np.state == false then
        return
    else
        np.strng = title("\n")
    end
    np.strng = markup.fg( beautiful.fg_focus, markup.font("monospace", np.strng.."  "))  
    mocbox = naughty.notify({ 
        title = markup.font("monospace","Now Playing:"),
        text = np.strng, hover_timeout = ( settings.hovertime or 3 ), timeout = 0,
        -- icon = "/usr/share/icons/gnome/24x24/actions/edia-playback-start.png", icon_size = 24,
        run = function() play(); popup() end
    })
end
---}}}

---{{{ function mocplay() 
-- easier way to check|run mocp
function play() 
  if settings.musicstate == "STOP" then
    awful.util.spawn('mocp --play') 
  elseif settings.musicstate == "PLAY" then
    awful.util.spawn('mocp --next')
  else 
    awful.util.spawn('mocp --toggle-pause')
  end
end
---}}}

function setwidget(w)
    settings.widget = w
end

-- {{{ mocp widget, scrolls text
function scroller(tb)
    local np = {}

    np.strng = state()
    if not np.strng then
        settings.widget.text = "moc stopped"
        settings.musicstate = "-"
        return
    else

        -- this just helps my keybindings work better 
        settings.musicstate = np.strng

        -- this sets the symbolic prefix based on where moc is playing | (stopped or paused)
        if np.strng == "PAUSE" or np.strng == "STOP" then
            prefix = "|| "
            settings.interval = 2
        else
            prefix = ">> "
            settings.interval = 0.75
        end

        -- extract a substring, putting it after the 
        np.strng = title()
        np.rtn = string.sub(np.strng,settings.iScroller,settings.MAXCH+settings.iScroller-1) 

        -- if our index and settings.MAXCH count are bigger than the string, wrap around to the beginning and
        -- add enough to make it look circular
        if settings.MAXCH+settings.iScroller > (np.strng):len() then
            np.rtn = np.rtn .. string.sub(np.strng,1,(settings.MAXCH+settings.iScroller-1)-np.strng:len())
        end

        np.rtn = awful.util.escape(np.rtn)
        settings.widget.text = markup.fg(beautiful.fg_normal,prefix) .. markup.fg(beautiful.fg_sb_hi,np.rtn) 

        if settings.iScroller <= np.strng:len() then
            settings.iScroller = settings.iScroller +1
        else
            settings.iScroller = 1
        end
    end
end
-- }}}

-- vim: filetype=lua fdm=marker tabstop=4 shiftwidth=4 expandtab smarttab autoindent smartindent:

