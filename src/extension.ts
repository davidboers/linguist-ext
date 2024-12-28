import * as vscode from 'vscode';
import * as ChildProcess from 'child_process';
import { findRubyExec, findGemExec, isGemInstalled, findLinguistExec } from './ruby';

export function activate(context: vscode.ExtensionContext) {
	vscode.workspace.onDidOpenTextDocument(async (document: vscode.TextDocument) => await activeServer(context, document));

	let ruby = findRubyExec();
	let gem = findGemExec();

	isGemInstalled(gem, 'github-linguist');

	let linguist = findLinguistExec();

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
			let msg = `Something went wrong. Linguist gem returned error code: ${out.status}`;
			if (out.stdout !== null || out.stdout !== undefined) {
				msg += dumpText(out.stdout);
			}
			vscode.window.showErrorMessage(msg);
			throw new Error(msg);
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

function dumpText(buffer: Buffer<ArrayBufferLike>): string {
	let text = '';
	buffer.forEach((value) => { text += String.fromCharCode(value); });
	return text;
}