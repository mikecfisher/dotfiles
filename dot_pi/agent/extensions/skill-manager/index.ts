import type { ExtensionAPI, ExtensionContext, ExtensionCommandContext } from "@mariozechner/pi-coding-agent";
import { existsSync } from "node:fs";
import { mkdir, readFile, writeFile, readdir } from "node:fs/promises";
import { dirname, join } from "node:path";
import { homedir } from "node:os";
import { Key, matchesKey, truncateToWidth, type Component } from "@mariozechner/pi-tui";

interface Config {
  defaultProfile: string;
  activeProfile?: string;
  profiles: Record<string, string[]>;
}

const configPath = join(homedir(), ".pi/agent/extensions/skill-manager/skill-manager.json");

const defaultConfig: Config = {
  defaultProfile: "lean",
  activeProfile: "lean",
  profiles: {
    lean: [],
    frontend: [
      "~/.agents/skills/frontend-design",
      "~/.agents/skills/polish",
      "~/.agents/skills/adapt",
      "~/.agents/skills/audit",
    ],
    planning: [
      "~/.agents/skills/write-a-prd",
      "~/.agents/skills/prd-to-plan",
      "~/.agents/skills/to-issues",
    ],
  },
};

export default function skillManager(pi: ExtensionAPI) {
  pi.on("resources_discover", async (_event, ctx) => {
    const config = await loadConfig();
    const activeProfile = getActiveProfile(config);
    const paths = getExistingSkillPaths(config, activeProfile);
    ctx.ui.setStatus("skill-manager", `skills: ${activeProfile}`);
    return { skillPaths: paths };
  });

  pi.on("session_start", async (_event, ctx) => {
    const config = await loadConfig();
    ctx.ui.setStatus("skill-manager", `skills: ${getActiveProfile(config)}`);
  });

  pi.registerCommand("skills", {
    description: "Manage active skill profile",
    getArgumentCompletions: (prefix: string) => {
      const words = prefix.trim().split(/\s+/);
      const first = words[0] ?? "";
      const subcommands = ["pick", "manage", "current", "profile", "edit", "help"];
      if (words.length <= 1 && !prefix.endsWith(" ")) {
        return subcommands.filter((s) => s.startsWith(first)).map((s) => ({ value: s, label: s }));
      }
      return null;
    },
    handler: async (args, ctx) => {
      const [subcommand, ...rest] = args.trim().split(/\s+/).filter(Boolean);

      switch (subcommand ?? "pick") {
        case "":
        case "pick":
          await pickProfile(ctx);
          return;
        case "manage":
          await manageProfiles(ctx);
          return;
        case "current":
          await showCurrent(ctx);
          return;
        case "profile":
          await switchProfile(rest.join(" "), ctx);
          return;
        case "edit":
          ctx.ui.notify(`Edit skill manager config: ${configPath}`, "info");
          return;
        case "help":
          showHelp(ctx);
          return;
        default:
          ctx.ui.notify(`Unknown /skills subcommand: ${subcommand}. Try /skills help`, "warning");
          return;
      }
    },
  });

  pi.registerShortcut("ctrl+shift+s", {
    description: "Pick skill profile",
    handler: async (ctx) => {
      await pickProfileNoReload(ctx);
      ctx.ui.notify("Profile saved. Run /reload to apply skills.", "info");
    },
  });
}

async function loadConfig(): Promise<Config> {
  await mkdir(dirname(configPath), { recursive: true });
  if (!existsSync(configPath)) {
    await writeFile(configPath, JSON.stringify(defaultConfig, null, 2) + "\n", "utf8");
    return defaultConfig;
  }

  try {
    const parsed = JSON.parse(await readFile(configPath, "utf8")) as Config;
    if (!parsed.defaultProfile || !parsed.profiles || typeof parsed.profiles !== "object") {
      throw new Error("missing defaultProfile/profiles");
    }
    return parsed;
  } catch (error) {
    throw new Error(`Invalid skill-manager config at ${configPath}: ${error instanceof Error ? error.message : String(error)}`);
  }
}

