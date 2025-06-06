function backupDatabase()
    local f = fileOpen("forgex.db")
    local data = fileRead(f, fileGetSize(f))
    fileClose(f)
    local backup = fileCreate("backup/forgex_"..os.date("%Y%m%d%H%M")..".db")
    fileWrite(backup, data)
    fileClose(backup)
end
setTimer(backupDatabase, 3600000, 0) -- backup a cada hora