local widget = widget
local button = button
local io = io
local string = string
local hooks = require("awful.hooks")
local util = require("awful.util")
local beautiful = require("beautiful")
local mocbox = nil

-- module("mocscroll")

function mocstate()

    local np = {}
    np.file = {}
    np.file = io.popen('pgrep mocp')

    if np.file == nil then
        np.file:close()
        mocpwidget.text = "moc stopped"
        settings.sys.musicstate = "-"
        mocInterval = 2
        return false
    else
        np.file:close()

        -- pgrep returned something so we can now check for play|pause
        np.file = io.popen('mocp -Q %state')
        np.strng = np.file:read()
        np.file:close()

        settings.sys.musicstate = np.strng
        return np.strng
    end
end

function moctitle(delim)

    local eol = delim or " "
    local np = {}

    -- grab artist
    np.file = io.popen('mocp -Q %artist')
    np.artist = np.file:read() .. ":" .. eol
    np.file:close()

    -- grab song
    np.file = io.popen('mocp -Q %song')
    np.song = np.file:read() .. eol
    np.file:close()

    -- return for widget text
    if not delim then return np.artist..np.song end

    -- get time, etc for notify
    np.file = io.popen('mocp -Q %album')
    np.strng = "Artist: "..np.artist.."Song:   "..np.song.."Album:  "..np.file:read()..eol
    np.file:close()

    np.file = io.popen('mocp -Q %ct')
    np.strng = np.strng.."Time:   "..np.file:read() .." [ " 
    np.file:close()

    np.file = io.popen('mocp -Q %tt')
    np.strng = np.strng..np.file:read() .." ]" 
    np.file:close()

    return np.strng
end

-- 
function mocnotify(args)

    if mocbox ~= nil then
        naughty.destroy(mocbox)
    end

    local np = {}
    np.state = nil
    np.strng = ""
    np.state = mocstate()
    if np.state == false then
        return
    else
        np.strng = moctitle("\n")
    end
    np.strng = markup.fg( beautiful.fg_focus, markup.font("monospace", np.strng.."  "))  
    mocbox = naughty.notify({ title = markup.font("monospace","Now Playing:"),
        text = np.strng, hover_timeout = 2,
        icon = "/usr/share/icons/gnome/24x24/actions/edia-playback-start.png", icon_size = 24,
        run = function() mocplay(); mocnotify() end})
end

-- easier way to check|run mocp
function mocplay() 
  if settings.sys.musicstate == "STOP" then
    awful.util.spawn('mocp --play') 
  elseif settings.sys.musicstate == "PLAY" then
    awful.util.spawn('mocp --next')
  else 
    awful.util.spawn('mocp --toggle-pause')
  end
end

-- {{{ mocp widget, scrolls text
-- settings = {}
-- settings.iScroller = 1
-- settings.MAXCH = 15
-- settings.mocInterval = 0.75
iScroller = 1
MAXCH = 15
mocInterval = 0.75
function mocp()
    local np = {}

    np.strng = mocstate()
    if not np.strng then
        mocpwidget.text = "moc stopped"
        settings.sys.musicstate = "-"
        return
    else

        -- this just helps my keybindings work better 
        settings.sys.musicstate = np.strng

        -- this sets the symbolic prefix based on where moc is playing | (stopped or paused)
        if np.strng == "PAUSE" or np.strng == "STOP" then
            prefix = "|| "
            mocInterval = 2
        else
            prefix = ">> "
            mocInterval = 0.75
        end

        -- extract a substring, putting it after the 
        np.strng = moctitle()
        np.rtn = string.sub(np.strng,iScroller,MAXCH+iScroller-1) 

        -- if our index and MAXCH count are bigger than the string, wrap around to the beginning and
        -- add enough to make it look circular
        if MAXCH+iScroller > (np.strng):len() then
            np.rtn = np.rtn .. string.sub(np.strng,1,(MAXCH+iScroller-1)-np.strng:len())
        end

        np.rtn = awful.util.escape(np.rtn)
        mocpwidget.text = markup.fg(beautiful.fg_normal,prefix) .. markup.fg(beautiful.fg_sb_hi,np.rtn) 

        if iScroller <= np.strng:len() then
            iScroller = iScroller +1
        else
            iScroller = 1
        end
    end
        -- return (markup.fg(beautiful.fg_normal,prefix) .. markup.fg("#cfcfff",np.rtn) )
end
-- }}}

-- vim: filetype=lua fdm=marker tabstop=4 shiftwidth=4 expandtab smarttab autoindent smartindent:

