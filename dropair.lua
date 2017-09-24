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

local function childposition(x, y, r)
	return { x = x + math.sin(math.rad(r)), y = y + math.cos(math.rad(r)) }
end

setmetatable(dropair, {
	__call = function(_, x, y, colors)
		local self = setmetatable({}, dropair)

		self.x = x
		self.y = y
		self.r = 0
		self.nextx = self.x
		self.nexty = self.y
		self.nextr = 0
		self.movespeed = 20
		self.rotatespeed = 600
		self.colors = colors
		self.moveanimationstate = "idle"
		self.rotateanimationstate = "idle"
		self.moveanimationtimer = 0
		self.rotateanimationtimer = 0
		self.falltimer = 0

		return self
	end,
})

function dropair:movesenabled()
	return self.moveanimationstate == "idle"
end

function dropair:rotatesenabled(dir)
	if dir == nil then
		return self.rotateanimationstate == "idle" and self.moveanimationstate == "idle"
	end
	return self.rotateanimationstate ~= dir and self.moveanimationstate == "idle"
end

function dropair:movedown()
	local field = game.objects["field"]

	local tmpr
	if self.rotateanimationstate ~= "idle" then
		tmpr = self.nextr
	else
		tmpr = self.r
	end

	local poss = { { x = self.x, y = self.y - 1 }, childposition(self.x, self.y - 1, tmpr) }
	local enabled = true
	for _, pos in ipairs(poss) do
		if field:get(pos.x, pos.y) ~= "no" then
			enabled = false
			break
		end
	end

	if enabled then
		sounds["se"][2]:play()
		self.moveanimationstate = "down"
		self.nextx = self.x
		self.nexty = self.y - 1
	else
		game:changegamestate("fix")
	end
end

function dropair:move(dt)
	local checkorder = util.shuffle{ "right", "left", "down" }
	local field = game.objects["field"]

	for _, dir in ipairs(checkorder) do
		if dir == "right" and checkcontrols("moveright") or dir == "left" and checkcontrols("moveleft") then
			local diffx = (dir == "right") and 1 or -1

			local tmpr
			if self.rotateanimationstate ~= "idle" then
				tmpr = self.nextr
			else
				tmpr = self.r
			end

			local poss = { { x = self.x + diffx, y = self.y }, childposition(self.x + diffx, self.y, self.nextr) }
			local enabled = true
			for _, pos in ipairs(poss) do
				if field:get(pos.x, pos.y) ~= "no" then
					enabled = false
					break
				end
			end

			if enabled then
				sounds["se"][2]:play()
				self.moveanimationstate = dir
				self.nextx = self.x + diffx
				self.nexty = self.y
			end

		elseif dir == "down" and checkcontrols("movedown") then
			self:movedown()
		end
	end
end

function dropair:getpositions()
	return { { x = self.x, y = self.y }, childposition(self.x, self.y, self.r) }
end

function dropair:rotate(dt)
	local angleref = { 0, 90, 180, 270, 360 }
	local checkorder = util.shuffle{ "right", "left" }
	local field = game.objects["field"]

	local function rotatecommon(rdir, nextr)
		local cpos = childposition(self.x, self.y, nextr)
		sounds["se"][3]:play()
		if field:get(cpos.x, cpos.y) == "no" then
			self.nextr = nextr
			self.rotateanimationstate = rdir
			return
		else
			local tpos = childposition(self.x, self.y, (nextr + 180) % 360)

			if field:get(tpos.x, tpos.y) == "no" then
				self.nextx = tpos.x
				self.nexty = tpos.y
				self.nextr = nextr
				self.rotateanimationstate = rdir

				if nextr == 90 then
					self.moveanimationstate = "left"
				elseif nextr == 180 then
					self.moveanimationstate = "up"
				elseif nextr == 270 then
					self.moveanimationstate = "right"
				end
				return
			else
				self.rotateanimationstate = "upsidedown"

				if nextr == 180 then
					self.nextr = 0
				elseif nextr == 0 or nextr == 360 then
					self.nextr = 180
				end
				return
			end
		end

	end

	for _, dir in ipairs(checkorder) do
		if dir == "right" and checkcontrols("rotateright") and self:rotatesenabled("right") then
			if self.r > 270 then
				self.r = self.r - 360
			end
			for i = 1, 4 do
				if self.r >= angleref[i] and self.r <= angleref[i + 1] then
					local nextr = angleref[i + 1]
					rotatecommon("right", nextr)
				end
			end
			break

		elseif dir == "left" and checkcontrols("rotateleft") and self:rotatesenabled("left") then
			if self.r < 90 then
				self.r = self.r + 360
			end
			for i = 1, 4 do
				if self.r > angleref[i] and self.r <= angleref[i + 1] then
					local nextr = angleref[i]
					rotatecommon("left", nextr)
				end
			end
			break
		end
	end
end

function dropair:leavemove()
	self.moveanimationstate = "idle"
end

function dropair:leaverotate()
	self.rotateanimationstate = "idle"
end

function dropair:update(dt)
	self.falltimer = self.falltimer + dt
	if self.falltimer > falltimeinterval and self:movesenabled() then
		self.falltimer = 0
		self:movedown()
	end


	if self.moveanimationstate == "right" then
		if self.x >= self.nextx then
			self.x = self.nextx
			self:leavemove()
		else
			self.x = self.x + self.movespeed * dt
		end
	elseif self.moveanimationstate == "left" then
		if self.x <= self.nextx then
			self.x = self.nextx
			self:leavemove()
		else
			self.x = self.x - self.movespeed * dt
		end
	elseif self.moveanimationstate == "down" then
		if self.y <= self.nexty then
			self.y = self.nexty
			self:leavemove()
		else
			self.y = self.y - self.movespeed * dt
		end
	elseif self.moveanimationstate == "up" then
		if self.y >= self.nexty then
			self.y = self.nexty
			self:leavemove()
		else
			self.y = self.y + self.movespeed * dt
		end
	end

	if self.rotateanimationstate == "right" then
		if self.r >= self.nextr then
			self.r = self.nextr
			self:leaverotate()
		else
			self.r = self.r + self.rotatespeed * dt
		end
	elseif self.rotateanimationstate == "left" then
		if self.r <= self.nextr then
			self.r = self.nextr
			self:leaverotate()
		else
			self.r = self.r - self.rotatespeed * dt
		end
	elseif self.rotateanimationstate == "upsidedown" then

	end

	if self:rotatesenabled() then
		self:rotate(dt)
	end
	if self:movesenabled() then
		self:move(dt)
	end
end

function dropair:draw()
	for i, pos in ipairs(self:getpositions()) do
		local x, y = transformcoordinate(pos.x, pos.y)
		drawdrop(x, y, self.colors[i])
		--love.graphics.circle("fill", (pos.x - 1) * 50 + 75, (12 - pos.y) * 50 + 75, 25)
	end
end
