import * as vscode from 'vscode';
import { findRubyExec, findGemExec, isGemInstalled, findLinguistExec, findLinguistExtExec } from './ruby';
import { breakdownGit, breakdownWorkspace, breakdownDir, inquireFile } from './breakdown';

export function activate(context: vscode.ExtensionContext) {
	const ruby = findRubyExec();
	const gem = findGemExec();

	isGemInstalled(gem, 'github-linguist');
	//isGemInstalled(gem, 'linguist-ext');

	const linguist = findLinguistExec();
	const linguist_ext = findLinguistExtExec();

	console.log('Linguist extension is now active.');

	const inquireFileCommand = vscode.commands.registerCommand('linguist.inquireFile', () => { inquireFile(linguist); });
	const breakdownGitCommand = vscode.commands.registerCommand('linguist.breakdownGit', () => { breakdownGit(linguist); });
	const breakdownWorkspaceCommand = vscode.commands.registerCommand('linguist.breakdownWorkspace', () => { breakdownWorkspace(linguist_ext); });
	const breakdownDirCommand = vscode.commands.registerCommand('linguist.breakdownDir', () => { breakdownDir(linguist_ext); });

	context.subscriptions.push(inquireFileCommand);
	context.subscriptions.push(breakdownGitCommand);
	context.subscriptions.push(breakdownWorkspaceCommand);
	context.subscriptions.push(breakdownDirCommand);
}


export function deactivate() {
	console.log('Linguist extension is no longer active.');
}