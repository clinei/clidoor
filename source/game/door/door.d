module game.door.door;

final class Door
{
	import game.door.state : DoorState;
	import std.container.slist : SList;
	SList!DoorState states;

	import std.container.dlist : DList;
	import game.door.command : InputCommand;
	DList!InputCommand inputCommands;

	import game.door.command : StateCommand;
	DList!StateCommand stateCommands;

	import std.experimental.allocator : IAllocator, theAllocator;
	private IAllocator _allocator;

	this(IAllocator allocator = theAllocator)
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

	import game.door.state : Input;
	void handleInput(Input input)
	{
		import std.experimental.allocator : make;
		import game.door.command : InputCommand;
		auto inputCommand = _allocator.make!InputCommand(this, input);
		addCommand(inputCommand);
	}

	void updateState()
	{
		foreach (stateCommand; stateCommands)
		{
			stateCommand.exec();
			import std.experimental.allocator : dispose;
			_allocator.dispose(stateCommand);
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
			_allocator.dispose(inputCommand);
		}
		updateState();
		inputCommands.clear();
	}
}
