Database = {}

---@type table
---Local table that stores all mangas that is in database
local base = {}

local function get_key(Manga)
    return (Manga.ParserID .. Manga.Link):gsub("%p", "")
end
---Gets Manga list from database
function Database.getMangaList()
    local b = {}
    for k, v in ipairs(base) do
        b[k] = v
    end
    return b
end

---@param manga table
---Adds `manga` to database
function Database.add(manga)
    local key = get_key(manga)
    if not base[key] then
        base[#base + 1] = manga
        base[key] = #base
        Database.save()
    end
end

---@param manga table
---Checks if `manga` is in database
function Database.check(manga)
    return base[get_key(manga)] ~= nil
end
function Database.checkByKey(key)
    return base[key] ~= nil
end

---@param manga table
---Removes `manga` from database
function Database.remove(manga)
    local key = get_key(manga)
    if base[key] then
        local n = base[key]
        table.remove(base, n)
        base[key] = nil
        for i = n, #base do
            local k = get_key(base[i])
            base[k] = base[k] - 1
        end
        Database.save()
    end
end

---Saves database to `ux0:data/noboru/save.dat`
function Database.save()
    local manga_table = {}
    for k, v in ipairs(base) do
        local key = get_key(v)
        manga_table[k] = CreateManga(v.Name, v.Link, v.ImageLink, v.ParserID, v.RawLink)
        manga_table[k].Data = v.Data
        manga_table[k].Path = "cache/" .. key .. "/cover.image"
        manga_table[key] = k
    end
    local save = "local " .. table.serialize(manga_table, "base") .. "\nreturn base"
    if System.doesFileExist("ux0:data/noboru/save.dat") then
        System.deleteFile("ux0:data/noboru/save.dat")
    end
    local f = System.openFile("ux0:data/noboru/save.dat", FCREATE)
    System.writeFile(f, save, save:len())
    System.closeFile(f)
end

---Loads database from `ux0:data/noboru/save.dat`
function Database.load()
    if System.doesFileExist("ux0:data/noboru/save.dat") then
        local f = System.openFile("ux0:data/noboru/save.dat", FREAD)
        local suc, new_base = pcall(function() return load(System.readFile(f, System.sizeFile(f)))() end)
        System.closeFile(f)
        if suc then
            base = new_base
        end
    end
    Database.save()
end

function Database.clear()
    base = {}
    Database.save()
end