async function saveConfig(config: Config) {
  await mkdir(dirname(configPath), { recursive: true });
  await writeFile(configPath, JSON.stringify(config, null, 2) + "\n", "utf8");
}

function expandHome(path: string): string {
  return path === "~" ? homedir() : path.startsWith("~/") ? join(homedir(), path.slice(2)) : path;
}

function getActiveProfile(config: Config): string {
  return config.activeProfile ?? config.defaultProfile;
}

function getExistingSkillPaths(config: Config, profile: string): string[] {
  return (config.profiles[profile] ?? []).map(expandHome).filter((path) => existsSync(path));
}

function missingSkillPaths(config: Config, profile: string): string[] {
  return (config.profiles[profile] ?? []).filter((path) => !existsSync(expandHome(path)));
}

async function pickProfile(ctx: ExtensionCommandContext) {
  await pickProfileNoReload(ctx);
  await ctx.reload();
  return;
}

async function pickProfileNoReload(ctx: ExtensionContext) {
  const config = await loadConfig();
  const profiles = Object.keys(config.profiles).sort();
  if (profiles.length === 0) {
    ctx.ui.notify(`No profiles configured. Edit ${configPath}`, "warning");
    return;
  }

  const choice = await ctx.ui.select("Pick skill profile", profiles);
  if (!choice) return;

  config.activeProfile = choice;
  await saveConfig(config);
  ctx.ui.setStatus("skill-manager", `skills: ${choice}`);
  const missing = missingSkillPaths(config, choice);
  if (missing.length > 0) {
    ctx.ui.notify(`Profile '${choice}' saved with ${missing.length} missing skill path(s). See /skills current.`, "warning");
  } else {
    ctx.ui.notify(`Skill profile saved: ${choice}`, "info");
  }
}

async function switchProfile(name: string, ctx: ExtensionCommandContext) {
  const config = await loadConfig();
  if (!name) {
    ctx.ui.notify("Usage: /skills profile <name>", "warning");
    return;
  }
  if (!config.profiles[name]) {
    ctx.ui.notify(`Unknown skill profile '${name}'. Available: ${Object.keys(config.profiles).sort().join(", ")}`, "warning");
    return;
  }

  config.activeProfile = name;
  await saveConfig(config);
  ctx.ui.notify(`Switching skill profile to '${name}' and reloading…`, "info");
  await ctx.reload();
  return;
}

async function showCurrent(ctx: ExtensionContext) {
  const config = await loadConfig();
  const active = getActiveProfile(config);
  const configured = config.profiles[active] ?? [];
  const missing = missingSkillPaths(config, active);
  const lines = [
    `Skill Manager config: ${configPath}`,
    `Active profile: ${active}`,
    `Configured skills: ${configured.length}`,
    ...configured.map((p) => `- ${p}${existsSync(expandHome(p)) ? "" : " (missing)"}`),
  ];
  if (missing.length > 0) lines.push(`Missing paths: ${missing.length}`);
  ctx.ui.notify(lines.join("\n"), missing.length > 0 ? "warning" : "info");
}

function showHelp(ctx: ExtensionContext) {
  ctx.ui.notify([
    "/skills or /skills pick — choose a profile",
    "/skills manage — open full-screen profile/skill manager",
    "/skills current — show active profile and configured skill paths",
    "/skills profile <name> — switch profile and reload",
    "/skills edit — show config path",
    `Config: ${configPath}`,
  ].join("\n"), "info");
}

interface InstalledSkill {
  name: string;
  path: string;
}

async function manageProfiles(ctx: ExtensionCommandContext) {
  const config = await loadConfig();
  const installed = await discoverInstalledSkills();
  const result = await ctx.ui.custom<{ saved: boolean; config?: Config }>((_tui, theme, _keybindings, done) => {
    return new SkillManagerComponent(config, installed, theme, done);
  });

  if (!result.saved || !result.config) return;
  await saveConfig(result.config);
  ctx.ui.notify("Skill profiles saved. Reloading…", "info");
  await ctx.reload();
  return;
}

