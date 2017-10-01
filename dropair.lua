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

dropair = {}
dropair.__index = dropair

setmetatable(dropair, {
	__call = function(_, x, y, colors, player)
		local self = setmetatable({}, dropair)

		self.player = player
		self.x = x
		self.y = y
		self.r = 0
		self.nextx = x
		self.nexty = y
		self.nextr = 0
		self.movespeed = 8
		self.rotatespeed = 600
		self.colors = colors
		self.falltime = 1
		self.falltimer = 0
		self.moveanimstate = "idle"
		self.rotateanimstate = "idle"

		return self
	end,
})

function dropair.calcchildposition(x, y, r)
	return {
		x = x + math.sin(math.rad(r)),
		y = y + math.cos(math.rad(r)),
	}
end

function dropair:fix()
	local field = self.player.field
	local poss = self:getpositions()

	for i, p in ipairs(poss) do
		local j = (i + 2) % 2 + 1

		-- Either one drop can falldown.
		if field:get(p.x, p.y - 1) == "no" and (p.x ~= poss[j].x and p.y - 1 ~= poss[j].y) then
			local y = p.y - 1

			while field:get(p.x, y) == "no" do
				y = y - 1
			end

			field:set(poss[j].x, poss[j].y, self.colors[j])
			self.player:changegamestate("fall", {
				{ x = p.x, y = p.y, desty = y + 1, color = self.colors[i]},
			})

			return
		end
	end
	for i, p in ipairs(poss) do
		field:set(p.x, p.y, self.colors[i])
	end

	local deletes, linknums, numcolors = field:delete()

	if #deletes == 0 then
		self.player:changegamestate("next")
	else
		self.player.scoremanager:chain(#deletes, linknums, numcolors)
		self.player:changegamestate("delete", deletes)
	end
end

function dropair:movedown()
	local field = self.player.field
	local poss = {
		{ x = self.x, y = self.y - 1 },
		dropair.calcchildposition(self.x, self.y - 1, self.nextr)
	}

	local enable = true
	for _, p in ipairs(poss) do
		if field:get(p.x, p.y) ~= "no" then
			enable = false
			break
		end
	end

	if enable then
		self.moveanimstate = "down"
		self.nextx = self.x
		self.nexty = self.y - 1
	elseif self.moveanimstate == "idle" and self.rotateanimstate == "idle" then
		self:fix()
	end
end

function dropair:move()
	local checks = util.shuffle{ "right", "left", "down" }
	local field = self.player.field

	for _, v in ipairs(checks) do
		if v == "right" and checkcontrols("right") or v == "left" and checkcontrols("left") then
			local dx = (v == "right") and 1 or -1
			local poss = {
				{ x = self.x + dx, y = self.y },
				dropair.calcchildposition(self.x + dx, self.y, self.nextr),
			}

			local enable = true
			for _, p in ipairs(poss) do
				if field:get(p.x, p.y) ~= "no" then
					enable = false
					break
				end
			end

			if enable then
				self.moveanimstate = v
				self.nextx = self.x + dx
				self.nexty = self.y
			end

		elseif v == "down" and checkcontrols("movedown") then
			self:movedown()
		end
	end
end

function dropair:rotate()
	local checks = util.shuffle{ "right", "left" }
	local field = self.player.field

	local function rotatecommon(dir, nextr)
		local cpos = dropair.calcchildposition(self.nextx, self.nexty, nextr)
		if field:get(cpos.x, cpos.y) == "no" then
			self.nextr = nextr
			self.rotateanimstate = dir
			return
		else
			local tpos = dropair.calcchildposition(self.nextx, self.nexty, (nextr + 180) % 360)

			if field:get(tpos.x, tpos.y) == "no" then
				self.nextx = tpos.x
				self.nexty = tpos.y
				self.nextr = nextr
				self.rotateanimstate = dir

				local tmp = (nextr / 90) % 4
				if tmp == 1 then
					self.moveanimstate = "left"
				elseif tmp == 2 then
					self.moveanimstate = "up"
				elseif tmp == 3 then
					self.moveanimstate = "right"
				end
				return
			else

			end
		end
	end

	for _, v in ipairs(checks) do
		if v == "right" and checkcontrols("rotateright") then
			local nextr = (math.floor(self.r / 90) + 1) * 90
			rotatecommon("right", nextr)

		elseif v == "left" and checkcontrols("rotateleft") then
			local nextr = math.floor((self.r - 1) / 90) * 90
			rotatecommon("left", nextr)
		end
	end
end

function dropair:update(dt)
	self.falltimer = self.falltimer + dt
	if self.falltimer > self.falltime and self.moveanimstate == "idle" then
		self.falltimer = 0
		self:movedown()
		return
	end

	if self.rotateanimstate == "idle" then
		if self.r > 360 then
			self.r = self.r - 360
		elseif self.r < 0 then
			self.r = self.r + 360
		end

		if self.nextr > 360 then
			self.nextr = self.nextr - 360
		elseif self.nextr < 0 then
			self.nextr = self.nextr + 360
		end
	end

	if self.rotateanimstate == "right" then
		self.r = self.r + self.rotatespeed * dt
		if self.r >= self.nextr then
			self.r = self.nextr
			self.rotateanimstate = "idle"
			return
		end
	elseif self.rotateanimstate == "left" then
		self.r = self.r - self.rotatespeed * dt
		if self.r <= self.nextr then
			self.r = self.nextr
			self.rotateanimstate = "idle"
			return
		end
	end

	if self.moveanimstate == "up" then
		self.y = self.y + self.movespeed * dt
		if self.y >= self.nexty then
			self.y = self.nexty
			self.moveanimstate = "idle"
			return
		end
	elseif self.moveanimstate == "down" then
		self.y = self.y - self.movespeed * dt
		if self.y <= self.nexty then
			self.y = self.nexty
			self.moveanimstate = "idle"
			return
		end
	elseif self.moveanimstate == "left" then
		self.x = self.x - self.movespeed * dt
		if self.x <= self.nextx then
			self.x = self.nextx
			self.moveanimstate = "idle"
			return
		end
	elseif self.moveanimstate == "right" then
		self.x = self.x + self.movespeed * dt
		if self.x >= self.nextx then
			self.x = self.nextx
			self.moveanimstate = "idle"
			return
		end
	end

	if self.moveanimstate == "idle" then
		self:rotate()
		self:move()
	end
end

function dropair:getpositions()
	return {
		{ x = self.x, y = self.y },
		dropair.calcchildposition(self.x, self.y, self.r),
	}
end

function dropair:draw()
	for i, p in ipairs(self:getpositions()) do
		local x = util.round((p.x - 1) * 10 + self.player.fieldoffsetx)
		local y = util.round((12 - p.y) * 10 + self.player.fieldoffsety)

		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.draw(images["drop"][self.colors[i]], x * scale, y * scale, 0, scale, scale)
	end
end
