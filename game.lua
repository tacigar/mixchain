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

function game:load(params)
	gamestate = "game"

	self.effects = {}
	self.player = player{
		fieldoffsetx = 33,
		fieldoffsety = 5,
		nextdropairsoffsetx = 107,
		nextdropairsoffsety = 19,
	}
end

function game:addeffect(e)
	table.insert(self.effects, e)
end

function game:update(dt)
	for i = #self.effects, 1, -1 do
		if self.effects[i].isstopped then
			table.remove(self.effects, i)
		end
	end

	for _, e in ipairs(self.effects) do
		e:update(dt)
	end

	self.player:update(dt)
end

function game:draw()
	self.player:draw()

	for _, e in ipairs(self.effects) do
		e:draw()
	end
end

function game:keypressed(key)

end
