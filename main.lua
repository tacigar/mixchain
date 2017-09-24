---------------------------------------------------------------------
-- mixchain
-- Copyright (C) 2017 tacigar
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
---------------------------------------------------------------------

function love.load()
	love.window.setTitle("MixChain")
	love.graphics.setDefaultFilter("nearest", "nearest")
	love.graphics.setBackgroundColor(0, 0, 0)
	love.graphics.clear()
	love.audio.setVolume(0.2)

	math.randomseed(os.time())

	require "util"
	require "animation"
	require "effect"
	require "dropair"
	require "field"
	require "game"

	controls = {}
	controls["up"]          = { "w", 12 }
	controls["right"]       = { "d", 15 }
	controls["left"]        = { "a", 14 }
	controls["down"]        = { "s", 13 }
	controls["moveright"]   = { "d", 15 }
	controls["moveleft"]    = { "a", 14 }
	controls["movedown"]    = { "s", 13 }
	controls["rotateleft"]  = { "j",  1 }
	controls["rotateright"] = { "l",  2 }
	controls["decide"]      = { "return", 1 }
	controls["cancel"]      = { "escape", 2 }
	controls["start"]       = { "escape", 8 }

	colors = {}
	colors["red"]    = { r = 255, g =   0, b =   0 }
	colors["blue"]   = { r =   0, g =   0, b = 255 }
	colors["purple"] = { r = 255, g =   0, b = 255 }
	colors["yellow"] = { r = 255, g = 255, b =   0 }
	colors["green"]  = { r =   0, g = 255, b =   0 }

	images = {}
	images["drop"] = {}
	images["drop"]["red"]    = love.graphics.newImage("textures/drop-red.png")
	images["drop"]["blue"]   = love.graphics.newImage("textures/drop-blue.png")
	images["drop"]["green"]  = love.graphics.newImage("textures/drop-green.png")
	images["drop"]["purple"] = love.graphics.newImage("textures/drop-purple.png")
	images["drop"]["yellow"] = love.graphics.newImage("textures/drop-yellow.png")

	images["effect"] = {}
	images["effect"][1] = love.graphics.newImage("textures/effect-01.png")

	sounds = {}
	sounds["bgm"] = {}
	sounds["bgm"][1] = love.audio.newSource("media/bgm-01.mp3")
	sounds["se"] = {}
	sounds["se"][1] = love.audio.newSource("media/se-01.mp3", "static")
	sounds["se"][2] = love.audio.newSource("media/se-02.mp3", "static")
	sounds["se"][3] = love.audio.newSource("media/se-03.mp3", "static")
	sounds["se"][4] = love.audio.newSource("media/se-04.mp3", "static")
	sounds["se"][5] = love.audio.newSource("media/se-05.mp3", "static")

	joystick = love.joystick.getJoysticks()[1]

	falltimeinterval = 1

	game:load()
end

function love.update(dt)
	if gamestate == "menu" then
		menu:update(dt)
	elseif gamestate == "game" then
		game:update(dt)
	end
end

function love.draw()
	if gamestate == "menu" then
		menu:draw()
	elseif gamestate == "game" then
		game:draw()
	end
end

function drawdrop(x, y, color)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(images["drop"][color], x, y, 0)
end

function transformcoordinate(x, y)
	return (x - 1) * 50 + 75, (12 - y) * 50 + 75
end

function checkcontrols(k)
	if love.keyboard.isDown(controls[k][1]) or joystick and joystick:isDown(controls[k][2]) then
		return true
	end
	return false
end
