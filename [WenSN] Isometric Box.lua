---------------------------------------
-- USER DEFAULTS --
---------------------------------------
local c = app.fgColor;

-- Default colors:
local colors = {
  stroke = Color{h=0, s=0, v=0, a=255},
  top = app.fgColor,
  left = Color{h=c.hsvHue, s=c.hsvSaturation+0.3, v=c.hsvValue-0.1, a=255},
  right = Color{h=c.hsvHue, s=c.hsvSaturation+0.3, v=c.hsvValue-0.4, a=255},
}

-- Use 3px corner by default:
local use3pxCorner = false

-- Default Max Sizes:
local maxSize = {
  x = math.floor(app.activeSprite.width/4), 
  y = math.floor(app.activeSprite.width/4), 
  z = math.floor(app.activeSprite.height/2)
}



---------------------------------------
-- Colors Utility --
---------------------------------------
local function colorAsPixel(color)
  return app.pixelColor.rgba(color.red, color.green, color.blue, color.alpha)
end

local function isColorEqual(a, b)
  local pc = app.pixelColor
  
  return pc.rgbaR(a) == pc.rgbaR(b) and
         pc.rgbaG(a) == pc.rgbaG(b) and
         pc.rgbaB(a) == pc.rgbaB(b) and
         pc.rgbaA(a) == pc.rgbaA(b)
end

local function isColorEqualAt(x, y, color)
  local pc = app.pixelColor
  local pickedColor = app.activeImage:getPixel(x, y)

  return isColorEqual(pickedColor, color)
end

---------------------------------------
-- Flood Fill --
-- Paint Bucket Tool implementation --
---------------------------------------
local function floodFill(x, y, targetColor, replacementColor)
  if isColorEqual(targetColor, replacementColor) then return end
  if not isColorEqualAt(x, y, targetColor) then return end
  
  app.activeImage:putPixel(x, y, replacementColor)
  
  floodFill(x+1, y, targetColor, replacementColor)
  floodFill(x-1, y, targetColor, replacementColor)
  floodFill(x, y+1, targetColor, replacementColor)
  floodFill(x, y-1, targetColor, replacementColor)
end

---------------------------------------
-- BASIC LINES --
---------------------------------------
local function hLine(color, x, y, len)
  -- Horizontal Line
  for i = 1, len do
    app.activeImage:putPixel(x+i, y, color)
  end
end

local function vLine(color, x, y, len)
  -- Vertical Line
  for i = 1, len do
    app.activeImage:putPixel(x, y+i, color)
  end
end

---------------------------------------
-- ISOMETRIC LINES --
---------------------------------------
--TODO: Compile these functions into one universal isoLine(direction)
local function isoLineDownRight(color, x, y, len)
  for i=0,len do
    x1 = i*2
    x2 = x1+1
    app.activeImage:putPixel(x+x1, y+i, color)
    app.activeImage:putPixel(x+x2, y+i, color)
  end
end

local function isoLineDownLeft(color, x, y, len)
  for i=0,len do
    x1 = i*2
    x2 = x1+1
    app.activeImage:putPixel(x-x1, y+i, color)
    app.activeImage:putPixel(x-x2, y+i, color)
  end
end

local function isoLineUpRight(color, x, y, len)
  for i=0,len do
    x1 = i*2
    x2 = x1+1
    app.activeImage:putPixel(x+x1, y-i, color)
    app.activeImage:putPixel(x+x2, y-i, color)
  end
end

local function isoLineUpLeft(color, x, y, len)
  for i=0,len do
    x1 = i*2
    x2 = x1+1
    app.activeImage:putPixel(x-x1, y-i, color)
    app.activeImage:putPixel(x-x2, y-i, color)
  end
end

