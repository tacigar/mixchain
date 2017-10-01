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

menu = {}

local opts = { "start", "option", "quit" }

function menu:load()
	gamestate = "menu"
	self.selectindex = 1
	self.selectblink = true
	self.selectblinktimer = 0
	self.selectblinkrate = 0.3
end

function menu:update(dt)
	self.selectblinktimer = self.selectblinktimer + dt
	if self.selectblinktimer > self.selectblinkrate then
		self.selectblink = not self.selectblink
		self.selectblinktimer = 0
	end
end

function menu:draw()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(images["background"]["menu"], 0, 0, 0, scale, scale)

	for i, v in ipairs(opts) do
		local x = util.round((160 - (v:len() * 8)) / 2)
		local y = 90 + 15 * (i - 1)
		if self.selectindex == i then
			love.graphics.setColor(255, 255, 255, 255)
			love.graphics.print('>', (x - 8) * scale, y * scale, 0, scale, scale)
			if self.selectblink then
				love.graphics.setColor(255, 255, 255, 255)
			else
				love.graphics.setColor(150, 150, 150, 150)
			end
		else
			love.graphics.setColor(150, 150, 150, 150)
		end
		love.graphics.print(v, x * scale, y * scale, 0, scale, scale)
	end
end

function menu:keypressed(key)
	if key == 's' then
		self.selectindex = self.selectindex + 1
		if self.selectindex > 3 then
			self.selectindex = 1
		end

	elseif key == 'w' then
		self.selectindex = self.selectindex - 1
		if self.selectindex < 1 then
			self.selectindex = 3
		end

	elseif key == "return" then
		local opt = opts[self.selectindex]
		if opt == "start" then
			game:load()
			return
		elseif opt == "option" then
			option:load()
			return
		elseif opt == "quit" then
			love.event.quit()
			return
		end

	elseif key == "escape" then
		love.event.quit()
		return
	end
end
