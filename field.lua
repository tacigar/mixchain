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

field = {}
field.__index = field

setmetatable(field, {
	__call = function()
		local self = setmetatable({}, field)
		self.w = 6
		self.h = 13

		for i = 1, self.h do
			self[i] = {}
			for j = 1, self.w do
				self[i][j] = "no"
			end
		end

		return self
	end
})

function field:get(x, y)
	x = util.round(x)
	y = util.round(y)
	if x <= 0 or x > self.w or y <= 0 or y > self.h then
		return "wall"
	else
		return self[y][x]
	end
end

function field:set(x, y, color)
	x = util.round(x)
	y = util.round(y)
	self[y][x] = color
end

function field:update(dt)

end

function field:delete()
	local checkedfield = {}
	for i = 1, self.h do
		checkedfield[i] = {}
		for j = 1, self.w do
			checkedfield[i][j] = 0
		end
	end

	local deletes = {}

	local function check(color, x, y, auxfield, poss)
		if self[y] == nil or self[y][x] ~= color or auxfield[y][x] then
			return 0
		end

		auxfield[y][x] = true
		local cnt = 1
		table.insert(poss, { x = x, y = y })

		for _, diff in ipairs{{ x = 1, y = 0 }, { x = -1, y = 0 }, { x = 0, y = 1 }, { x = 0, y = -1 }} do
			local tmpcnt = check(color, x + diff.x, y + diff.y, auxfield, poss)
			cnt = cnt + tmpcnt
		end

		return cnt
	end

	for i = 1, self.h do
		for j = 1, self.w do
			if self[i][j] ~= "no" and checkedfield[i][j] == 0 then
				local auxfield = {}
				for i = 1, self.h do
					auxfield[i] = {}
				end

				local poss = {}
				local cnt = check(self[i][j], j, i, auxfield, poss)

				if cnt >= 4 then
					for _, pos in ipairs(poss) do
						checkedfield[pos.y][pos.x] = 2
						table.insert(deletes, { x = pos.x, y = pos.y, color = self[i][j]})
					end
				elseif cnt >= 1 then
					for _, pos in ipairs(poss) do
						checkedfield[pos.y][pos.x] = 1
					end
				end
			end
		end
	end

	for _, pos in ipairs(deletes) do
		self:set(pos.x, pos.y, "no")
	end

	return deletes
end

function field:draw()
	for i = 1, self.h do
		for j = 1, self.w do
			if self[i][j] ~= "no" and self[i][j] ~= "wall" then
				local x, y = transformcoordinate(j, i)
				drawdrop(x, y, self[i][j])
			end
		end
	end
end
