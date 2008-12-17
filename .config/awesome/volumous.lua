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

module("volumous")

local theme = {bg = "#99999966", border = "#aaaaaa44"}
local geometry = {x = 1040, y = 30, width=230, height=50}
--------------------
local bar_norm = {}
local bar_inactive = {}
local bars = {}
local volcontrol
--------------------------
local cardid  = 0
local channel = "Master"
local update = 2 --2 seconds
----------------------------

function clickableIcon(iconpath, align, callback)
   icon = widget({ type="imagebox", name="icon", align=align })
   icon.image = image(iconpath)
   icon:buttons({
		   button({ }, 1, callback),
		})
   return icon
end

function joinTables(t1, t2)
   for k,v in ipairs(t2) do table.insert(t1, v) end return t1
end

local function loadImages(image_base)
   for i = 1,10 do
      bar_norm[i] = image(image_base .. "norm" .. i .. ".png")
      bar_inactive[i] = image(image_base .. "inactive" .. i .. ".png")
   end
end

local function volume (mode, value)
   if mode == "get" then
      local status = io.popen("amixer -c " .. cardid .. " -- sget " .. channel):read("*all")
      
      local volume = string.match(status, "(%d?%d?%d)%%")
      volume = string.format("% 3d", volume)
      
      status = string.match(status, "%[(o[^%]]*)%]")
      return math.floor(volume/10)*10
   elseif mode == "up" then
      util.spawn("amixer -q -c " .. cardid .. " sset " .. channel .. " 5%+")
   elseif mode == "down" then
      util.spawn("amixer -q -c " .. cardid .. " sset " .. channel .. " 5%-")
   elseif mode == "set" then
      util.spawn("amixer -q -c " .. cardid .. " sset " .. channel .. " " .. value .. "%")
   else
      util.spawn("amixer -c " .. cardid .. " sset " .. channel .. " toggle")
   end
end

local function update_bars()
   vol = volume("get")
    local ind = vol/10
    for i = 1,10 do
       if i <= ind then
	  bars[i].image = bar_norm[i]
       else
	  bars[i].image = bar_inactive[i]
       end
    end
 end

local function mouseOn(index)
   for i = 1,10 do
      if i <= index then
	 bars[i].image = bar_norm[i]
      else
	 bars[i].image = bar_inactive[i]
      end
   end
end
local function mouseOff(i)
   update_bars()
end
local function mouseClick(i)
   volume("set", i*10)
   update_bars()
end

local function createBars()
   for i = 1,10 do
      local bar
      bar = widget({ type="imagebox", name="icon", align="left"})
      bar.image = bar_norm[i]
      function bar.mouse_enter() mouseOn(i) end
      function bar.mouse_leave() mouseOff(i) end
      bar:buttons({
		     button({ }, 1, function () mouseClick(i) end),
		     button({}, 5, function() volume("down") end),
		     button({}, 4, function() volume("up") end),
		  })
      bars[i] = bar
   end
end

function init(img_base, x, y)
   geometry.x = x
   geometry.y = y
   loadImages(img_base)
   createBars()
   volcontrol = wibox({position="floating", bg=theme.bg, border_color=theme.border, border_width=1})
   volcontrol:geometry(geometry)
   volcontrol.screen = 1
   local widg = {
      clickableIcon(img_base .. "speaker.png", 
		    "left",
		    function ()
		       volume()
		    end
		 ),
   }
   joinTables(widg, bars)
   volcontrol.widgets = widg
   hooks.timer.register(update, update_bars)
end
