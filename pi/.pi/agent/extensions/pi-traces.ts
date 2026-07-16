import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import {
	DEFAULT_MAX_BYTES,
	DEFAULT_MAX_LINES,
	formatSize,
	truncateHead,
} from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

const TRACE_URL = /https?:\/\/(?:www\.)?traces\.com\/[^\s<>"')\]]+/gi;
const TRACE_ID =
	/\b[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\b/i;

function traceId(reference: string): string {
	const decoded = decodeURIComponent(reference);
	const uuid = decoded.match(TRACE_ID)?.[0];
	if (uuid) return uuid;

	try {
		const url = new URL(reference);
		for (const key of ["traceId", "trace_id", "id"]) {
			const value = url.searchParams.get(key);
			if (value) return value;
		}
		const segments = url.pathname.split("/").filter(Boolean);
		if (segments.length) return segments.at(-1)!;
	} catch {
		// A bare trace ID is also accepted.
	}

	const bare = reference.trim();
	if (/^[A-Za-z0-9_-]+$/.test(bare)) return bare;
	throw new Error(`Could not extract a trace ID from: ${reference}`);
}

export default function piTraces(pi: ExtensionAPI) {
	pi.registerTool({
		name: "traces_show",
		label: "Traces",
		description: `Load a particular agent trace through the traces CLI. Accepts a traces.com link or bare trace ID. Returns user and agent messages by default, bounded to 60 events and truncated to ${DEFAULT_MAX_LINES} lines or ${formatSize(DEFAULT_MAX_BYTES)}.`,
		promptSnippet:
			"Load a traces.com trace link or trace ID using the traces CLI",
		promptGuidelines: [
			"Use traces_show whenever the user pastes a traces.com link or explicitly asks you to inspect, open, read, or look at a particular trace. Do not use fetch_content or web tools for trace links.",
		],
		parameters: Type.Object({
			reference: Type.String({
				description: "A traces.com URL or bare trace ID",
			}),
			includeTools: Type.Optional(
				Type.Boolean({
					description:
						"Include tool calls/results when implementation evidence is needed",
				}),
			),
		}),
		async execute(_toolCallId, params, signal) {
			const id = traceId(params.reference);
			const eventTypes = params.includeTools
				? "user_message,agent_text,tool_call,tool_result"
				: "user_message,agent_text";
			const result = await pi.exec(
				"traces",
				[
					"show",
					id,
					"--remote",
					"--markdown",
					"--event-type",
					eventTypes,
					"--offset",
					"1",
					"--limit",
					"60",
					"--max-event-chars",
					"6000",
				],
				{ signal, timeout: 30_000 },
			);

			if (result.code !== 0) {
				throw new Error(
					result.stderr.trim() ||
						result.stdout.trim() ||
						`traces show failed (${result.code})`,
				);
			}

			const truncation = truncateHead(result.stdout, {
				maxLines: DEFAULT_MAX_LINES,
				maxBytes: DEFAULT_MAX_BYTES,
			});
			let text = truncation.content;
			if (truncation.truncated) {
				text += `\n\n[Trace output truncated: showing ${truncation.outputLines}/${truncation.totalLines} lines (${formatSize(truncation.outputBytes)}/${formatSize(truncation.totalBytes)}). Call traces_show again with the relevant trace and use focused CLI searches via bash if more detail is needed.]`;
			}

			return {
				content: [{ type: "text", text }],
				details: {
					traceId: id,
					reference: params.reference,
					eventTypes,
					truncated: truncation.truncated,
				},
			};
		},
	});

	pi.on("input", (event) => {
		if (event.source === "extension") return { action: "continue" };
		const links = event.text.match(TRACE_URL);
		if (!links?.length) return { action: "continue" };

		return {
			action: "transform",
			text: `${event.text}\n\n[pi-traces: Inspect ${links.join(", ")} with traces_show before answering.]`,
		};
	});
}
