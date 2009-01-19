---------------------------------------------------------------------------
-- @author Espen Wiborg &lt;espenhw@grumblesmurf.org&gt;
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008 Espen Wiborg, Julien Danjou
-- @release v3.1-rc3-14-gc7ee83f
---------------------------------------------------------------------------

local math = math
local table = table
local pairs = pairs
local button = button
local otable = otable
local awful =
{
    tag = require("awful.tag"),
    client = require("awful.client")
}
local capi =
{
    tag = tag,
    client = client,
    keygrabber = keygrabber,
    mouse = mouse
}

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
    t.layout = "tile"
    local columns = math.floor(math.sqrt(n))

    if columns > 1 then
        t.mwfact = 1 / columns
        t.ncol = columns - 1
    end
    t.nmaster = n / columns
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
    return function (mod, key)
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
                    awful.tag.history.restore()
                    return false
                elseif key == "Return" then
                    selectfn(restore)(capi.client.focus)
                    return false
                elseif key == "Left" or key == "Right" or
                    key == "Up" or key == "Down" then
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
    local data = otable()

    local clients = clients(class, screen)
    if #clients == 0 then
        return
    end

    local tag = capi.tag({ name = "Revelation" })
    tag.screen = screen

    layout_fn(tag, #clients)

    local function restore()
        for k, cl in pairs(tag:clients()) do
            -- Clear revelation tag
            local tags = cl:tags()
            if tags[tag] then
                tags[tags[tag]] = nil
            end
            cl:tags(tags)
            -- Restore client mouse bindings
            cl:buttons(data[cl])
            data[cl] = nil
        end
        tag.screen = nil
        capi.keygrabber.stop()
    end

    for k, c in pairs(clients) do
        data[c] = c:buttons()
        c:buttons({ button({}, 1, selectfn(restore)) })
    end
    tag:clients(clients)
    awful.tag.viewonly(tag)
    capi.keygrabber.run(keyboardhandler(restore))
end
