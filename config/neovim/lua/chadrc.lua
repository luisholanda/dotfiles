-- This file  needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/NvChad/blob/v2.5/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "onedark",
	hl_override = {
		Comment = { italic = true },
		["@comment"] = { italic = true },
	},
}
M.ui = {
	cmp = {
		style = "atom",
	},
}

return M
