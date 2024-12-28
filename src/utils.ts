export function dumpText(buffer: Buffer<ArrayBufferLike>): string {
    let text = '';
    buffer.forEach((value) => { text += String.fromCharCode(value); });
    return text;
}