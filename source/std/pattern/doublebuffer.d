module std.pattern.doublebuffer;

import std.pattern.multibuffer : MultiBuffer;
alias DoubleBuffer(Buffer) = MultiBuffer!(Buffer, 2);
