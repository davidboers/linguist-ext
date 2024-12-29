export function dumpText(buffer: Buffer<ArrayBufferLike>): string {
    let text = '';
    buffer.forEach((value) => { text += String.fromCharCode(value); });
    return text;
}

export function normalizePath(path: string): string {
    return path.replace('/c:/', 'C:/');
}