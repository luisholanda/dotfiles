local vapi = vim.api
local M = {}

-- Command ':Bclose' executes ':bd' to delete buffer in current window.
-- The window will show the alternate buffer (Ctrl-^) if it exists,
-- or the previous buffer (:bp), or a blank buffer if no previous.
-- Command ':Bclose!' is the same, but executes ':bd!' (discard changes).
-- An optional argument can specify which buffer to close (name or number).
function M.close_buffer(bang, buffer)
  local btarget
  local curr = vapi.nvim_get_current_buf()

  if #buffer == 0 then
    btarget = curr
  elseif not string.match(buffer, "^%d+$") then
    btarget = vapi.nvim_buf_get_number(tonumber(buffer))
  else
    btarget = vapi.nvim_buf_get_number(buffer)
  end

  if btarget < 0 then
    vapi.nvim_err_writeln("No match buffer for "..buffer)
    return
  end

  if #bang == 0 and vapi.nvim_buf_get_option(btarget, "modified") then
    vapi.nvim_err_writeln("No write since last change for buffer "..btarget.." (use :Bclose!)")
    return
  end

  for _, w in ipairs(vapi.nvim_list_wins()) do
    vapi.nvim_command(tostring(vapi.nvim_win_get_number(w)).."wincmd w")

    local bprev = vim.fn.bufnr("#")
    if bprev > 0 and vim.fn.buflisted(bprev) and bprev ~= btarget then
      vapi.nvim_command[[buffer #]]
    else
      vapi.nvim_command[[bprevious]]
    end

    if btarget == vapi.nvim_get_current_buf() then
      local bjump = -1
      -- Number of listed buffers which are not the target to be delted.
      local blisted = {}
      for b = 1,vim.fn.bufnr("$") do
        if b ~= btarget and vapi.fn.buflisted(b) then
          table.insert(blisted, b)
        end
      end

      -- Listed, not target, and not displayed.
      for b = 1,#blisted do
        if vapi.fn.bufwinnr(b) < 0 then
          bjump = b
          break
        end
      end

      if bjump < 0 and #blisted > 0 then
        bjump = blisted[0]
      end

      if bjump > 0 then
        vapi.nvim_command("buffer "..bjump)
      else
        vapi.nvim_command("enew"..bang)
      end
    end
  end
end

return M
