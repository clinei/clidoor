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

	void popState();

	void pushState(C, Args...)(Args args);
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
	import std.experimental.allocator.building_blocks.free_list : FreeList;
	private FreeList!(A, InputCommand.sizeof) _inputCommandsAllocator;

	import game.door.command : StateCommand;
	DList!StateCommand _stateCommands;
	ref DList!StateCommand stateCommands() { return _stateCommands; }
	/+ // Free lists for fast command allocation
	import std.algorithm : min, max;
	import game.door.command : PushStateCommand, PopStateCommand;
	enum size_t pushSize = PushStateCommand.sizeof;
	enum size_t popSize = PopStateCommand.sizeof;
	private FreeList!(A, min(pushSize, popSize), max(pushSize, popSize)) _stateCommandsAllocator;
	+/

	private A _allocator;

	static if (is(A == typeof(theAllocator)))
	{
		this()
		{
			this(theAllocator);
		}
	}

	this(A allocator)
	{
		_allocator = allocator;

		import game.door.command : PushStateCommand;
		import game.door.state : UnbrokenState;
		addCommand!(PushStateCommand!UnbrokenState)(this, 3);

		import game.door.state : OpenState;
		addCommand!(PushStateCommand!OpenState)(this);
		update();
	}

	void addCommand(C, Args...)(Args args) if (is(C : StateCommand))
	{
		import std.experimental.allocator : make;
		//_stateCommandsAllocator.make!C(args);
		stateCommands.insertBack(_allocator.make!C(args));
	}

	private void addCommand(InputCommand command)
	{
		inputCommands.insertBack(command);
	}

	void handleInput(Input input)
	{
		import std.experimental.allocator : make;
		import game.door.command : InputCommand;
		auto inputCommand = _inputCommandsAllocator.make!InputCommand(this, input);
		addCommand(inputCommand);
	}

	private void updateState()
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

	void popState()
	{
		// not safe, apparently
		import std.experimental.allocator : dispose;
		auto front = states.front;
		states.removeFront();
		_allocator.dispose(front);
	}

	void pushState(C, Args...)(Args args)
	{
		import std.experimental.allocator : make;
		states.insertFront(_allocator.make!C(args));
	}
}
