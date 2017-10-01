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

player = {}
player.__index = player

local colorref = { "red", "blue", "green", "purple", "yellow" }

function player.newcolorpair()
	return {
		colorref[math.random(numcolors)],
		colorref[math.random(numcolors)],
	}
end

setmetatable(player, {
	__call = function(_, params)
		self = setmetatable({}, player)

		self.score = 0
		self.dropair = nil
		self.field = field(self)
		self.nextdropairs = {
			player.newcolorpair(),
			player.newcolorpair(),
		}
		self.tempobjects = nil
		self.fieldoffsetx = params.fieldoffsetx
		self.fieldoffsety = params.fieldoffsety
		self.nextdropairsoffsetx = params.nextdropairsoffsetx
		self.nextdropairsoffsety = params.nextdropairsoffsety
		self.playtime = 0
		self:changegamestate("countdown")

		return self
	end,
})

function player:update(dt)
	if self.state == "control" or self.state == "next" or self.state == "fall" or self.state == "delete" then
		self.playtime = self.playtime + dt
	end

	if self.state == "control" then
		self.dropair:update(dt)

	elseif self.state == "countdown" then
		self.tempobjects.countdowntimer = self.tempobjects.countdowntimer + dt

		if self.tempobjects.countdowntimer > self.tempobjects.countdowntime then
			self.tempobjects = nil
			self:changegamestate("next")
		end

	elseif self.state == "next" then
		self.tempobjects.movediff = self.tempobjects.movediff + self.tempobjects.movespeed * dt

		if self.tempobjects.movediff > 30 then
			self.nextdropairs[1] = self.tempobjects.nextdropairs[2]
			self.nextdropairs[2] = self.tempobjects.nextdropairs[3]
			self.dropair = dropair(3, 13, self.tempobjects.nextdropairs[1], self)
			self.tempobjects = nil
			self:changegamestate("control")
			return
		end

	elseif self.state == "fall" then
		self.tempobjects.falltimer = self.tempobjects.falltimer + dt

		if self.tempobjects.falltimer > self.tempobjects.fallduration then
			for _, v in ipairs(self.tempobjects) do
				self.field:set(v.x, v.y, v.color)
			end

			local deletes = self.field:delete()
			if #deletes == 0 then
				self:changegamestate("next")
			else
				self:changegamestate("delete", deletes)
			end
			return
		else
			for _, v in ipairs(self.tempobjects) do
				local frame = (self.tempobjects.fallduration - self.tempobjects.falltimer) / self.tempobjects.fallduration
				v.y = (v.desty - v.starty) * (1 - frame) + v.starty
			end
		end

	elseif self.state == "delete" then
		self.tempobjects.deletetimer = self.tempobjects.deletetimer + dt
		if self.tempobjects.deletetimer > self.tempobjects.deleteduration then
			local falls = {}

			for _, pos in ipairs(self.tempobjects) do
				self.field:set(pos.x, pos.y, "no")
			end

			for j = 1, 6 do
				local cnt = 0
				for i = 1, 13 do
					local c = self.field:get(j, i)
					if c == "no" then
						cnt = cnt + 1
					elseif cnt > 0 then
						self.field:set(j, i, "no")
						table.insert(falls, { x = j, y = i, desty = i - cnt, color = c })
					end
				end
			end

			self.tempobjects = nil
			if #falls == 0 then
				self:changegamestate("next")
			else
				self:changegamestate("fall", falls)
			end
			return
		end
	end
end

function player:drawnextdropairs()
	local y = self.nextdropairsoffsety * scale
	love.graphics.setColor(255, 255, 255, 255)

	for _, dropair in ipairs(self.nextdropairs) do
		for _, color in ipairs(dropair) do
			y = y + 10 * scale
			love.graphics.draw(images["drop"][color], self.nextdropairsoffsetx * scale, y, 0, scale, scale)
		end
		y = y + 10 * scale
	end
end

function player:draw()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(images["background"]["game"]["backward"], 0, 0, 0, scale, scale)

	if self.state == "control" then
		self.dropair:draw()
		self.field:draw()
		self:drawnextdropairs()

	elseif self.state == "countdown" then
		local n = math.floor(self.tempobjects.countdowntime - self.tempobjects.countdowntimer)
		if n == 0 then
			love.graphics.print("go!", 42 * scale, 50 * scale, 0, 2 * scale, 2 * scale)
		else
			love.graphics.print(tostring(n), 55 * scale, 50 * scale, 0, 2 * scale, 2 * scale)
		end

	elseif self.state == "next" then
		self.field:draw()

		do -- draw next dropairs
			local y = math.floor((self.nextdropairsoffsety - self.tempobjects.movediff)) * scale
			love.graphics.setColor(255, 255, 255, 255)

			for _, dropair in ipairs(self.tempobjects.nextdropairs) do
				for _, color in ipairs(dropair) do
					y = y + 10 * scale
					love.graphics.draw(images["drop"][color], self.nextdropairsoffsetx * scale, y, 0, scale, scale)
				end
				y = y + 10 * scale
			end
		end

	elseif self.state == "delete" then
		self.field:draw()
		self:drawnextdropairs()

	elseif self.state == "fall" then
		self.field:draw()
		self:drawnextdropairs()

		for _, v in ipairs(self.tempobjects) do
			local x = math.floor((v.x - 1) * 10 + self.fieldoffsetx)
			local y = math.floor((12 - v.y) * 10 + self.fieldoffsety)

			love.graphics.setColor(255, 255, 255, 255)
			love.graphics.draw(images["drop"][v.color], x * scale, y * scale, 0, scale, scale)
		end
	end

	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(images["background"]["game"]["forward"], 0, 0, 0, scale, scale)

	if self.state == "control" or self.state == "countdown" or self.state == "next" or self.state == "delete" or self.state == "fall" then
		local time
		if math.floor(self.playtime) > 9999 then
			time = "9999"
		else
			time = tostring(math.floor(self.playtime))
		end

		love.graphics.print(time, (119 - (time:len() - 1) * 8) * scale, 102 * scale, 0, scale, scale)
	end
end

function player:changegamestate(state, ...)
	if state == "next" then
		self.state = "next"
		self.tempobjects = {
			movespeed = 100,
			movediff = 0,
			nextdropairs = {
				self.nextdropairs[1],
				self.nextdropairs[2],
				player.newcolorpair(),
			},
		}
		return

	elseif state == "fall" then
		self.state = "fall"
		local falls = ({...})[1]
		for _, d in ipairs(falls) do
			d.starty = d.y
		end
		self.tempobjects = falls
		self.tempobjects.fallduration = 0.25
		self.tempobjects.falltimer = 0

	elseif state == "delete" then
		self.state = "delete"
		-- Make effects
		local deletes = ({...})[1]
		for _, d in ipairs(deletes) do
			local x = util.round((d.x - 1) * 10 + self.fieldoffsetx)
			local y = util.round((12 - d.y) * 10 + self.fieldoffsety)
			game:addeffect(effect(images["effect"][1], 10, 10, 0.25, x, y))
		end
		self.tempobjects = deletes
		self.tempobjects.deleteduration = 0.5
		self.tempobjects.deletetimer = 0

	elseif state == "control" then
		self.state = "control"

	elseif state == "countdown" then
		self.state = "countdown"
		self.tempobjects = {
			countdowntime = 4,
			countdowntimer = 0,
		}
	end
end
