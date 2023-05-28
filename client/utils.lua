local utils = {}

--- Return formatted version of a value
---@param amount number
---@return string
function utils.comma_value(amount)
    local formatted = amount
    local k
    repeat
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    until k == 0
    return formatted
end

--- Draws Text onto the screen during test drive
---@param text string
---@param font number
---@param x number
---@param y number
---@param scale number 0.0-10.0
---@param r number red 0-255
---@param g number green 0-255
---@param b number blue 0-255
---@param a number alpha channel
function utils.drawTxt(text, font, x, y, scale, r, g, b, a)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextOutline()
    SetTextCentre(1)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

return utils