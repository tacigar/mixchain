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
	__call = function(_, player)
		local self = setmetatable({}, field)

		self.player = player

		for i = 1, 13 do
			self[i] = {}
			for j = 1, 6 do
				self[i][j] = "no"
			end
		end

		return self
	end,
})

function field:get(x, y)
	local x = util.round(x)
	local y = util.round(y)

	if x <= 0 or x > 6 or y <= 0 or y > 13 then
		return "wall"
	else
		return self[y][x]
	end
end

function field:set(x, y, c)
	local x = util.round(x)
	local y = util.round(y)

	self[y][x] = c
end

function field:delete()
	local checkedfield = {}
	for i = 1, 13 do
		checkedfield[i] = {}
		for j = 1, 6 do
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

	for i = 1, 13 do
		for j = 1, 6 do
			if self[i][j] ~= "no" and checkedfield[i][j] == 0 then
				local auxfield = {}
				for i = 1, 13 do
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

	return deletes
end

function field:draw()
	for i = 1, 13 do
		for j = 1, 6 do
			if self[i][j] ~= "no" then
				local x = util.round((j - 1) * 10 + self.player.fieldoffsetx)
				local y = util.round((12 - i) * 10 + self.player.fieldoffsety)

				love.graphics.setColor(255, 255, 255, 255)
				love.graphics.draw(images["drop"][self[i][j]], x * scale, y * scale, 0, scale, scale)
			end
		end
	end
end
