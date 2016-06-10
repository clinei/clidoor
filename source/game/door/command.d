module game.door.command;

import std.pattern.command : Executable;

class DoorCommand : Executable
{
	import game.door.door : IDoor;
	IDoor door;

	this(IDoor door)
	{
		this.door = door;
	}

	abstract void exec();
}

final class InputCommand : DoorCommand
{
	import game.door.state : Input;
	Input input;

	import game.door.door : IDoor;
	this(IDoor door, Input input)
	{
		super(door);
		this.input = input;
	}

	override void exec()
	{
		foreach (state; door.states)
		{
			// Stop execution if input has been consumed
			if (state.handleInput(door, input))
			{
				goto Success;
			}
		}

		// Show info about the unconsumed command
		import std.stdio : writeln;
		import std.conv : to;
		writeln("'" ~ input.to!string ~ "' had no effect on the door.");

		Success: {}
	}

	override string toString()
	{
		import std.conv : to;
		return input.to!string;
	}
}

alias StateCommand = DoorCommand;

final class PopStateCommand : StateCommand
{
	import std.experimental.allocator : IAllocator, theAllocator;
	private IAllocator _allocator;

	this(IDoor door, IAllocator allocator)
	{
		super(door);
		this._allocator = allocator;
	}

	override void exec()
	{
		// not safe, apparently
		import std.experimental.allocator : dispose;
		//_allocator.dispose(door.states.front);
		door.states.removeFront();
	}
}

final class PushStateCommand : StateCommand
{
	import game.door.state : DoorState;
	DoorState state;

	this(IDoor door, DoorState state)
	{
		super(door);
		this.state = state;
	}

	override void exec()
	{
		door.states.insertFront(state);
	}
}
