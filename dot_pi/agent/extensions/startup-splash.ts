import type { ExtensionAPI, ExtensionContext, Theme } from "@earendil-works/pi-coding-agent";
import { VERSION } from "@earendil-works/pi-coding-agent";
interface Component {
	render(width: number): string[];
	handleInput?(data: string): void;
	invalidate(): void;
	dispose?(): void;
}

function stripAnsi(text: string): string {
	return text.replace(/\x1b\[[0-9;?]*[ -/]*[@-~]/g, "").replace(/\x1b\][^\x07]*(?:\x07|\x1b\\)/g, "");
}

function visibleWidth(text: string): number {
	return Array.from(stripAnsi(text)).length;
}

function truncateToWidth(text: string, width: number): string {
	if (visibleWidth(text) <= width) return text;
	const ansiPattern = /\x1b\[[0-9;?]*[ -/]*[@-~]|\x1b\][^\x07]*(?:\x07|\x1b\\)/g;
	let out = "";
	let used = 0;
	for (let i = 0; i < text.length;) {
		ansiPattern.lastIndex = i;
		const match = ansiPattern.exec(text);
		if (match && match.index === i) {
			out += match[0];
			i += match[0].length;
			continue;
		}
		const char = Array.from(text.slice(i))[0] ?? "";
		if (!char || used + 1 > width) break;
		out += char;
		used += 1;
		i += char.length;
	}
	return out + "\x1b[0m";
}

interface StartupStats {
	contextCount: number;
	extensionCount: number;
	skillCount: number;
	promptCount: number;
	themeCount: number;
	recentSessions: string[];
}

function pad(text: string, width: number): string {
	return text + " ".repeat(Math.max(0, width - visibleWidth(text)));
}

function center(text: string, width: number): string {
	const left = Math.max(0, Math.floor((width - visibleWidth(text)) / 2));
	return " ".repeat(left) + text;
}

function row(theme: Theme, width: number, content = ""): string {
	const inner = Math.max(0, width - 2);
	return theme.fg("borderMuted", "│") + pad(truncateToWidth(content, inner), inner) + theme.fg("borderMuted", "│");
}

function divider(theme: Theme, width: number): string {
	return row(theme, width, theme.fg("borderMuted", "─".repeat(Math.max(0, width - 2))));
}

function topBorder(theme: Theme, width: number): string {
	const title = ` ${theme.fg("customMessageLabel", "pi agent")} `;
	const left = "╭" + "─".repeat(4);
	const right = "─".repeat(Math.max(0, width - visibleWidth(left) - visibleWidth(title) - 1)) + "╮";
	return theme.fg("borderMuted", left) + title + theme.fg("borderMuted", right);
}

function bottomBorder(theme: Theme, width: number, labelText: string): string {
	const label = ` ${labelText} `;
	const labelWidth = visibleWidth(label);
	const available = Math.max(0, width - labelWidth - 2);
	const leftWidth = Math.floor(available / 2);
	const rightWidth = available - leftWidth;
	return theme.fg("borderMuted", "╰" + "─".repeat(leftWidth)) + theme.fg("dim", label) + theme.fg("borderMuted", "─".repeat(rightWidth) + "╯");
}

function piLogo(theme: Theme): string[] {
	const pink = (s: string) => theme.fg("customMessageLabel", s);
	const mauve = (s: string) => theme.fg("mdHeading", s);
	const blue = (s: string) => theme.fg("mdLink", s);
	const teal = (s: string) => theme.fg("mdCode", s);
	const leg = "██████";
	const gap = " ".repeat(9);
	const indent = "   ";
	const crossbar = pink("██████") + mauve("██████") + blue("██████") + teal("██████");
	return [
		crossbar,
		indent + mauve(leg) + gap + blue(leg),
		indent + mauve(leg) + gap + blue(leg),
		indent + mauve(leg) + gap + blue(leg),
		indent + mauve(leg) + gap + blue(leg),
		indent + mauve(leg) + gap + blue(leg),
	];
}

function formatModel(ctx: ExtensionContext): string {
	const model = ctx.model;
	if (!model) return "no model";
	return model.name || model.id || "model";
}

function getStats(ctx: ExtensionContext): StartupStats {
	const systemPrompt = ctx.getSystemPrompt();
	const contextCount = (systemPrompt.match(/<context-file\b/g) ?? []).length;
	const extensionCount = Math.max(0, ctx.ui.getAllThemes().length ? 0 : 0); // filled below from rough header parsing fallback
	const skills = (systemPrompt.match(/<skill\b/g) ?? []).length;
	const prompts = (systemPrompt.match(/<prompt-template\b/g) ?? []).length;
	const themes = ctx.ui.getAllThemes().length;
	const sessionDir = ctx.sessionManager.getSessionDir();
	const recent = sessionDir ? [sessionDir.split("/").slice(-1)[0] || "current"] : ["current"];

	return {
		contextCount,
		extensionCount,
		skillCount: skills,
		promptCount: prompts,
		themeCount: themes,
		recentSessions: recent,
	};
}

class StartupSplash implements Component {
	private seconds: number | undefined;
	private timer: ReturnType<typeof setInterval> | undefined;

	constructor(
		private theme: Theme,
		private ctx: ExtensionContext,
		private done: () => void,
		private stats: StartupStats,
		private timeoutSeconds?: number,
	) {
		this.seconds = timeoutSeconds;
		if (this.seconds !== undefined) {
			this.timer = setInterval(() => {
				this.seconds = Math.max(0, (this.seconds ?? 0) - 1);
				if (this.seconds <= 0) this.close();
			}, 1000);
		}
	}

	handleInput(): void {
		this.close();
	}

	private close(): void {
		if (this.timer) {
			clearInterval(this.timer);
			this.timer = undefined;
		}
		this.done();
	}

