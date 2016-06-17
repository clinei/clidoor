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
	import game.door.door : IDoor;
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
	import game.door.door : IDoor;
	
	import game.door.state : UnbrokenState;
	static if (is(C : UnbrokenState))
	{
		uint _health;

		this(IDoor door, uint health)
		{
			super(door);
			_health = health;
		}

		override void exec()
		{
			door.pushUnbrokenState(_health);
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
			import game.door.state : BrokenState;
			import game.door.state : OpenState;
			import game.door.state : ClosedState;
			import game.door.state : LockedState;
			static if (is(C : BrokenState))
			{
				door.pushBrokenState();
			}
			else if (is(C : OpenState))
			{
				door.pushOpenState();
			}
			else if (is(C : ClosedState))
			{
				door.pushClosedState();
			}
			else if (is(C : LockedState))
			{
				door.pushLockedState();
			}
		}
	}
}
