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

effect = {}
effect.__index = effect

setmetatable(effect, {
	__call = function(_, img, w, h, duration, x, y, sx, sy, repeattime)
		local self = setmetatable({}, effect)

		self.x = x
		self.y = y
		self.sx = sx or 1
		self.sy = sy or 1
		self.repeattime = repeattime or 1
		self.repeatcount = 0
		self.image = img
		self.quads = {}
		self.duration = duration
		self.timer = 0
		self.isstopped = false

		for y = 0, img:getHeight() - h, h do
			for x = 0, img:getWidth() - w, w do
				table.insert(self.quads, love.graphics.newQuad(x, y, w, h, img:getDimensions()))
			end
		end
		return self
	end,
	__index = animation,
})

function effect:update(dt)
	if not self.isstopped then
		self.timer = self.timer + dt
		if self.timer > self.duration then
			self.repeatcount = self.repeatcount + 1
			if self.repeatcount > self.repeattime then
				self.isstopped = true
			end
			self.timer = self.timer - self.duration
		end
	end
end

function effect:draw()
	local n = math.floor(self.timer / self.duration * #self.quads) + 1

	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(self.image, self.quads[n], self.x * scale, self.y * scale, 0, self.sx * scale, self.sy * scale)
end