async function discoverInstalledSkills(): Promise<InstalledSkill[]> {
  const roots = [join(homedir(), ".pi/agent/skills"), join(homedir(), ".agents/skills")];
  const found = new Map<string, InstalledSkill>();

  for (const root of roots) {
    await scanSkillDir(root, found);
  }

  return [...found.values()].sort((a, b) => a.name.localeCompare(b.name));
}

async function scanSkillDir(dir: string, found: Map<string, InstalledSkill>) {
  if (!existsSync(dir)) return;
  const skillFile = join(dir, "SKILL.md");
  if (existsSync(skillFile)) {
    const name = dir.split("/").pop() ?? dir;
    if (!found.has(name)) found.set(name, { name, path: dir });
    return;
  }

  let entries: Awaited<ReturnType<typeof readdir>>;
  try {
    entries = await readdir(dir, { withFileTypes: true });
  } catch {
    return;
  }

  for (const entry of entries) {
    if (!entry.isDirectory() || entry.name === "node_modules" || entry.name.startsWith(".")) continue;
    await scanSkillDir(join(dir, entry.name), found);
  }
}

class SkillManagerComponent implements Component {
  private profiles: string[];
  private activeProfile: string;
  private selected = 0;
  private scroll = 0;
  private cachedWidth?: number;
  private cachedLines?: string[];
  private selectedPaths: Set<string>;

  constructor(
    private config: Config,
    private installed: InstalledSkill[],
    private theme: any,
    private done: (result: { saved: boolean; config?: Config }) => void,
  ) {
    this.profiles = Object.keys(config.profiles).sort();
    this.activeProfile = getActiveProfile(config);
    this.selectedPaths = new Set((config.profiles[this.activeProfile] ?? []).map(expandHome));
  }

  handleInput(data: string): void {
    if (matchesKey(data, Key.up)) this.move(-1);
    else if (matchesKey(data, Key.down)) this.move(1);
    else if (matchesKey(data, Key.home)) this.setSelected(0);
    else if (matchesKey(data, Key.end)) this.setSelected(this.installed.length - 1);
    else if (matchesKey(data, Key.space)) this.toggleSelected();
    else if (data === "p") this.cycleProfile(1);
    else if (data === "P") this.cycleProfile(-1);
    else if (data === "a") this.selectAll();
    else if (data === "x") this.clearAll();
    else if (data === "n") this.createProfile();
    else if (data === "d") this.deleteProfile();
    else if (matchesKey(data, Key.enter) || data === "s") this.save();
    else if (matchesKey(data, Key.escape) || data === "q") this.done({ saved: false });
  }

  render(width: number): string[] {
    if (this.cachedLines && this.cachedWidth === width) return this.cachedLines;
    const height = 22;
    const visibleItems = Math.max(6, height - 8);
    this.scroll = Math.min(this.scroll, Math.max(0, this.installed.length - visibleItems));
    if (this.selected < this.scroll) this.scroll = this.selected;
    if (this.selected >= this.scroll + visibleItems) this.scroll = this.selected - visibleItems + 1;

    const lines: string[] = [];
    const title = this.theme.fg?.("accent", "Skill Manager") ?? "Skill Manager";
    lines.push(truncateToWidth(`${title}  profile: ${this.activeProfile}  (${this.selectedPaths.size} selected)`, width));
    lines.push(truncateToWidth("↑/↓ move  space toggle  p/P profile  n new  d delete  a all  x none  s/enter save  q/esc cancel", width));
    lines.push(truncateToWidth("─".repeat(Math.max(0, width)), width));

    if (this.installed.length === 0) {
      lines.push("No installed skills found in ~/.pi/agent/skills or ~/.agents/skills");
    } else {
      const slice = this.installed.slice(this.scroll, this.scroll + visibleItems);
      for (let i = 0; i < slice.length; i++) {
        const absoluteIndex = this.scroll + i;
        const skill = slice[i];
        const checked = this.selectedPaths.has(skill.path) ? "☑" : "☐";
        const cursor = absoluteIndex === this.selected ? "›" : " ";
        let line = `${cursor} ${checked} ${skill.name}  ${prettifyHome(skill.path)}`;
        if (absoluteIndex === this.selected) line = this.theme.bg?.("selectedBg", line) ?? line;
        lines.push(truncateToWidth(line, width));
      }
    }

    lines.push(truncateToWidth("─".repeat(Math.max(0, width)), width));
    lines.push(truncateToWidth(`Profiles: ${this.profiles.map((p) => p === this.activeProfile ? `[${p}]` : p).join("  ")}`, width));
    lines.push(truncateToWidth(`Config: ${prettifyHome(configPath)}`, width));
    lines.push(truncateToWidth("Save applies selected skills to the active profile and reloads pi resources.", width));

    this.cachedWidth = width;
    this.cachedLines = lines;
    return lines;
  }

