// Pushdown Automata with a door

void main()
{
	enum bool nogc = true;
	static if (nogc)
	{
		import game.cli : interactive;
		import std.experimental.allocator.mallocator : Mallocator;
		interactive!(typeof(Mallocator.instance))(Mallocator.instance);
	}
	else
	{
		import std.experimental.allocator : theAllocator;
		interactive!(typeof(theAllocator))(theAllocator);
	}
	/+
	// Create a door
	import game.door.door : Door;
	auto door = new Door;

	// Synchronously handle door input
	import game.door.state : Input;
	door.handleInput(Input.Lock);
	door.update();

	door.handleInput(Input.Close);
	door.update();

	door.handleInput(Input.Lock);
	door.update();

	door.handleInput(Input.Open);
	door.update();

	door.handleInput(Input.Unlock);
	door.update();

	door.handleInput(Input.Open);
	door.update();

	import std.stdio : writeln;
	writeln();

	// Asynchronously handle door input
	door.handleInput(Input.Close);
	door.handleInput(Input.Lock);
	door.update();

	door.handleInput(Input.Unlock);
	door.handleInput(Input.Open);
	door.update();
	+/
}
