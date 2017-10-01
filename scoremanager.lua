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

scoremanager = {}
scoremanager.__index = scoremanager

setmetatable(scoremanager, {
	__call = function()
		local self = setmetatable({}, scoremanager)
		self:reset()
		return self
	end,
})

function scoremanager:reset()
	self.value = 0
	self.chaincounter = 0
end

scoremanager.chainbonus = {
	[1]  =   0,
	[2]  =   8,
	[3]  =  16,
	[4]  =  32,
	[5]  =  64,
	[6]  =  96,
	[7]  = 128,
	[8]  = 160,
	[9]  = 192,
	[10] = 224,
	[11] = 256,
	[12] = 288,
	[13] = 320,
	[14] = 352,
	[15] = 384,
	[16] = 416,
	[17] = 448,
	[18] = 480,
	[19] = 512,
}

scoremanager.linkbonus = {
	[4]  = 0,
	[5]  = 2,
	[6]  = 3,
	[7]  = 4,
	[8]  = 5,
	[9]  = 6,
	[10] = 7,
}

scoremanager.colorbonus = {
	[1] =  0,
	[2] =  3,
	[3] =  6,
	[4] = 12,
	[5] = 24,
}

function scoremanager:chain(numdrops, linknums, numcolors)
	self.chaincounter = self.chaincounter + 1
	local chainbonus = scoremanager.chainbonus[self.chaincounter]
	local linkbonus = 0
	for _, v in ipairs(linknums) do
		if v > 10 then
			linkbonus = linkbonus + 10
		else
			linkbonus = linkbonus + scoremanager.linkbonus[v]
		end
	end
	local colorbonus = scoremanager.colorbonus[numcolors]

	local totalbonus = chainbonus + linkbonus + colorbonus
	if totalbonus == 0 then
		totalbonus = 1
	end

	self.value = self.value + (numdrops * totalbonus) * 10
end
