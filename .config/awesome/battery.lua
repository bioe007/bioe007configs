local wibox = wibox
local widget = widget
local image = image
local button = button
local ipairs = ipairs
local table = table
local io = io
local string = string
local math = math
local hooks = require("awful.hooks")
local util = require("awful.util")
local awbeautiful = require("beautiful")
local naughty = require("naughty")

local battwarn 
local adapter_state = nil

function showWarning(s)

  naughty.notify({ 
    text = markup.font("DejaVu Sans 8",
           markup.bold(
           markup.fg(beautiful.fg_batt_oshi or "#ff2233", "Warning, low battery! ".. s ))),
    timeout = 0, hover_timeout = 0.5,
    bg = beautiful.bg_focus,
    -- width = beautiful.battery_w or 160,
  })

end

function batteryInfo()
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

  -- showWarning(battery)
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
    batterywidget.text = "bat: "..battery
  elseif state:match("discharging") then
    batterywidget.text = "bat: "..battery.."-"
  else
    batterywidget.text = "bat: +"..battery
  end
end

