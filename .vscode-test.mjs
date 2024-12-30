import { defineConfig } from '@vscode/test-cli';

export default defineConfig({
	files: 'out/test/**/*.test.js',
	workspaceFolder: './test',
	mocha: {
		timeout: 60 * 1000 // 1 minute
	}
});
