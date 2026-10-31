local M = {}
local cache

-- Compute once per edit, rather than scanning preceding lines in each foldexpr.
function M.levels(lines, tabstop)
  local levels, items = {}, {}
  local heading, fence = 0, nil
  for lnum, line in ipairs(lines) do
    local whitespace = line:match '^%s*'
    local indent = 0
    for char in whitespace:gmatch '.' do
      indent = char == '\t' and (indent + tabstop - indent % tabstop) or (indent + 1)
    end
    local text = line:sub(#whitespace + 1)
    if fence then
      levels[lnum] = fence.level
      local closing = text:match '^(`+)%s*$' or text:match '^(~+)%s*$'
      if closing and closing:sub(1, 1) == fence.char and #closing >= fence.length then fence = nil end
    else
      local hashes = line:match '^ ? ? ?(#+)%s+' or line:match '^ ? ? ?(#+)%s*$'
      local bullet = text:match '^[-+*]%s+' or text:match '^%d+[.)]%s+'
      local thematic = text:match '^%*[%s%*]*$' or text:match '^%-[%s%-]*$' or text:match '^_[%s_]*$'
      thematic = thematic and #thematic:gsub('%s', '') >= 3
      if hashes and #hashes <= 6 then
        heading, items = #hashes, {}
        levels[lnum] = '>' .. heading
      else
        if text ~= '' then
          while #items > 0 and indent <= items[#items] do table.remove(items) end
        end
        if bullet and not thematic then
          items[#items + 1] = indent
          levels[lnum] = '>' .. (heading + #items)
        else
          levels[lnum] = heading + #items
        end
        local opening, info = text:match '^(```+)(.*)$'
        if not opening then opening, info = text:match '^(~~~+)(.*)$' end
        if opening and not (opening:sub(1, 1) == '`' and info:find('`', 1, true)) then
          local level = heading + #items + 1
          fence = { char = opening:sub(1, 1), length = #opening, level = level }
          levels[lnum] = '>' .. level
        end
      end
    end
  end
  return levels
end

function M.foldexpr(lnum)
  local buf = vim.api.nvim_get_current_buf()
  local tick, tabstop = vim.api.nvim_buf_get_changedtick(buf), vim.bo[buf].tabstop
  local entry = cache
  if not entry or entry.buf ~= buf or entry.tick ~= tick or entry.tabstop ~= tabstop then
    entry = { buf = buf, tick = tick, tabstop = tabstop, levels = M.levels(vim.api.nvim_buf_get_lines(buf, 0, -1, false), tabstop) }
    cache = entry
  end
  return entry.levels[lnum] or 0
end

return M
