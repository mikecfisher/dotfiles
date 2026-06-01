import * as os from "node:os";
import * as path from "node:path";
import {
	CustomEditor,
	type ExtensionAPI,
	type ExtensionContext,
	type KeybindingsManager,
} from "@earendil-works/pi-coding-agent";
import type { EditorTheme, TUI } from "@earendil-works/pi-tui";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

const ELLIPSIS = "…";
const BORDER = "─";
const LEFT_CORNER = "╭";
const RIGHT_CORNER = "╮";
const LEFT_PROMPT_GAP = " ";

function shortenHome(p: string | undefined): string {
	if (!p) return "~";
	const home = os.homedir();
	return p === home ? "~" : p.startsWith(home + path.sep) ? `~${p.slice(home.length)}` : p;
}

function compactPath(p: string, maxWidth: number): string {
	if (visibleWidth(p) <= maxWidth) return p;
	if (maxWidth <= 1) return ELLIPSIS.slice(0, maxWidth);

	const parts = p.split(path.sep).filter(Boolean);
	const isHome = p.startsWith("~");
	const prefix = isHome ? "~" : p.startsWith(path.sep) ? path.sep : "";
	const tail = parts.slice(-2).join(path.sep);
	const joiner = prefix && prefix !== path.sep && tail ? path.sep : "";
	const candidate = `${prefix}${joiner}${ELLIPSIS}${path.sep}${tail}`;
	return truncateToWidth(candidate, maxWidth);
}

function fmtCount(n: number | null | undefined): string {
	if (n == null || !Number.isFinite(n)) return "?";
	if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(n >= 10_000_000 ? 0 : 1)}m`;
	if (n >= 1_000) return `${(n / 1_000).toFixed(n >= 100_000 ? 0 : 1)}k`;
	return String(Math.round(n));
}

function fmtPercent(p: number | null | undefined): string {
	if (p == null || !Number.isFinite(p)) return "?";
	return `${p.toFixed(p < 10 ? 1 : 0)}%`;
}

function displayModel(model: ExtensionContext["model"]): string {
	if (!model) return "no model";
	return model.name || model.id || "model";
}

function sessionLabel(pi: ExtensionAPI, ctx: ExtensionContext): string {
	const name = pi.getSessionName() || ctx.sessionManager.getSessionName?.();
	if (name) return String(name);

	const header = ctx.sessionManager.getHeader();
	if (header?.id) return String(header.id).slice(0, 8);

	const id = ctx.sessionManager.getSessionId();
	return id ? String(id).slice(0, 8) : "session";
}

function formatStatus(pi: ExtensionAPI, ctx: ExtensionContext, branch: string | null | undefined, width: number): string {
	const rawCwd = shortenHome(ctx.cwd || ctx.sessionManager.getCwd());
	const cwdBudget = Math.max(10, Math.min(34, Math.floor(width * 0.25)));
	const cwd = compactPath(rawCwd, cwdBudget);
	const session = sessionLabel(pi, ctx);
	const sessionPart = branch ? `${session} (${branch})` : session;
	const reasoning = pi.getThinkingLevel();
	const usage = ctx.getContextUsage();
	const contextWindow = usage?.contextWindow ?? ctx.model?.contextWindow;
	const contextPart = `${fmtPercent(usage?.percent)}/${fmtCount(contextWindow)}`;
	const theme = ctx.ui.theme;
	const sep = theme.fg("muted", " › ");

	const icon = (color: Parameters<typeof theme.fg>[0], glyph: string): string => theme.fg(color, theme.bold(glyph));

	return [
		icon("warning", "π"),
		theme.fg("mdCode", cwd),
		`${icon("mdLink", "⎇")} ${theme.fg("mdLink", sessionPart)}`,
		`${icon("customMessageLabel", "⚙")} ${theme.fg("customMessageLabel", `${displayModel(ctx.model)} · ${reasoning}`)}`,
		`${icon("dim", "⛶")} ${theme.fg("dim", `${contextPart} `)}${icon("warning", "✨")}`,
	].join(sep);
}

function fitTopBorder(status: string, width: number, borderColor: (text: string) => string): string {
	if (width <= 0) return "";
	if (width === 1) return borderColor(BORDER);
	if (width === 2) return borderColor(`${LEFT_CORNER}${RIGHT_CORNER}`);

	let label = `${LEFT_PROMPT_GAP}${status} `;
	const maxLabelWidth = Math.max(0, width - 4);
	if (visibleWidth(label) > maxLabelWidth) {
		label = truncateToWidth(label, maxLabelWidth, ELLIPSIS);
	}

	const used = visibleWidth(label) + 2;
	const fill = Math.max(0, width - used);
	return borderColor(LEFT_CORNER) + label + borderColor(BORDER.repeat(fill) + RIGHT_CORNER);
}

function fitEditorContentLine(
	content: string,
	width: number,
	borderColor: (text: string) => string,
	isLast: boolean,
): string {
	if (width <= 0) return "";
	if (width === 1) return borderColor(isLast ? "╰" : "│");
	if (width === 2) return borderColor(isLast ? "╰╯" : "││");

	const left = borderColor(isLast ? "╰  " : "│  ");
	const right = borderColor(isLast ? "  ╯" : "  │");
	const innerWidth = Math.max(0, width - 6);
	const trimmedContent = content.replace(/[ \t]+$/, "");
	const fittedContent = truncateToWidth(trimmedContent, innerWidth, "");
	const gap = Math.max(0, innerWidth - visibleWidth(fittedContent));
	return left + fittedContent + " ".repeat(gap) + right;
}

export default function (pi: ExtensionAPI) {
	let branch: string | null | undefined;
	let activeTui: TUI | undefined;

	const rerender = () => activeTui?.requestRender();

	pi.on("session_start", (_event, ctx) => {
		if (!ctx.hasUI) return;

		// The visual target has the status prompt integrated into the editor border,
		// so remove the separate footer row entirely.
		ctx.ui.setFooter((_tui, _theme, footerData) => {
			branch = footerData.getGitBranch();
			const unsubscribe = footerData.onBranchChange(() => {
				branch = footerData.getGitBranch();
				rerender();
			});
			return {
				dispose: unsubscribe,
				invalidate() {},
				render(): string[] {
					return [];
				},
			};
		});

		class RichPromptEditor extends CustomEditor {
			constructor(tui: TUI, theme: EditorTheme, keybindings: KeybindingsManager) {
				super(tui, theme, keybindings, { paddingX: 0 });
				activeTui = tui;
			}

			render(width: number): string[] {
				const lines = super.render(width);
				if (lines.length === 0) return lines;

				const borderColor = (text: string) => this.borderColor(text);
				lines[0] = fitTopBorder(formatStatus(pi, ctx, branch, width), width, borderColor);

				// Match the target prompt shape: status is cut into the top border,
				// user input sits below it, with only short lower corner ticks instead
				// of a full bottom border line.
				if (lines.length > 1) {
					lines.pop();
					for (let i = 1; i < lines.length; i++) {
						lines[i] = fitEditorContentLine(lines[i] ?? "", width, borderColor, i === lines.length - 1);
					}
				}
				return lines;
			}
		}

		ctx.ui.setEditorComponent((tui, theme, keybindings) => new RichPromptEditor(tui, theme, keybindings));
	});

	pi.on("model_select", rerender);
	pi.on("thinking_level_select", rerender);
	pi.on("agent_end", rerender);
	pi.on("session_shutdown", () => {
		activeTui = undefined;
		branch = undefined;
	});
}
