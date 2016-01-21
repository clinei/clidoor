module game.door.door;

class Door
{
	import game.door.state : DoorState;
	DoorState[] states;

	auto ref state() @property
	{
		if (states.length > 0)
		{
			import std.range.primitives : back;
			return states.back;
		}
		return null;
	}

	import std.pattern.doublebuffer : DoubleBuffer;
	import game.door.command : DoorCommand;
	DoubleBuffer!(DoorCommand[]) commandBuffers;

	this()
	{
		import game.door.state : OpenState;
		states ~= new OpenState;
	}

	void addCommand(DoorCommand command)
	{
		commandBuffers.back ~= command;
	}

	import game.door.state : Input;
	void handleInput(Input input)
	{
		state.handleInput(this, input);
	}

	void update()
	{
		import std.stdio : writeln;
		writeln(states);
		foreach (command; commandBuffers.front)
		{
			command.exec();
		}
		commandBuffers.front.length = 0;
		commandBuffers.popFront();

		writeln(states);
		writeln();
	}
}
