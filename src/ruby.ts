import * as ChildProcess from 'child_process';
import * as fs from 'fs';
import { workspace, window } from 'vscode';

function findExecTemp(setting: string, execName: string): string {
    let exePath = workspace.getConfiguration('linguist').get(setting) as string;
    if (executableExists(exePath)) {
        return exePath;
    } else {
        const msg = `Could not find ${execName} executable at '${exePath}'! 
        Consider changing the 'linguist.${setting}' setting, and make sure the executable is installed on your computer by running '${findCommand()} ${execName.toLowerCase()}'`;
        window.showErrorMessage(msg);
        throw new Error(msg);
    }
}

export function findRubyExec(): string {
    return findExecTemp('rubyExecutable', 'Ruby');
}

export function findGemExec(): string {
    return findExecTemp('gemExecutable', 'Gem');
}

export function findLinguistExec(): string {
    return findExecTemp('linguistExecutable', 'github-linguist');
}

export function findLinguistExtExec(): string {
    return findExecTemp('linguistExtExecutable', 'linguist-ext');
}

export function isGemInstalled(gemExec: string, gemName: string) {
    const args = ['list', '-i', gemName];
    const out = ChildProcess.spawnSync(gemExec, args, { shell: true });
    if (out.status !== 0) {
        const msg = 'Gem not installed. Install using `gem install github-linguist`';
        window.showErrorMessage(msg);
        throw new Error(msg);
    }
}

function findCommand(): string {
    const isWindows = process.platform === 'win32';
    return isWindows ? 'where' : 'which';
}

function executableExists(exe: string): boolean {
    const cmd: string = findCommand();
    const out = ChildProcess.spawnSync(cmd, [exe]);
    return out.status === 0 || fs.existsSync(exe);
}