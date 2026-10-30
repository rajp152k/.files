local home = assert(os.getenv("HOME"), "HOME is not set")
local terminal = "com.superlogical.terminal.shell"

local function checked(value, err)
  if err ~= nil then error(err, 0) end
  return value
end

-- Reuse a tool's live block in this session, including across tab changes.
-- All placement state comes from the server, so config reloads do not duplicate tools.
local function open_tool(label, options)
  local view = checked(rex.session.view{})
  for _, window in ipairs(view.windows or {}) do
    for _, layer in ipairs(window.layers or {}) do
      for _, block in ipairs(layer.blocks or {}) do
        if block.label == label then
          if layer.kind == "floating" then
            checked(rex.session.raise_layer{ layer_id = layer.layer_id })
          end
          checked(rex.session.focus_block{ block_id = block.block_id })
          return { block_id = block.block_id, window_id = window.window_id, reused = true }
        end
      end
    end
  end

  local result = checked(rex.session.new_layer{
    bounds = { 0.1, 0.1, 0.8, 0.8 },
    focus = true,
    layout = rex.layout.block{ flavor = terminal, label = label, options = options },
  })
  return { block_id = result.block_ids[1], layer_id = result.layer_id, reused = false }
end

local tools = {
  { name = "btop", title = "Open btop", cwd = home, command = { "btop" } },
  { name = "journal", title = "Open Journal", cwd = home .. "/source/jour", command = { "just", "day" } },
  { name = "scratch", title = "Open Scratchpad", cwd = home .. "/source", command = { "nvim", "scratchpad.md" } },
  { name = "hud", title = "Open HUD Shell", cwd = home .. "/source" },
}

for _, tool in ipairs(tools) do
  -- Capture one tool per callback under Lua 5.1.
  local spec = tool
  rex.action{
    name = spec.name,
    title = spec.title,
    category = "Personal",
    run = function(ctx, args)
      return open_tool("tool-" .. spec.name, {
        cwd = spec.cwd,
        command = spec.command,
      })
    end,
  }
end

rex.action{
  name = "dev_layout",
  title = "Open Editor and Shell",
  category = "Personal",
  args = { cwd = "string?" },
  run = function(ctx, args)
    local cwd = args.cwd or (home .. "/source")
    return checked(rex.session.new_window{
      window_label = "dev",
      layout = rex.layout.horizontal(0.7,
        rex.layout.block{
          flavor = terminal,
          label = "editor",
          options = { cwd = cwd, command = { "nvim" } },
        },
        rex.layout.block{
          flavor = terminal,
          label = "shell",
          options = { cwd = cwd },
        }),
    })
  end,
}
