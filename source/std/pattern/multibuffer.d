module std.pattern.multibuffer;

struct MultiBuffer(Buffer, size_t N)
{
	Buffer[N] buffers;

	size_t index;

	enum bool empty = false;

	alias front this;
	@property
	{
		ref Buffer front()
		{
			return buffers[index];
		}

		ref Buffer back()
		{
			return buffers[(index + ($ - 1)) % $];
		}
	}

	ref Buffer opIndex(size_t i)
	{
		return buffers[(index + i) % $];
	}

	void popFront()
	{
		index = (index + 1) % N;
	}
}

unittest
{
	// test int buffer
	MultiBuffer!(int, 3) ibuf;
	ibuf = -1;
	ibuf.popFront();
	ibuf = 3;
	ibuf.popFront();
	ibuf = 2;

	ibuf.popFront();
	assert(ibuf == -1);
	ibuf.popFront();
	assert(ibuf == 3);
	ibuf.popFront();
	assert(ibuf == 2);

	// test int array buffer
	MultiBuffer!(int[], 3) iabuf;
	iabuf ~= -1;
	iabuf ~= 3;
	iabuf ~= 2;
	iabuf.popFront();
	iabuf ~= 1;
	iabuf ~= -3;
	iabuf ~= 2;
	iabuf.popFront();
	iabuf ~= 1;
	iabuf ~= 3;
	iabuf ~= -2;

	iabuf.popFront();
	assert(iabuf == [-1, 3, 2]);

	iabuf.popFront();
	assert(iabuf == [1, -3, 2]);

	iabuf.popFront();
	assert(iabuf == [1, 3, -2]);

	// check .back functionality
	iabuf.popFront();
	iabuf.popFront();
	auto iabuf1 = iabuf.front;
	iabuf.popFront();
	assert(iabuf.back == iabuf1);
	auto iabuf2 = iabuf.front;
	iabuf.popFront();
	assert(iabuf.back == iabuf2);
	auto iabuf3 = iabuf.front;
	iabuf.popFront();
	assert(iabuf.back == iabuf3);
}
