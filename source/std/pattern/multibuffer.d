module std.pattern.multibuffer;

struct MultiBuffer(Buffer, size_t N)
{
	Buffer[N] buffers;

	size_t index;

	enum bool empty = false;

	alias front this;
	@property
	{
		auto ref Buffer front()
		{
			return buffers[index];
		}

		auto ref Buffer back()
		{
			if (index < N)
			{
				return buffers[$ - 1];
			}
			else
			{
				return buffers[$ - 2];
			}
		}
	}

	void popFront()
	{
		index = (index + 1) % N;
	}
}