	render(width: number): string[] {
		const w = Math.min(Math.max(90, Math.floor(width * 0.78)), 156);
		const inner = w - 2;
		const leftW = Math.min(46, Math.max(34, Math.floor(inner * 0.34)));
		const rightW = inner - leftW - 3;
		const th = this.theme;
		const lines: string[] = [topBorder(th, w)];
		const logo = piLogo(th);
		const left: string[] = [
			"",
			center(th.fg("text", th.bold("Welcome back!")), leftW),
			"",
			...logo.map((line) => center(line, leftW)),
			"",
			center(th.fg("customMessageLabel", formatModel(this.ctx)), leftW),
			center(th.fg("dim", this.ctx.model?.provider || "openai-codex"), leftW),
			"",
		];
		const right: string[] = [
			th.fg("mdLink", th.bold("Tips")),
			`${th.fg("dim", "/")}  for commands`,
			`${th.fg("dim", "!")}  to run bash`,
			`${th.fg("dim", "Shift+Tab")} cycle thinking`,
			th.fg("borderMuted", "─".repeat(rightW)),
			th.fg("mdLink", th.bold("Loaded")),
			`${th.fg("success", "✓")} ${this.stats.contextCount || 1} context file${(this.stats.contextCount || 1) === 1 ? "" : "s"}`,
			`${th.fg("success", "✓")} ${this.stats.extensionCount || "?"} extensions`,
			`${th.fg("success", "✓")} ${this.stats.skillCount || "?"} skills`,
			th.fg("borderMuted", "─".repeat(rightW)),
			th.fg("mdLink", th.bold("MCP")),
			`${th.fg("success", "●")} ${th.fg("mdCode", "opensrc")} ${th.fg("dim", "1/1 ~1,387")}`,
			`${th.fg("success", "●")} ${th.fg("mdCode", "grep_app")} ${th.fg("dim", "1/1 ~732")}`,
			`${th.fg("success", "●")} ${th.fg("mdCode", "context_7")} ${th.fg("dim", "2/2 ~849")}`,
			th.fg("dim", "4 direct ~2,968 tokens"),
			th.fg("borderMuted", "─".repeat(rightW)),
			th.fg("mdLink", th.bold("Recent sessions")),
			...this.stats.recentSessions.slice(0, 3).map((s) => `${th.fg("dim", "•")} ${th.fg("mdCode", s)}`),
			"",
		];

		const count = Math.max(left.length, right.length);
		for (let i = 0; i < count; i++) {
			const l = pad(left[i] ?? "", leftW);
			const r = pad(right[i] ?? "", rightW);
			lines.push(row(th, w, l + th.fg("borderMuted", " │ ") + r));
		}
		lines.push(bottomBorder(th, w, this.seconds === undefined ? "Press any key to dismiss" : `Press any key to continue (${this.seconds}s)`));
		return lines;
	}

	invalidate(): void {}
	dispose(): void {
		if (this.timer) clearInterval(this.timer);
	}
}

function renderBottomPinnedHeader(width: number, splashLines?: string[]): string[] {
	const terminalRows = process.stdout.rows || 40;
	const reservedPromptRows = 4;
	const availableRows = Math.max(splashLines?.length ?? 0, terminalRows - reservedPromptRows);
	if (!splashLines) {
		return Array.from({ length: availableRows }, () => "");
	}

	const splashWidth = Math.max(...splashLines.map((line) => visibleWidth(line)), 0);
	const leftPad = Math.max(0, Math.floor((width - splashWidth) / 2));
	const centeredSplash = splashLines.map((line) => " ".repeat(leftPad) + line);
	const topPad = Math.max(0, Math.floor((availableRows - centeredSplash.length) / 2));
	const bottomPad = Math.max(0, availableRows - centeredSplash.length - topPad);
	return [
		...Array.from({ length: topPad }, () => ""),
		...centeredSplash,
		...Array.from({ length: bottomPad }, () => ""),
	];
}

function setBottomPinnedBlankHeader(ctx: ExtensionContext): void {
	ctx.ui.setHeader((_tui, _theme) => ({
		render(width: number): string[] {
			return renderBottomPinnedHeader(width);
		},
		invalidate() {},
	}));
}

function showSplashAsHeader(ctx: ExtensionContext, timeoutSeconds?: number): void {
	const stats = getStats(ctx);
	stats.extensionCount = ctx.ui.getAllThemes().length;
	let unsubscribeInput: (() => void) | undefined;

	ctx.ui.setHeader((tui, theme) => {
		let hidden = false;
		const splash = new StartupSplash(theme, ctx, () => {
			hidden = true;
			unsubscribeInput?.();
			unsubscribeInput = undefined;
			tui.requestRender();
		}, stats, timeoutSeconds);
		const tick = setInterval(() => tui.requestRender(), 250);
		unsubscribeInput = ctx.ui.onTerminalInput(() => splash.handleInput());

		return {
			render(width: number): string[] {
				return hidden ? renderBottomPinnedHeader(width) : renderBottomPinnedHeader(width, splash.render(width));
			},
			invalidate() {},
			dispose() {
				clearInterval(tick);
				unsubscribeInput?.();
				splash.dispose();
			},
		};
	});
}

export default function (pi: ExtensionAPI) {
	pi.registerCommand("splash", {
		description: "Show the startup splash until dismissed",
		handler: async (_args, ctx) => {
			if (!ctx.hasUI) return;
			showSplashAsHeader(ctx);
		},
	});

	pi.on("session_start", async (event, ctx) => {
		if (!ctx.hasUI) return;
		if (event.reason === "reload") {
			setBottomPinnedBlankHeader(ctx);
			return;
		}
		showSplashAsHeader(ctx, 10);
	});
}
