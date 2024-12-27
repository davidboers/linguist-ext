import * as vscode from 'vscode';
import * as ChildProcess from 'child_process';
import { findRubyExec, findGemExec, isGemInstalled } from './ruby';

export function activate(context: vscode.ExtensionContext) {
	vscode.workspace.onDidOpenTextDocument(async (document: vscode.TextDocument) => await activeServer(context, document));

	let ruby = findRubyExec();
	let gem = findGemExec();
	if (!gem && !isGemInstalled(gem)) {
		vscode.window.showErrorMessage('Gem not installed. Install using `gem install github-linguist`');
	}

	console.log('Linguist extension is now active.');

	const inquireFile = vscode.commands.registerCommand('linguist.inquireFile', () => {
		const editor = vscode.window.activeTextEditor;
		if (!editor) {
			vscode.window.showInformationMessage('No active document.');
			return;
		}

		const path = editor.document.uri.path;
		const out = ChildProcess.spawnSync('github-linguist', [path]);
		if (out.status !== 0) {
			vscode.window.showErrorMessage(`Something went wrong. Linguist gem returned error code: ${out.status}`);
			return;
		}
	});

	context.subscriptions.push(inquireFile);
}

function activeServer(context: vscode.ExtensionContext, document: vscode.TextDocument) {
	const uri = document.uri;
	console.log('File opened.');
}


export function deactivate() {
	console.log('Linguist extension is no longer active.');
}
