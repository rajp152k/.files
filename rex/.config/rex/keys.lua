-- Preserve the tmux prefix. Press it twice to pass Ctrl-Space to the terminal.
local prefix = "ctrl+space>"
local function bind(key, action, args)
  rex.bind(prefix .. key, action, args)
end

bind("ctrl+space", "pane.send_key", { key = "ctrl+space" })

local directions = { h = "left", j = "down", k = "up", l = "right" }
for key, direction in pairs(directions) do
  bind(key, "pane.focus", { direction = direction })
  bind("ctrl+" .. key, "pane.focus", { direction = direction })
  bind("shift+" .. key, "pane.resize", { direction = direction, amount = 5 })
end

-- Write shifted symbols as their unshifted key plus Shift.
bind("shift+\\", "pane.split", { direction = "right" }) -- |
bind("-", "pane.split", { direction = "down" })
bind("shift+5", "pane.split", { direction = "right" }) -- %
bind("shift+'", "pane.split", { direction = "down" }) -- "
bind("z", "pane.zoom")
bind("=", "pane.balance")
bind("f", "pane.float")
bind("x", "pane.close")

bind("c", "client.tab.new")
bind("n", "client.tab.next")
bind("p", "client.tab.previous")
bind(",", "client.tab.rename")
bind("shift+,", "client.tab.move.backward") -- <
bind("shift+.", "client.tab.move.forward") -- >
for index = 1, 9 do
  bind(tostring(index), "client.tab.goto", { index = index })
end
bind("s", "session.switch")
bind("shift+;", "client.palette.toggle") -- :
bind("r", "client.config.reload")

-- Reusable, 80% floating terminals. Quit the program to close its terminal.
bind("i", "btop")
bind("shift+w", "journal")
bind("shift+s", "scratch")
bind("enter", "hud")

-- A held resize key repeats without pressing the prefix for every step.
rex.mode("resize", { exclusive = true })
bind("shift+r", "client.mode.enter", { name = "resize" })
for key, direction in pairs(directions) do
  rex.bind("resize/" .. key, "pane.resize", { direction = direction, amount = 5 })
  rex.bind("resize/shift+" .. key, "pane.resize", { direction = direction, amount = 15 })
end
rex.bind("resize/=", "pane.balance")
rex.bind("resize/enter", "client.mode.exit")
-- Escape also leaves the mode.
