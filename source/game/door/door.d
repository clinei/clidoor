module game.door.door;

interface IDoor
{
	import game.door.state : DoorState;
	import std.container.slist : SList;
	ref SList!DoorState states();

	import std.container.dlist : DList;
	import game.door.command : InputCommand;
	ref DList!InputCommand inputCommands();

	import game.door.command : StateCommand;
	ref DList!StateCommand stateCommands();

	void addCommand(StateCommand command);

	void addCommand(InputCommand command);

	import game.door.state : Input;
	void handleInput(Input input);
}

import std.experimental.allocator : theAllocator;
final class Door(A = typeof(theAllocator)) : IDoor
{
	import game.door.state : DoorState;
	import std.container.slist : SList;
	SList!DoorState _states;
	ref SList!DoorState states() { return _states; }

	import std.container.dlist : DList;
	import game.door.command : InputCommand;
	DList!InputCommand _inputCommands;
	ref DList!InputCommand inputCommands() { return _inputCommands; }

	import game.door.command : StateCommand;
	DList!StateCommand _stateCommands;
	ref DList!StateCommand stateCommands() { return _stateCommands; }

	import std.experimental.allocator : theAllocator;
	private A _allocator;

	static if (is(A == typeof(theAllocator)))
	{
		this()
		{
			this._allocator = theAllocator;
		}
	}

	this()(auto ref A allocator)
	{
		_allocator = allocator;

		import std.experimental.allocator : make;
		import game.door.state : UnbrokenState;
		states.insertFront(_allocator.make!UnbrokenState(3));

		import game.door.state : OpenState;
		states.insertFront(_allocator.make!OpenState);
	}

	void addCommand(StateCommand command)
	{
		stateCommands.insertBack(command);
	}

	void addCommand(InputCommand command)
	{
		inputCommands.insertBack(command);
	}

	void handleInput(Input input)
	{
		import std.experimental.allocator : make;
		import game.door.command : InputCommand;
		auto inputCommand = _allocator.make!InputCommand(this, input);
		addCommand(inputCommand);
	}

	private void updateState()
	{
		foreach (stateCommand; stateCommands)
		{
			stateCommand.exec();
			import std.experimental.allocator : dispose;
			//_allocator.dispose(stateCommand);
		}
		stateCommands.clear();
	}

	void update()
	{
		foreach (inputCommand; inputCommands)
		{
			updateState();
			inputCommand.exec();
			import std.experimental.allocator : dispose;
			//_allocator.dispose(inputCommand);
		}
		updateState();
		inputCommands.clear();
	}
}
