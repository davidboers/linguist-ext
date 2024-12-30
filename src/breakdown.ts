import * as ChildProcess from 'child_process';
import * as path from 'path';
import { workspace, window, Uri } from 'vscode';
import { normalizePath } from './utils';

/* Breakdown commands */

export function inquireFile(cmd: string): string {
    const editor = window.activeTextEditor;
    if (!editor) {
        const msg = 'No active document.';
        window.showInformationMessage(msg);
        throw new Error(msg);
    }

    const path = normalizePath(editor.document.uri.path);
    const out = ChildProcess.spawnSync(cmd, [path, '--json'], { shell: true });
    if (out.status !== 0) {
        const dump = out.stderr.toString();
        const msg = `Something went wrong. Linguist gem returned error code: ${out.status}
        ${dump}`;
        window.showErrorMessage(msg);
        throw new Error(msg);
    }

    const dump = JSON.parse(out.stdout.toString());
    const lang = dump[path].language;
    window.showInformationMessage(`Language: ${lang}`);
    return lang;
}

export function breakdownGit(cmd: string) {
    makeBreakdown(cmd, getWorkspaceRoot().uri.path, 'breakdown-git.txt');
}

export function breakdownWorkspace(cmd: string) {
    makeBreakdown(cmd, getWorkspaceRoot().uri.path, 'breakdown-workspace.txt');
}

export function breakdownDir(cmd: string) {
    const editor = window.activeTextEditor;
    if (!editor) {
        const msg = 'No active document.';
        window.showErrorMessage(msg);
        throw new Error(msg);
    }
    const dir = workspace.getWorkspaceFolder(editor.document.uri)?.uri.path;
    if (dir === undefined) {
        window.showInformationMessage('The current document appears to be in the root directory. Using `linguist.breakdownWorkspace` command instead.');
        breakdownWorkspace(cmd);
    } else {
        makeBreakdown(cmd, dir, 'breakdown-dir.txt');
    }
}

/* Helpers */

function getWorkspaceRoot() {
    const folders = workspace.workspaceFolders;
    if (folders) {
        return folders[0];
    } else {
        const msg = 'Workspace is empty.';
        window.showErrorMessage(msg);
        throw new Error(msg);
    }
}

function getWorkspaceFile(name: string): Uri {
    const wsroot = getWorkspaceRoot().uri;
    return wsroot.with({ path: path.posix.join(wsroot.path, name) });
}

function makeBreakdown(cmd: string, loc: string, dumpPath: string) {
    loc = normalizePath(loc) + '/..';
    const out = ChildProcess.spawnSync(cmd, [loc], { shell: true });
    if (out.status === 0) {
        workspace.fs.writeFile(getWorkspaceFile(dumpPath), out.stdout);
    } else {
        workspace.fs.writeFile(getWorkspaceFile(dumpPath), out.stderr);
        const msg = `Request for breakdown failed with error code: ${out.status}.`;
        window.showErrorMessage(msg);
        throw new Error(msg);
    }
}
