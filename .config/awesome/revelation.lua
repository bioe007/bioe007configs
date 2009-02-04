---------------------------------------------------------------------------
-- @author Espen Wiborg &lt;espenhw@grumblesmurf.org&gt;
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008 Espen Wiborg, Julien Danjou
-- @release v3.1-rc3-14-gc7ee83f
-- 
-- note: rewritten by Perry Hargrave perry)dot(hargrave)at(gmail.com
-- note: this is a version of revelation.lua modified for awesome 3.1.223+
--
---------------------------------------------------------------------------
local math = math
local table = table
local pairs = pairs
local button = button
local otable = otable
local awful = awful
local capi =
{
    tag = tag,
    client = client,
    keygrabber = keygrabber,
    mouse = mouse,
    screen = screen
}
local print = print
--- Exposé implementation
module("revelation")

-- Layout functions
layout = {}

--- The default layout function for revelation
-- Tries to arrange clients in an approximated square grid, by
-- calculating c = floor(sqrt(n)) and arranging for c columns in a
-- tile layout.
-- @param t The tag to do revelation on.
-- @param n The number of clients to reveal.
function layout.default (t, n)
    awful.tag.setproperty(t,"layout",awful.layout.suit.fair )
    -- local columns = math.floor(math.sqrt(n))
-- 
    -- if columns > 1 then
        -- awful.tag.setmwfact(1 / columns, t )
        -- awful.tag.setncol( columns - 1, t)
    -- end
    -- awful.tag.setnmaster(n / columns, t)
end

function clients(class, s)
    local clients
    if class then
        clients = {}
        for k, c in pairs(capi.client.get(s)) do
            if c.class == class then
                table.insert(clients, c)
            end
        end
   else
        clients = capi.client.get(s)
   end
   return clients
end

function selectfn(restore)
    return function(c)
               restore()
               -- Pop to client tag
               awful.tag.viewonly(c:tags()[1])
               -- Focus and raise
               capi.client.focus = c
               c:raise()
           end
end

--- Returns keyboardhandler.
-- Arrow keys move focus, Return selects, Escape cancels.
-- Ignores modifiers.
function keyboardhandler (restore)
    return function (mod, key, event)
      if event ~= "press" then return true end
                -- translate vim-style home keys to directions
                if key == "j" or key == "k" or key == "h" or key == "l" then
                  if key == "j" then
                    key = "Down"
                  elseif key == "k" then
                    key = "Up"
                  elseif key == "h" then
                    key = "Left"
                  elseif key == "l" then
                    key = "Right"
                  end
                end

                --
                if key == "Escape" then
                    restore()
                    -- awful.tag.history.restore()
                    return false
                elseif key == "Return" then
                    selectfn(restore)(capi.client.focus)
                    return false
                elseif key == "Left" or key == "Right" or
                    key == "Up" or key == "Down" then
                    print(key)
                    awful.client.focus.bydirection(key:lower())
                end
                return true
           end
end

--- Implement Exposé (from Mac OS X).
-- @param class The class of clients to expose, or nil for all clients.
-- @param fn A binary function f(t, n) to set the layout for tag t for n clients, or nil for the default layout.
-- @param s The screen to consider clients of, or nil for "current screen".
function revelation(class, fn, s)
    local screen = s or capi.mouse.screen
    local layout_fn = fn or layout.default
    -- local data = otable()

    local t = awful.tag.selected()

    local oset = {}
    oset.mwfact = awful.tag.getmwfact(t)
    oset.ncol = awful.tag.getncol(t)
    oset.nmaster = awful.tag.getnmaster(t)
    oset.layout = awful.tag.getproperty(t,"layout")

    oset.clients = t.clients(t)

    local allc = capi.client.get(screen)
    if #allc == 0 then
        return
    end

    layout_fn(t, #allc)

    t:clients(allc)

    local function restore()
      local t = awful.tag.selected()
      for i,c in pairs(allc) do
        if not oset.clients[c] then
          awful.client.toggletag(t,c)
        end
      end
      awful.tag.setproperty(t,"layout",oset.layout)
      awful.tag.setnmaster(oset.nmaster,t)
      awful.tag.setmwfact(oset.mwfact, t)
      awful.tag.setncol(oset.ncol, t)
      awful.tag.viewonly(t)

      capi.keygrabber.stop()
    end

    awful.tag.viewonly(t)
    capi.keygrabber.run(keyboardhandler(restore))
end
