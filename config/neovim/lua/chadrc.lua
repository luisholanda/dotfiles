---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "ashes",
  hl_override = {
    Comment = { italic = true },
    ["@comment"] = { link = "Comment" },
    ["@puntuation.bracket"] = { link = "@puntuation" },
    ["@puntuation.special"] = { link = "@puntuation" },
    ["@string"] = { link = "String" },
    LspInlayHint = { bg = "NONE" },
  },
  integrations = { "semantic_tokens", "neogit" },
}
M.ui = {
  cmp = {
    style = "atom",
  },
}

return M
