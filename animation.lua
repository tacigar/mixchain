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

animation = {}
animation.__index = animation

setmetatable(animation, {
	__call = function(_, img, w, h, duration)
		local self = setmetatable({}, animation)

		self.image = img
		self.quads = {}
		self.duration = duration
		self.timer = 0

		for y = 0, img:getHeight() - h, h do
			for x = 0, img:getWidth() - w, w do
				table.insert(self.quads, love.graphics.newQuad(x, y, w, h, img:getDimensions()))
			end
		end

		return self
	end,
})

function animation:update(dt)
	self.timer = self.timer + dt
	if self.timer >= self.duration then
		self.timer = self.timer - self.duration
	end
end

function animation:draw(x, y, sx, sy)
	local n = math.floor(self.timer / self.duration * #self.quads) + 1
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(self.image, self.quads[n], x, y, 0, sx, sy)
end
