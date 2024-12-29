import * as vscode from 'vscode';
import * as ChildProcess from 'child_process';
import { findRubyExec, findGemExec, isGemInstalled, findLinguistExec, findLinguistExtExec } from './ruby';
import { dumpText } from './utils';
import { breakdownGit, breakdownWorkspace, breakdownDir } from './breakdown';

export function activate(context: vscode.ExtensionContext) {
	const ruby = findRubyExec();
	const gem = findGemExec();

	isGemInstalled(gem, 'github-linguist');
	//isGemInstalled(gem, 'linguist-ext');

	const linguist = findLinguistExec();
	const linguist_ext = findLinguistExtExec();

	console.log('Linguist extension is now active.');

	const inquireFile = vscode.commands.registerCommand('linguist.inquireFile', () => {
		const editor = vscode.window.activeTextEditor;
		if (!editor) {
			const msg = 'No active document.';
			vscode.window.showInformationMessage(msg);
			throw new Error(msg);
		}

		const path = editor.document.uri.path.replace('/c:/', 'C:/');
		const out = ChildProcess.spawnSync(linguist, [path], { shell: true });
		if (out.status !== 0) {
			const dump = dumpText(out.stderr);
			const msg = `Something went wrong. Linguist gem returned error code: ${out.status}
			${dump}`;
			vscode.window.showErrorMessage(msg);
			throw new Error(msg);
		}
	});

	context.subscriptions.push(inquireFile);

	const breakdownGitCommand = vscode.commands.registerCommand('linguist.breakdownGit', () => { breakdownGit(linguist); });
	const breakdownWorkspaceCommand = vscode.commands.registerCommand('linguist.breakdownWorkspace', () => { breakdownWorkspace(linguist_ext); });
	const breakdownDirCommand = vscode.commands.registerCommand('linguist.breakdownDir', () => { breakdownDir(linguist_ext); });


	context.subscriptions.push(breakdownGitCommand);
	context.subscriptions.push(breakdownWorkspaceCommand);
	context.subscriptions.push(breakdownDirCommand);
}


export function deactivate() {
	console.log('Linguist extension is no longer active.');
}