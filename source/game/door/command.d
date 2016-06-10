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
	this(IDoor door)
	{
		super(door);
	}

	override void exec()
	{
		door.popState();
	}
}

final class PushStateCommand(C) : StateCommand
{
	enum bool needArgs = __traits(hasMember, C, "__ctor");
	static if (needArgs)
	{
		import std.traits : Parameters;
		alias Args = Parameters!(C.__ctor);
		import std.typecons : Tuple;
		Tuple!Args _args;

		this(IDoor door, Args args)
		{
			super(door);
			_args = args;
		}

		override void exec()
		{
			door.pushState!C(_args.expand);
		}
	}
	else
	{
		this(IDoor door)
		{
			super(door);
		}

		override void exec()
		{
			door.pushState!C;
		}
	}
}
