local function findFunction(name, identifier, expectedType)
    for _ = 1, 10 do
        for _, v in next, getgc(true) do
            if type(v) == "table" and type(rawget(v, name)) == expectedType then
                if identifier then
                    local info = getinfo(v[name])
                    if info and info.source:find(identifier) then
                        return v[name]
                    end
                else
                    return v[name]
                end
            end
        end
        wait(0.1) -- Wait before retrying
    end
    return nil
end

-- Find the melee and gun functions safely
local rcFunction = findFunction("lol", ".RCHB", "function")
local grcFunction = findFunction("ONRH_S4", nil, "function")

-- Patch the constants in both functions
local function patchFunction(targetFunction, valuesToReplace, newValue)
    if targetFunction then
        for i, v in next, getconstants(targetFunction) do
            if table.find(valuesToReplace, v) then
                setconstant(targetFunction, i, newValue)
            end
        end
    else
        warn("Failed to get a crucial function.")
    end
end

local numberT = 20
patchFunction(rcFunction, {1.75, 10}, numberT)
patchFunction(grcFunction, {1.5, 10}, numberT)

-- Ensure head size stays normal
local DefHeadSize = game.Players.LocalPlayer.Character:WaitForChild("Head").Size
local Lighting = game.Lighting
local DefaultAmbient = Lighting.Ambient

-- Prevent game scripts from restoring values
local oldIndex, oldNewIndex

oldIndex = hookmetamethod(game, "__index", newcclosure(function(tab, key)
    if tab and type(tab) == "userdata" and key then
        if not checkcaller() and oldIndex(tab, "ClassName") == "Part" and key == "Size" then
            if oldIndex(tab, "Name") == "Head" then
                return DefHeadSize
            end
        end
    end
    return oldIndex(tab, key)
end))

oldNewIndex = hookmetamethod(game, "__newindex", newcclosure(function(tab, key, value)
    if not checkcaller() then
        if tab == Lighting and key == "Ambient" then
            return oldNewIndex(tab, key, _G.FullBright and _G.FullBrightColor or DefaultAmbient)
        end
    end
    return oldNewIndex(tab, key, value)
end))
