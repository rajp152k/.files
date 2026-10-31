-- Run only in a disposable session. See ../README.md for the cleanup command.
local function checked(value, err)
  if err ~= nil then error(err, 0) end
  return assert(value)
end

local function find_block(view, id)
  for _, window in ipairs(view.windows or {}) do
    for _, layer in ipairs(window.layers or {}) do
      for _, block in ipairs(layer.blocks or {}) do
        if block.block_id == id then return window, layer, block end
      end
    end
  end
end

local function await(check, message)
  for attempt = 1, 40 do
    if check() then return end
    rex.sleep(0.25)
  end
  error(message, 0)
end

local function await_process(id, name)
  await(function()
    local process = checked(rex.call("block.method", {
      session_id = rex.session_id, block_id = id, method = "process",
    }))
    assert(not process.last_exit, name .. " exited before the check")
    return process.foreground and process.foreground.name == name
  end, name .. " did not start")
end

local hud = checked(rex.invoke("hud", {}))
assert(hud.block_id and not hud.reused, "first HUD call must create a block")
local window, layer, block = find_block(checked(rex.session.view{}), hud.block_id)
assert(block.label == "tool-hud", "HUD label must survive layout construction")
assert(layer.kind == "floating", "HUD must be a floating layer")
assert(layer.bounds[1] == 0.1 and layer.bounds[3] == 0.8, "HUD must use the popup bounds")

local again = checked(rex.invoke("hud", {}))
assert(again.reused and again.block_id == hud.block_id, "HUD must reuse its running block")

local monitor = checked(rex.invoke("btop", {}))
assert(monitor.block_id and not monitor.reused, "btop must create a block")
await_process(monitor.block_id, "btop")
local editor = checked(rex.invoke("dev_layout", { cwd = assert(os.getenv("HOME")) }))
assert(#editor.block_ids == 2, "dev layout must create editor and shell")
local editor_window, editor_layer = find_block(checked(rex.session.view{}), editor.block_ids[1])
assert(editor_window.window_id == editor.window_id and editor_layer.kind == "tiled")
assert(editor_layer.layout.split.direction == "horizontal")
assert(editor_layer.layout.split.ratio == 0.7)
await_process(editor.block_ids[1], "nvim")

-- Reuse must work after changing tabs, not just in the original window.
local after_layout = checked(rex.invoke("hud", {}))
assert(after_layout.reused and after_layout.block_id == hud.block_id)
local final = checked(rex.session.view{})
assert(final.active_window_id == window.window_id, "reused tool must focus its original window")

-- A normal program exit must close its transient overlay.
checked(rex.call("block.method", {
  session_id = rex.session_id, block_id = monitor.block_id,
  method = "write", args = { data = "q" },
}))
await(function()
  return not find_block(checked(rex.session.view{}), monitor.block_id)
end, "btop overlay did not close after quitting")
return { passed = true, checks = "floating HUD, reuse, live btop/nvim, 70/30 layout, cross-tab reuse, close on exit" }
