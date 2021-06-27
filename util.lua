function Pastelizer:RGB(r, g, b, a)
  r = r or 255
  g = g or 255
  b = b or 255
  a = a or 255

  return {
    r = r,
    g = g,
    b = b,
    a = a,

    hex = self:RGBToHex(r, g, b),

    Unpack = function(self)
      return self.r / 255, self.g / 255, self.b / 255, self.a / 255
    end,

    ToString = function(self)
      return "rgb(" .. self.r .. ", " .. self.g .. ", " .. self.b .. ")"
    end
  }
end

function Pastelizer:RGBToHex(r, g, b)
  local rgb = (r * 0x10000) + (g * 0x100) + b
  return string.format("%x", rgb)
end

function Pastelizer:HexToRGB(hex)
  hex = hex:gsub("#", "")

  -- if string.len(hex) == 3 then
	-- 	return {
  --     tonumber("0x" .. hex:sub(1, 1)) * 17,
  --     tonumber("0x" .. hex:sub(2, 2)) * 17,
  --     tonumber("0x" .. hex:sub(3, 3)) * 17
  --   }
  -- end

  return {
    tonumber("0x" .. hex:sub(1, 2)),
    tonumber("0x" .. hex:sub(3, 4)),
    tonumber("0x" .. hex:sub(5, 6))
  }
end

local defaultDarkRequirement = 0.21
function Pastelizer:GetRelativeLuminance(color)
  local R, G, B = 0, 0, 0

  local RsRGB = color.r / 255
  local GsRGB = color.g / 255
  local BsRGB = color.b / 255

  if RsRGB <= 0.03928 then R = RsRGB / 12.92 else R = ((RsRGB + 0.055) / 1.055) ^ 2.4 end
  if GsRGB <= 0.03928 then G = GsRGB / 12.92 else G = ((GsRGB + 0.055) / 1.055) ^ 2.4 end
  if BsRGB <= 0.03928 then B = BsRGB / 12.92 else B = ((BsRGB + 0.055) / 1.055) ^ 2.4 end

  return 0.2126 * R + 0.7152 * G + 0.0722 * B, defaultDarkRequirement
end

function Pastelizer:GetContrastColor(color, lightColor, darkColor, darkRequirement)
  lightColor = lightColor or self:RGB(255, 255, 255)
  darkColor = darkColor or self:RGB(0, 0, 0)
  darkRequirement = darkRequirement or defaultDarkRequirement

  if self:GetRelativeLuminance(color) > (darkRequirement or defaultDarkRequirement) then
    return darkColor
  end

  return lightColor
end

local function clamp(x, y, z)
	return math.min(math.max(x, y), z)
end

function Pastelizer:Lighten(color, light)
  return self:RGB(
    clamp(math.floor(color.r + color.r * light), 0, 255),
    clamp(math.floor(color.g + color.g * light), 0, 255),
    clamp(math.floor(color.b + color.b * light), 0, 255),
    color.a
  )
end

function Pastelizer:IsSameRatio(color, originalColor)
  local diffR = color.r - originalColor.r
  local diffG = color.g - originalColor.g
  local diffB = color.b - originalColor.b

  local sumA = color.r + color.g + color.b
  local sumB = originalColor.r + originalColor.g + originalColor.b

  local diff = math.abs(sumA - sumB)

  if diffR + diffG + diffB ~= diff then
    return false
  end

  return true
end

function Pastelizer:IsHovering(x, y, w, h)
  local mx, my = love.mouse.getPosition()
  return mx >= x and mx <= x + w and my >= y and my < y + h
end