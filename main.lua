Pastelizer = {}

require("util")
require("components/slider")

math.randomseed(
  love.timer.getDelta() / math.random()
)

function love.load()
  local starterColors = {
    Pastelizer:RGB(247, 223, 31),
    Pastelizer:RGB(237, 41, 57),
    Pastelizer:RGB(106, 79, 236),
    Pastelizer:RGB(247, 106, 140)
  }

  Pastelizer.Color = starterColors[math.random(1, #starterColors)]

  Pastelizer.PastelColor = Pastelizer.Color
  Pastelizer.ColorText = Pastelizer.Color.hex

  Pastelizer.PastelLevel = 2

  Pastelizer.Fonts = {
    Semibold = love.graphics.newFont("assets/fonts/poppins_semibold.ttf", 24),
    Bold = love.graphics.newFont("assets/fonts/poppins_bold.ttf", 48)
  }

  local w, h = love.graphics.getDimensions()
  local p = math.ceil(h * 0.025)

  Pastelizer.PastelLevelSlider = Pastelizer.Slider(w / 4 + w / 2, h - p * 2, w / 2 - p * 4, Pastelizer.PastelLevel, 0, Pastelizer.PastelLevel * 2, function(value)
    if Pastelizer.PastelLevel == value then return end

    Pastelizer.PastelLevel = value
  end)

  for i = 0, Pastelizer.PastelLevel * 2 do
    Pastelizer.PastelLevelSlider:setValue(i)
  end

  Pastelizer.PastelLevelSlider:setValue(0.6)

  Pastelizer.Buttons = {
    {
      text = "Copy",
      onClick = function()
        love.system.setClipboardText("#" .. Pastelizer.ColorText)
      end
    },
    {
      text = "Paste",
      onClick = function()
        Pastelizer.ColorText = love.system.getClipboardText():gsub("#", ""):sub(1, 6)
      end
    }
  }

  love.keyboard.setKeyRepeat(true)
  love.audio.setVolume(0.1)
end

function love.textinput(t)
  if #Pastelizer.ColorText < 6 then
    Pastelizer.ColorText = Pastelizer.ColorText .. t
  end
end

local utf8 = require("utf8")
function love.keypressed(key)
  if key == "backspace" then
    local byteOffset = utf8.offset(Pastelizer.ColorText, -1)

    if byteOffset then
      Pastelizer.ColorText = string.sub(Pastelizer.ColorText, 1, byteOffset - 1)
    end
  end

  local osString = love.system.getOS()
  local control

  if osString == "OS X" then
    control = love.keyboard.isDown("lgui", "rgui")
  elseif osString == "Windows" or osString == "Linux" then
    control = love.keyboard.isDown("lctrl", "rctrl")
  end

  if control then
    if key == "c" then
      love.system.setClipboardText("#" .. Pastelizer.PastelColor.hex)
    end

    if key == "v" then
      Pastelizer.ColorText = love.system.getClipboardText():gsub("#", ""):sub(1, 6)
    end
  end
end

function love.update(deltaTime)
  Pastelizer.PastelLevelSlider:update()
end

local function round(x, y)
	local mult = 10 ^ (y or 0)
	return math.floor(x * mult + 0.5) / mult
end

function love.draw()
  local w, h = love.graphics.getDimensions()

  local currentColor = Pastelizer.Color
  local parsedColor = Pastelizer:HexToRGB(Pastelizer.ColorText)

  local rgbParsedColor = Pastelizer:RGB(unpack(parsedColor, 1, 3))
  if currentColor:ToString() ~= rgbParsedColor:ToString() then
    if parsedColor[1] and parsedColor[2] and parsedColor[3] then
      Pastelizer.Color = rgbParsedColor

      Pastelizer.PastelColor = Pastelizer.Color
      Pastelizer.PastelLevel = 2

      for i = 0, Pastelizer.PastelLevel * 2 do
        Pastelizer.PastelLevelSlider:setValue(i)
      end

      Pastelizer.PastelLevelSlider.max = Pastelizer.PastelLevel * 2
      Pastelizer.PastelLevelSlider:setValue(0.6)
    end
  end

  Pastelizer.PastelColor = Pastelizer:Lighten(Pastelizer.Color, Pastelizer.PastelLevel)

  love.graphics.setColor(Pastelizer.Color:Unpack())
  love.graphics.rectangle("fill", 0, 0, w / 2, h)

  love.graphics.setColor(Pastelizer.PastelColor:Unpack())
  love.graphics.rectangle("fill", w / 2, 0, w / 2, h)

  local text = "#" .. Pastelizer.ColorText:lower()

  local fontWidth = Pastelizer.Fonts.Bold:getWidth(text)
  local fontHeight = Pastelizer.Fonts.Bold:getHeight()

  local p = math.ceil(h * 0.025)
  local debug = love.keyboard.isDown("d")

  love.graphics.setColor(Pastelizer:GetContrastColor(Pastelizer.Color):Unpack())
  love.graphics.setFont(Pastelizer.Fonts.Bold)
  love.graphics.print(text, w / 4 - fontWidth / 2, h / 2 - fontHeight / 2)

  if debug then
    local relativeLuminance, dR = Pastelizer:GetRelativeLuminance(Pastelizer.Color)

    love.graphics.setFont(Pastelizer.Fonts.Semibold)
    love.graphics.print(round(relativeLuminance, 2) .. "/" .. dR, p, p)
  end

  local totalWidth = 0
  local buttonHeight = Pastelizer.Fonts.Semibold:getHeight() + 16

  love.graphics.setFont(Pastelizer.Fonts.Semibold)

  local colorR, colorG, colorB = love.graphics.getColor()
  for i, button in ipairs(Pastelizer.Buttons) do
    local x, y = p + totalWidth, h - buttonHeight - p

    local width = Pastelizer.Fonts.Semibold:getWidth(button.text) + 16
    local isHovered = Pastelizer:IsHovering(x, y, width, buttonHeight)

    button.last = button.now
    button.now = love.mouse.isDown(1)

    love.graphics.setColor(colorR, colorG, colorB)
    love.graphics.rectangle(isHovered and "fill" or "line", x, y, width, buttonHeight)

    totalWidth = totalWidth + width + p

    if isHovered then
      love.graphics.setColor(Pastelizer.Color:Unpack())
    end

    love.graphics.print(button.text, x + width / 2 - (width - 16) / 2, y + buttonHeight / 2 - (buttonHeight - 16) / 2)

    if isHovered and button.now and not button.last then
      button.onClick()

      local hint = love.audio.newSource("assets/sounds/hint.wav", "static")
      love.audio.play(hint)
    end
  end

  text = "#" .. Pastelizer.PastelColor.hex

  love.graphics.setColor(Pastelizer:GetContrastColor(Pastelizer.PastelColor):Unpack())
  love.graphics.setFont(Pastelizer.Fonts.Bold)
  love.graphics.print(text, w / 2 + w / 4 - Pastelizer.Fonts.Bold:getWidth(text) / 2, h / 2 - fontHeight / 2)

  local relativeLuminance, dR = Pastelizer:GetRelativeLuminance(Pastelizer.PastelColor)
  if relativeLuminance >= 1 or not Pastelizer:IsSameRatio(Pastelizer.PastelColor, Pastelizer.Color) then
    Pastelizer.PastelLevelSlider.max = Pastelizer.PastelLevelSlider.max / 2
  end

  if debug then
    love.graphics.setFont(Pastelizer.Fonts.Semibold)
    love.graphics.print(round(relativeLuminance, 2) .. "/" .. dR, w / 2 + p, p)
  end

  love.graphics.setLineWidth(3)
  love.graphics.setFont(Pastelizer.Fonts.Semibold)

  local percentage = round(100 * Pastelizer.PastelLevel / Pastelizer.PastelLevelSlider.max)
  if debug then
    love.graphics.print(string.format("Pastel Level: %s%% (%s/%s)", percentage, round(Pastelizer.PastelLevel, 1), round(Pastelizer.PastelLevelSlider.max, 1)), w / 2 + p, h - Pastelizer.Fonts.Semibold:getHeight() - p * 3.5)
  else
    love.graphics.print(string.format("Pastel Level: %s%%", percentage), w / 2 + p, h - Pastelizer.Fonts.Semibold:getHeight() - p * 3.5)
  end

  Pastelizer.PastelLevelSlider:draw()
end