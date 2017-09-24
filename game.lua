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

game = {}

local colorref = { "red", "blue", "green", "purple", "yellow"}

local function makerandomcolorpair()
	return { colorref[math.random(1, 3)], colorref[math.random(1, 3)] }
end

function game:load()
	gamestate = "game"

	self.type = "mixchain"
	self.state = "control"
	self.objects = {}
	self.objects["dropair"] = dropair(3, 13, makerandomcolorpair())
	self.objects["field"] = field()
	self.objects["effects"] = {}
	self.objects["falls"] = {}
	self.objects["deletes"] = {}
	sounds["bgm"][1]:play()
	--self.objects["nexts"] = { makerandomcolorpair(), makerandomcolorpair() }
end

function game:startfalldrops(data)
	for _, d in ipairs(data) do
		d.startx = d.x
		d.starty = d.y
	end
	self.objects["falls"] = data
	self.objects["falls"].numframes = 20
	self.objects["falls"].framecounter = 0
	self.state = "fall"
end

function game:startdelete(deletes)
	sounds["se"][5]:play()
	for _, d in ipairs(deletes) do
		local x, y = transformcoordinate(d.x, d.y)
		d.effect = effect(images["effect"][1], 50, 50, 0.25, x, y, 1, 1)
	end
	self.objects["deletes"] = deletes
	self.objects["deletes"].numframes = 20
	self.objects["deletes"].framecounter = 0
	self.state = "delete"
end

function game:changegamestate(state)
	if state == "fix" then
		self.state = "fix"

		sounds["se"][1]:play()

		local poss = self.objects["dropair"]:getpositions()
		for i, p in ipairs(poss) do
			local j = (i + 2) % 2 + 1
			if self.objects["field"]:get(p.x, p.y - 1) == "no" and (p.x ~= poss[j].x and p.y - 1 ~= poss[j].y) then
				local y = p.y
				while self.objects["field"]:get(p.x, y) == "no" do
					y = y - 1
				end
				self.objects["field"]:set(poss[j].x, poss[j].y, self.objects["dropair"].colors[j])
				self:startfalldrops({{ x = p.x, y = p.y, desty = y + 1, color = self.objects["dropair"].colors[i] }})
				return
			end
		end

		for i, p in ipairs(self.objects["dropair"]:getpositions()) do
			self.objects["field"]:set(p.x, p.y, self.objects["dropair"].colors[i])
		end

		local deletes = self.objects["field"]:delete()

		if #deletes == 0 then
			self:changegamestate("next")
		else
			self:startdelete(deletes)
		end

	elseif state == "next" then
		self.state = "next"

		sounds["se"][4]:play()
		self.objects["dropair"] = dropair(3, 13, makerandomcolorpair())

		self:changegamestate("control")

	elseif state == "control" then
		self.state = "control"
	end
end

function game:update(dt)
	if self.state == "control" then
		self.objects["dropair"]:update(dt)
		self.objects["field"]:update(dt)
		for _, v in ipairs(self.objects["effects"]) do
			v:update(dt)
		end
	elseif self.state == "fix" then
		self.objects["field"]:update(dt)
		for _, v in ipairs(self.objects["effects"]) do
			v:update(dt)
		end
	elseif self.state == "fall" then
		self.objects["field"]:update(dt)

		local falls = self.objects["falls"]
		falls.framecounter = falls.framecounter + 1
		if falls.framecounter > falls.numframes then
			for _, v in ipairs(self.objects["falls"]) do
				self.objects["field"]:set(v.x, v.desty, v.color)
			end

			local deletes = self.objects["field"]:delete()
			if #deletes == 0 then
				self:changegamestate("next")
			else
				self:startdelete(deletes)
			end
			return
		end

		for _, v in ipairs(self.objects["falls"]) do
			v.y = (v.desty - v.starty) / falls.numframes * falls.framecounter + v.starty
		end

	elseif self.state == "delete" then
		self.objects["field"]:update(dt)

		local deletes = self.objects["deletes"]
		deletes.framecounter = deletes.framecounter + 1
		if deletes.framecounter > deletes.numframes then
			local field = self.objects["field"]

			local falls = {}
			for j = 1, field.w do
				local cnt = 0
				for i = 1, field.h do
					local c = field:get(j, i)
					if c == "no" then
						cnt = cnt + 1
					elseif cnt > 0 then
						field:set(j, i, "no")
						table.insert(falls, { x = j, y = i, desty = i - cnt, color = c })
					end
				end
			end

			self:startfalldrops(falls)
			return
		end

		for _, v in ipairs(deletes) do
			v.effect:update(dt)
		end
	end
end

function game:draw()
	if self.state == "control" then
		self.objects["dropair"]:draw()
		self.objects["field"]:draw()
		for _, v in ipairs(self.objects["effects"]) do
			v:draw()
		end
	elseif self.state == "fall" then
		self.objects["field"]:draw()
		for _, v in ipairs(self.objects["falls"]) do
			local x, y = transformcoordinate(v.x, v.y)
			drawdrop(x, y, v.color)
		end
	elseif self.state == "delete" then
		self.objects["field"]:draw()
		for _, v in ipairs(self.objects["deletes"]) do
			v.effect:draw()
		end
	end
end
