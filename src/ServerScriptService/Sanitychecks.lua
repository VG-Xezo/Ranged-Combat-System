local Sanitychecks = {}
local PlayerWarns = {}

local function warnPlayer(player: Player)

    local playerWarn = PlayerWarns[player.Name]

    if playerWarn then
        PlayerWarns[player.Name] += 1
        if PlayerWarns[player.Name] >= 5 then
            player:Kick("Suspiscious Client Activity")
        end
    else
        PlayerWarns[player.Name] = 1
    end

    print(PlayerWarns)

end

function Sanitychecks.checkDistance(player: Player, pos1: Vector3, pos2: Vector3, maxDistance: number)
    if (pos1 - pos2).Magnitude < maxDistance then
        return true
    else
        warnPlayer(player)
        return false
    end
end

return Sanitychecks