---------------------------------------
-- FINAL CUBE --
---------------------------------------
local function drawCube(type, xSize, ySize, zSize, color)
  --[[
    Dimensions:
      X: right side
      Y: left side
      Z: is height
    
    Type can be 1 or 2:
      1 is for 3px corner
      2 is for 2px corner
  ]]--
  local centerX = math.floor(app.activeSprite.width/2)
  local centerY = math.floor(app.activeSprite.height/2)
  
  local a, b
  if (type == 1) then 
    -- 3 px corner
    a = 0
    b = 1
  elseif (type == 2) then
    -- 2 px corner
    a = 1
    b = 0
  else
    -- 4 px corner
    a = -1
    b = 2   -- veya b = 2; bu çizim mantığınıza göre değişebilir
  end
  
  --top plane
  
  isoLineUpRight(color, centerX-a, centerY, xSize) --bottom right
  isoLineUpLeft(color, centerX, centerY, ySize) --bottom left
  isoLineUpLeft(color, centerX+xSize*2+b, centerY-xSize-1, ySize) --top right
  isoLineUpRight(color, centerX-ySize*2-1, centerY-ySize-1, xSize) --top left

  --bottom plane
  isoLineUpRight(color, centerX-a, centerY+zSize, xSize) --right
  isoLineUpLeft(color, centerX, centerY+zSize, ySize) --left

  --vertical lines
  vLine(color, centerX, centerY, zSize) --middle
  vLine(color, centerX-ySize*2-1, centerY-ySize, zSize) --left
  vLine(color, centerX+xSize*2+b, centerY-xSize, zSize) --right
  vLine(color, centerX+1, centerY, zSize) --middle
end


------------ Adding Colors: ------------

local function fillCubeSides(type, topColor, leftColor, rightColor)
  local centerX = math.floor(app.activeSprite.width/2)
  local centerY = math.floor(app.activeSprite.height/2)

  local TRANSPARENT_COLOR = app.pixelColor.rgba(0, 0, 0, 0)

  if (type == 1) then
    -- 3 px corner offsets
    floodFill(centerX,     centerY-1, TRANSPARENT_COLOR, colorAsPixel(topColor))
    floodFill(centerX-2,   centerY+1, TRANSPARENT_COLOR, colorAsPixel(leftColor))
    floodFill(centerX+1,   centerY+1, TRANSPARENT_COLOR, colorAsPixel(rightColor))

  elseif (type == 2) then
    -- 2 px corner offsets
    floodFill(centerX,     centerY-1, TRANSPARENT_COLOR, colorAsPixel(topColor))
    floodFill(centerX-2,   centerY+1, TRANSPARENT_COLOR, colorAsPixel(leftColor))
    floodFill(centerX+1,   centerY+1, TRANSPARENT_COLOR, colorAsPixel(rightColor))

  else
    -- 4 px corner offsets (deneme yanılma ile ayarlanmalı)
    floodFill(centerX,     centerY-2, TRANSPARENT_COLOR, colorAsPixel(topColor))
    floodFill(centerX-3,   centerY+2, TRANSPARENT_COLOR, colorAsPixel(leftColor))
    floodFill(centerX+2,   centerY+2, TRANSPARENT_COLOR, colorAsPixel(rightColor))
  end
end


---------------------------------------
-- LAYER MANAGEMENT --
---------------------------------------
local function newLayer(name)
  s = app.activeSprite
  lyr = s:newLayer()
  lyr.name = name
  s:newCel(lyr, 1)
  
  return lyr
end


---------------------------------------
-- USER INTERFACE --
---------------------------------------
local dlg = Dialog("[KAM] Isometric Box")
dlg   :separator{ text="Size:" }
      :slider {id="ySize", label="Left:", min=1, max=maxSize.y, value=7}
      :slider {id="xSize", label="Right:", min=1, max=maxSize.x, value=7}
      :slider {id="zSize", label="Height:", min=3, max=maxSize.z, value=16}

      :separator{ text="Colors:" }
      :color {id="color", label="Stroke:", color = colors.stroke}
      :color {id="topColor", label="Top:", color = colors.top}
      :color {id="leftColor", label="Left:", color = colors.left}
      :color {id="rightColor", label="Right:", color = colors.right}

      :separator()
      :radio {
        id="typeThree",
        label="Corner:",
        text="4 px",
        selected=(use3pxCorner == 3)
      }

      :separator()
      :button {
        id="ok",
        text="Add Box",
        onclick=function()
          local data = dlg.data
          app.transaction(function()
            local cubeType
            if data.typeOne then
              cubeType = 1   -- 3 px
            elseif data.typeTwo then
              cubeType = 2   -- 2 px
            else
              cubeType = 3   -- 4 px (yeni eklediğimiz)
            end
      
            newLayer("Cube("..data.xSize.." "..data.ySize.." "..data.zSize..")")
            drawCube(cubeType, data.xSize, data.ySize, data.zSize, data.color)
            fillCubeSides(cubeType, data.topColor, data.leftColor, data.rightColor)
          end)
          -- Refresh screen
          app.command.Undo()
          app.command.Redo()
        end
      }
      :show{wait=false}

---------------------------------------
