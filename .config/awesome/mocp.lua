local widget = widget
local button = button
local io = io
local string = string
local hooks = require("awful.hooks")
local util = require("awful.util")
local awbeautiful = require("beautiful")

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
local iScroller = 1
local MAXCH = 15
local mocInterval = 0.75
function mocp()
    local np = {}
    np.file = {}
    np.file = io.popen('pgrep mocp')

    if np.file == nil then
        np.file:close()
        mocpwidget.text = "moc stopped"
        settings.sys.musicstate = "-"
        mocInterval = 2
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
            mocInterval = 2
        else
            prefix = ">> "
            mocInterval = 0.75
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

