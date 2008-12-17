-- puts text on screen using osdcat
function printOsd(text,pos,color)
    local font='-bitstream-bitstream\\ vera\\ sans-bold-r-*-*-17-*-*-*-*-*-*-*'
    local osdcmd='osd_cat --align=center --delay=1 --font=' .. font

    -- kill any already running osd_cat
    os.execute("kill $(/usr/bin/pgrep osd_cat) > /dev/null 2>&1 ")
    awful.util.spawn("echo "..text..' | '..osdcmd .. " --pos=" .. pos .. " " ..  "--color=" .. color )
end 
