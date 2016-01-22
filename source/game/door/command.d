module game.door.command;

import std.pattern.command : Executable;

class DoorCommand : Executable
{
	import game.door.door : Door;
	Door door;

	this(Door door)
	{
		this.door = door;
	}

	abstract void exec();
}

class InputCommand : DoorCommand
{
	import game.door.state : Input;
	Input input;

	import game.door.door : Door;
	this(Door door, Input input)
	{
		super(door);
		this.input = input;
	}

	override void exec()
	{
		door.states.front.handleInput(door, input);
	}
}

alias StateCommand = DoorCommand;

class PopStateCommand : StateCommand
{
	this(Door door)
	{
		super(door);
	}

	override void exec()
	{
		door.states.removeFront();
	}
}

class PushStateCommand : StateCommand
{
	import game.door.state : DoorState;
	DoorState state;

	this(Door door, DoorState state)
	{
		super(door);
		this.state = state;
	}

	override void exec()
	{
		door.states.insertFront(state);
	}
}
