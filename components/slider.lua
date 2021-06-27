local Slider = {}
Slider.__index = Slider

function Slider:constructor(x, y, length, value, min, max, setter, vertical)
  local slider = {
    x = x or 0,
    y = y or 0,

    oX = 0,
    oY = 0,

    grabbed = false,
    wasDown = true,

    length = length,
    width = length * 0.1,

    vertical = vertical or false,

    min = min,
    max = max,
    value = (value - min) / (max - min),

    setter = setter
  }

  return setmetatable(slider, Slider)
end

function Slider:getValue()
  return self.min + self.value * (self.max - self.min)
end

function Slider:setValue(value)
  self.value = (value - self.min) / (self.max - self.min)
  return self
end

function Slider:update(mX, mY, mD)
  mX = mX or love.mouse.getX()
  mY = mY or love.mouse.getY()
  mD = mD or love.mouse.isDown(1)

  local knobX = self.x
  local knobY = self.y

  if self.vertical then
    knobY = self.y + self.length / 2 - self.length * self.value
  else
    knobX = self.x - self.length / 2 + self.length * self.value
  end

  local oX = mX - knobX
  local oY = mY - knobY

  local dX = oX - self.oX
  local dY = oY - self.oY

  if mD then
    if self.grabbed then
      self.value = self.value + (self.vertical and dY or dX) / self.length
    elseif (mX > knobX - self.width / 2 and mX < knobX + self.width / 2 and mY > knobY - self.width / 2 and mY < knobY + self.width / 2) and not self.wasDown then
      self.oX = oX
      self.oY = oY

      self.grabbed = true
    end
  else
    self.grabbed = false
  end

  self.value = math.max(0, math.min(1, self.value))

  if type(self.setter) == "function" then
    self.setter(self:getValue())
  end

  self.wasDown = mD
end

function Slider:draw()
  if self.vertical then
    love.graphics.rectangle("line", self.x - self.width / 2, self.y - self.length / 2 - self.width / 2, self.width, self.length + self.width)
  else
    love.graphics.rectangle("line", self.x - self.length / 2 - self.width / 2, self.y - self.width / 2, self.length + self.width, self.width)
  end

  local knobX = self.x
  local knobY = self.y

  if self.vertical then
    knobY = self.y + self.length / 2 - self.length * self.value
  else
    knobX = self.x - self.length / 2 + self.length * self.value
  end

  love.graphics.rectangle("fill", knobX - self.width / 2, knobY - self.width / 2, self.width, self.width)
end

setmetatable(Slider, {
  __call = Slider.constructor
})

Pastelizer.Slider = Slider