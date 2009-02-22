-- nice battery widget for awesome. 
-- user can config path to battery using 
--     battery.settings.ipath = <path to your info file>
--     battery.settings.spath = <path to your state file>
--
local io = io
local string = string
local math = math
local beautiful = require("beautiful")
local naughty = require("naughty")
local markup = require("markup")

module("battery")
local battwarn 
local adapter_state = nil
local bwidget = {}

settings = {}

function showWarning(s)

  naughty.notify({ 
    text = markup.font("DejaVu Sans 8",
           markup.bold(
           markup.fg(beautiful.fg_batt_oshi or "#ff2233", "Warning, low battery! ".. s ))),
    timeout = 0, hover_timeout = 0.5,
    bg = beautiful.bg_focus,
    width = beautiful.battery_w or 160,
  })

end


function info()
  -- paths to the relevant files for battery statistics and state
  local capFile = settings.ipath or "/proc/acpi/battery/BAT0/info"
  local stateFile = settings.spath or "/proc/acpi/battery/BAT0/state"

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

  -- colorize based on remaining battery charge
  if battery < 10 then
    battery = markup.fg(beautiful.fg_batt_oshi or "#ff0000", battery)

    -- check that we arent continuosly issue the battery warning
    if battwarn == false then
      showWarning(battery)
      battwarn = true
    end
  elseif battery < 25 then
    battwarn = false
    battery = markup.fg( beautiful.fg_batt_crit or "#f8700a", battery)
  elseif battery < 50 then
    battwarn = false
    battery = markup.fg( beautiful.fg_batt_low or "#e6f21d", battery)
  elseif battery < 75 then
    battwarn = false
    battery = markup.fg( beautiful.fg_batt_mid or "#00cb00", battery)
  else
    battery = markup.fg( beautiful.fg_sb_hi or "#cfcfff", battery)
  end

  -- decide which and where to put the charging state indicator
  local state = string.match(tCurrent,"charging state:%s+(%w+)")
  if state:match("charged") then
    bwidget.text = "bat: ↯"..battery
  elseif state:match("discharging") then
    bwidget.text = "bat: ▼"..battery
  else
    bwidget.text = "bat: ▲"..battery
  end
end

function init(w, width)
  bwidget = w
  bwidget.width = width or 56
  info()
end
