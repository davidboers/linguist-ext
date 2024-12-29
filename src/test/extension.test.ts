import * as assert from 'assert';

import * as vscode from 'vscode';
// import * as myExtension from '../../extension';

suite('Extension Test Suite', () => {
	vscode.window.showInformationMessage('Start all tests.');
	const extensionId = 'undefined_publisher.linguist';
	const extension = vscode.extensions.getExtension(extensionId);

	test('1. Activation', async () => {
		assert.ok(await extension?.activate().then(() => true));
	});

	test('2. Inquire file command', async () => {
		assert.ok(await vscode.commands.executeCommand('linguist.inquireFile').then(() => true));
	});

	test('3. Breakdown git command', async () => {
		assert.ok(await vscode.commands.executeCommand('linguist.breakdownGit').then(() => true));
	});

	test('4. Breakdown workspace command', async () => {
		assert.ok(await vscode.commands.executeCommand('linguist.breakdownWorkspace').then(() => true));
	});

	test('5. Breakdown dir command', async () => {
		assert.ok(await vscode.commands.executeCommand('linguist.breakdownDir').then(() => true));
	});
});
