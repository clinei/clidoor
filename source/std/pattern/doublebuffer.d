module std.pattern.doublebuffer;

import std.pattern.multibuffer : MultiBuffer;
alias DoubleBuffer(Buffer) = MultiBuffer!(Buffer, 2);

unittest
{
	import std.container.dlist : DList;
	DoubleBuffer!(DList!int) idbuf;
	idbuf.back ~= 1;
	idbuf.back ~= 2;
	idbuf.back ~= 3;

	// start popping from front
	idbuf.popFront();
	assert(idbuf.front.front == 1);
	idbuf.front.removeFront();
	assert(idbuf.front.front == 2);

	// append to back
	idbuf.back ~= 4;
	idbuf.back ~= 5;
	idbuf.back ~= 6;

	// resume popping from front
	idbuf.front.removeFront();
	assert(idbuf.front.front == 3);
	idbuf.front.removeFront();
	assert(idbuf.front.empty);

	// swap buffers
	idbuf.popFront();

	// pop from front again, content should be what was appended to back
	assert(idbuf.front.front == 4);
	idbuf.front.removeFront();
	assert(idbuf.front.front == 5);
	idbuf.front.removeFront();
	assert(idbuf.front.front == 6);
	idbuf.front.removeFront();
	assert(idbuf.front.empty);
}
