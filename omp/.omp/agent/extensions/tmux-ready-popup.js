const TMUX_FORMAT = "#S:#I.#W";
const MAX_NOTIFICATION_TEXT_LENGTH = 200;

function sanitizeNotificationText(value) {
	return value
		.replace(/[\x00-\x1f\x7f]/g, " ")
		.replace(/;/g, ",")
		.trim()
		.slice(0, MAX_NOTIFICATION_TEXT_LENGTH);
}

async function showTmuxPopup(pi, pane, message) {
	const result = await pi.exec(
		"tmux",
		[
			"display-popup",
			"-t",
			pane,
			"-E",
			"-w",
			"50",
			"-h",
			"5",
			"-x",
			"R",
			"-y",
			"0",
			"-T",
			"OMP",
			"-e",
			`OMP_TMUX_READY_MESSAGE=${message}`,
			"printf '%s\\n\\nPress any key to dismiss.' \"$OMP_TMUX_READY_MESSAGE\"; old_stty=$(stty -g); trap 'stty \"$old_stty\"' EXIT HUP INT TERM; stty -icanon -echo min 1 time 0; dd bs=1 count=1 >/dev/null 2>&1;",
		],
		{ timeout: 1_000 },
	);
	if (result.code !== 0) throw new Error(result.stderr);
}

async function getTmuxLocation(pi) {
	const pane = process.env.TMUX_PANE;
	if (!pane) return undefined;

	const result = await pi.exec(
		"tmux",
		["display-message", "-p", "-t", pane, TMUX_FORMAT],
		{ timeout: 1_000 },
	);
	if (result.code !== 0) return undefined;

	const location = sanitizeNotificationText(result.stdout);
	return location || undefined;
}

async function sendReadyNotification(pi) {
	const pane = process.env.TMUX_PANE;
	if (!process.env.TMUX || !pane) return false;

	const location = await getTmuxLocation(pi);
	const message = location ? `Ready for input — ${location}` : "Ready for input";
	await showTmuxPopup(pi, pane, sanitizeNotificationText(message));
	return true;
}

export default function (pi) {
	pi.registerCommand("notify-test", {
		description: "Show the OMP tmux ready popup",
		handler: async (_args, ctx) => {
			if (ctx.mode !== "tui") return;

			try {
				if (!(await sendReadyNotification(pi))) {
					ctx.ui.notify("OMP tmux notifications require tmux", "warning");
				}
			} catch {
				ctx.ui.notify("Could not show OMP tmux notification", "error");
			}
		},
	});

	pi.on("agent_end", async (event, ctx) => {
		if (ctx.mode !== "tui" || event.willContinue) return;

		try {
			await sendReadyNotification(pi);
		} catch {
			// A notification must never interrupt a completed agent run.
		}
	});
}
