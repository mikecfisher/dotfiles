#!/usr/bin/env bun

// TypeScript declarations for Node.js globals
declare const process: {
  env: {
    [key: string]: string | undefined;
    HOME?: string;
    XDG_CONFIG_HOME?: string;
  };
  exit(code: number): never;
};

// @ts-ignore - Ignore module resolution errors for Node.js built-ins
import { execSync } from 'child_process';
// @ts-ignore - Ignore module resolution errors for Node.js built-ins
import fs from 'fs';
// @ts-ignore - Ignore module resolution errors for js-yaml
import yaml from 'js-yaml';

// Define types for our YAML structure
type PackagesYaml = {
  packages: {
    taps: string[];
    common: {
      brews: string[];
      casks: string[];
      mas?: Array<{ id: number; name: string }>;
    };
    personal?: {
      brews?: string[];
      casks?: string[];
      mas?: Array<{ id: number; name: string }>;
    };
  };
};

// Helper function to clean strings from any quotes
function cleanQuotes(str: string): string {
  // Remove all quotes (single and double) from the string
  return str.replace(/^(['"])(.*)\1$/, '$2').replace(/^'+"(.*)"+\'$/, '$1');
}

try {
  // Get paths
  const chezmoiSourcePath = execSync('chezmoi source-path').toString().trim();
  const packagesYamlPath = `${chezmoiSourcePath}/.chezmoidata/packages.yaml`;
  const brewfilePath = `${process.env.HOME ? `${process.env.HOME}/.config` : '~/.config'}/brewfile/Brewfile`;

  console.log(`Updating ${packagesYamlPath} from ${brewfilePath}...`);

  // Check if files exist
  if (!fs.existsSync(packagesYamlPath)) {
    throw new Error(`packages.yaml not found at ${packagesYamlPath}`);
  }

  if (!fs.existsSync(brewfilePath)) {
    throw new Error(`Brewfile not found at ${brewfilePath}`);
  }

  // Read the current packages.yaml as string to preserve formatting
  const packagesYamlContent = fs.readFileSync(packagesYamlPath, 'utf8');

  // Parse Brewfile
  const brewfileContent = fs.readFileSync(brewfilePath, 'utf8');

  // Extract taps, brews, and casks with error handling and clean any quotes
  const taps = brewfileContent.split('\n')
    .filter(line => line.trim().startsWith('tap '))
    .map(line => {
      const tap = line.replace(/^tap\s+/, '');
      return cleanQuotes(tap);
    })
    .sort();

  const brews = brewfileContent.split('\n')
    .filter(line => line.trim().startsWith('brew '))
    .map(line => {
      const brew = line.replace(/^brew\s+/, '');
      return cleanQuotes(brew);
    })
    .sort();

  const casks = brewfileContent.split('\n')
    .filter(line => line.trim().startsWith('cask '))
    .map(line => {
      const cask = line.replace(/^cask\s+/, '');
      return cleanQuotes(cask);
    })
    .sort();

  console.log(`Found ${taps.length} taps, ${brews.length} brews, and ${casks.length} casks in Brewfile`);

  // Get personal packages from the YAML file
  const yamlObj = yaml.load(packagesYamlContent) as PackagesYaml;

  // Clean personal brews and casks for proper comparison
  const personalBrews = yamlObj.packages.personal?.brews?.map(brew => {
    return typeof brew === 'string' ? cleanQuotes(brew) : brew;
  }) || [];

  const personalCasks = yamlObj.packages.personal?.casks?.map(cask => {
    return typeof cask === 'string' ? cleanQuotes(cask) : cask;
  }) || [];

  // Filter out personal packages
  const commonBrews = brews.filter(brew => !personalBrews.includes(brew));
  const commonCasks = casks.filter(cask => !personalCasks.includes(cask));

  // Create a backup of the original file
  const backupPath = `${packagesYamlPath}.bak`;
  fs.writeFileSync(backupPath, packagesYamlContent);
  console.log(`Created backup at ${backupPath}`);

  // Update the taps section
  function updateTapsSection(yaml: string, newTaps: string[]): string {
    // Match the taps section
    const tapsRegex = /(packages:\s*\n\s+taps:\s*\n)(([\s]*-\s*[^\n]+\s*\n)*)/;
    const match = yaml.match(tapsRegex);

    if (!match) {
      console.warn('Warning: Could not find taps section in YAML file');
      return yaml;
    }

    // Use double quotes for all items
    const tapsText = newTaps.map(tap => `    - "${tap}"`).join('\n');
    return yaml.replace(tapsRegex, `$1${tapsText}\n`);
  }

  // Update the brews section
  function updateBrewsSection(yaml: string, newBrews: string[]): string {
    // Match the brews section
    const brewsRegex = /(common:\s*\n\s+brews:\s*\n)(([\s\S]*?)(?=\n\s+casks:|$))/;
    const match = yaml.match(brewsRegex);

    if (!match) {
      console.warn('Warning: Could not find brews section in YAML file');
      return yaml;
    }

    // Extract comments from the original section
    const comments: string[] = [];
    let currentComment = '';

    match[2].split('\n').forEach(line => {
      const trimmedLine = line.trim();
      if (trimmedLine.startsWith('#')) {
        currentComment = line;
        comments.push(currentComment);
      }
    });

    // Build the new section content with double quotes
    let newContent = '';

    // If there are comments, try to preserve them
    if (comments.length > 0) {
      // Simple approach: just add all comments at the top
      newContent = comments.join('\n') + '\n';
      // Then add all items with double quotes
      newContent += newBrews.map(item => `      - "${item}"`).join('\n');
    } else {
      // No comments, just add the items with double quotes
      newContent = newBrews.map(item => `      - "${item}"`).join('\n');
    }

    // Replace the section in the YAML
    return yaml.replace(brewsRegex, `$1${newContent}`);
  }

  // Update the casks section
  function updateCasksSection(yaml: string, newCasks: string[]): string {
    // Match the casks section
    const casksRegex = /(common:[\s\S]*?casks:\s*\n)(([\s\S]*?)(?=\n\s+\w|$))/;
    const match = yaml.match(casksRegex);

    if (!match) {
      console.warn('Warning: Could not find casks section in YAML file');
      return yaml;
    }

    // Extract comments from the original section
    const comments: string[] = [];
    let currentComment = '';

    match[2].split('\n').forEach(line => {
      const trimmedLine = line.trim();
      if (trimmedLine.startsWith('#')) {
        currentComment = line;
        comments.push(currentComment);
      }
    });

    // Build the new section content with double quotes
    let newContent = '';

    // If there are comments, try to preserve them
    if (comments.length > 0) {
      // Simple approach: just add all comments at the top
      newContent = comments.join('\n') + '\n';
      // Then add all items with double quotes
      newContent += newCasks.map(item => `      - "${item}"`).join('\n');
    } else {
      // No comments, just add the items with double quotes
      newContent = newCasks.map(item => `      - "${item}"`).join('\n');
    }

    // Replace the section in the YAML
    return yaml.replace(casksRegex, `$1${newContent}`);
  }

  // Update each section
  let updatedYaml = packagesYamlContent;
  updatedYaml = updateTapsSection(updatedYaml, taps);
  updatedYaml = updateBrewsSection(updatedYaml, commonBrews);
  updatedYaml = updateCasksSection(updatedYaml, commonCasks);

  // Write the updated YAML back to the file
  fs.writeFileSync(packagesYamlPath, updatedYaml);

  console.log(`✅ Updated ${packagesYamlPath} based on Brewfile changes`);
} catch (error) {
  console.error('❌ Error updating packages.yaml:', error);
  process.exit(1);
}