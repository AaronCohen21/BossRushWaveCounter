local utils = {}

function utils:getScreenSize()
    -- By Kilburn himself.
    local room = Game():GetRoom()
    local pos = Isaac.WorldToScreen(Vector(0, 0)) - room:GetRenderScrollOffset() - Game().ScreenShakeOffset

    local rx = pos.X + 60 * 26 / 40
    local ry = pos.Y + 140 * (26 / 40)

    return rx * 2 + 13 * 26, ry * 2 + 7 * 26
end

return utils