  invalidate(): void {
    this.cachedWidth = undefined;
    this.cachedLines = undefined;
  }

  private move(delta: number) {
    this.setSelected(this.selected + delta);
  }

  private setSelected(index: number) {
    this.selected = Math.max(0, Math.min(this.installed.length - 1, index));
    this.invalidate();
  }

  private toggleSelected() {
    const skill = this.installed[this.selected];
    if (!skill) return;
    if (this.selectedPaths.has(skill.path)) this.selectedPaths.delete(skill.path);
    else this.selectedPaths.add(skill.path);
    this.invalidate();
  }

  private cycleProfile(delta: number) {
    if (this.profiles.length === 0) return;
    this.persistCurrentSelection();
    const current = Math.max(0, this.profiles.indexOf(this.activeProfile));
    this.activeProfile = this.profiles[(current + delta + this.profiles.length) % this.profiles.length];
    this.config.activeProfile = this.activeProfile;
    this.selectedPaths = new Set((this.config.profiles[this.activeProfile] ?? []).map(expandHome));
    this.invalidate();
  }

  private selectAll() {
    this.selectedPaths = new Set(this.installed.map((s) => s.path));
    this.invalidate();
  }

  private clearAll() {
    this.selectedPaths.clear();
    this.invalidate();
  }

  private createProfile() {
    const base = "new-profile";
    let name = base;
    let i = 2;
    while (this.config.profiles[name]) name = `${base}-${i++}`;
    this.persistCurrentSelection();
    this.config.profiles[name] = [];
    this.profiles = Object.keys(this.config.profiles).sort();
    this.activeProfile = name;
    this.config.activeProfile = name;
    this.selectedPaths = new Set();
    this.invalidate();
  }

  private deleteProfile() {
    if (this.profiles.length <= 1) return;
    delete this.config.profiles[this.activeProfile];
    this.profiles = Object.keys(this.config.profiles).sort();
    this.activeProfile = this.profiles[0];
    this.config.activeProfile = this.activeProfile;
    this.config.defaultProfile = this.config.profiles[this.config.defaultProfile] ? this.config.defaultProfile : this.activeProfile;
    this.selectedPaths = new Set((this.config.profiles[this.activeProfile] ?? []).map(expandHome));
    this.invalidate();
  }

  private save() {
    this.persistCurrentSelection();
    this.config.activeProfile = this.activeProfile;
    if (!this.config.profiles[this.config.defaultProfile]) this.config.defaultProfile = this.activeProfile;
    this.done({ saved: true, config: this.config });
  }

  private persistCurrentSelection() {
    this.config.profiles[this.activeProfile] = [...this.selectedPaths].sort().map(prettifyHome);
  }
}

function prettifyHome(path: string): string {
  const home = homedir();
  return path === home ? "~" : path.startsWith(home + "/") ? `~/${path.slice(home.length + 1)}` : path;
}
