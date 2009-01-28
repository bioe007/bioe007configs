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

local calendar = nil
local offset = 0

function remove_calendar()
  if calendar ~= nil then
    naughty.destroy(calendar)
    calendar = nil
    offset = 0
  end
end

function add_calendar(inc_offset)
  local save_offset = offset
  remove_calendar()
  offset = save_offset + inc_offset
  local datespec = os.date("*t")
  datespec = datespec.year * 12 + datespec.month - 1 + offset
  datespec = (datespec % 12 + 1) .. " " .. math.floor(datespec / 12)
  local cal = awful.util.pread("cal -m " .. datespec)
  cal = string.gsub(cal, "^%s*(.-)%s*$", "%1")
  calendar = naughty.notify({
    text = markup.font("monospace", os.date("%a, %d %B %Y") .. "\n" .. cal),
    timeout = 0, hover_timeout = 0.5,
    width = beautiful.calendar_w or 160,
    bg = beautiful.calendar_bg or beautiful.bg_focus or #000000,
    fg = beautiful.calendar_fg or beautiful.fg_focus or #ffffff})
end

-- vim:set filetype=lua fdm=marker tabstop=4 shiftwidth=4 expandtab smarttab autoindent smartindent: --
