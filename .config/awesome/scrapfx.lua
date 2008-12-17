--[[ function mocp()

  if (io.popen('pgrep mocp'):read() ~= nil) then
    local np = {}
    np.file =io.popen('mocp -Q %title'):read() 
    for line in io.popen('LC_ALL=en_US.utf8 mocp -i'):lines() do
      -- line = awful.util.escape(line)
      if ( string.find(line, 'State:') ~= nil) then
        np.status = " || "
        if ( string.gsub(line,'State:%s','') == "PLAY" ) then
          np.status = " >>"
        end  
      elseif ( string.find(line, 'Artist') ~= nil) then
        np.status = np.status .. " " .. string.gsub(line,'Artist:%s','')
      elseif ( string.find(line, 'SongTitle') ~= nil) then
        np.status = np.status .. ": " .. string.gsub(line,'SongTitle:%s','')
      end
    end
    tstr = string.sub(np.status,iScroller,maxCh+iScroller-1)
    if maxCh+iScroller > string.len(np.status) then
        tstr = tstr .. " " .. string.sub(np.status,1,(maxCh+iScroller)-string.len(np.status))
    end
    mocpwidget.text = awful.util.escape(tstr)
    if iScroller <= string.len(np.status) then
        iScroller = iScroller +1
    else
        iScroller = 1
    end
  else
    mocpwidget.text = "#"
  end
end
-- ]]--


