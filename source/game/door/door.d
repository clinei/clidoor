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

	void popState();

	void pushBrokenState();

	void pushUnbrokenState(uint health);

	void pushOpenState();

	void pushClosedState();

	void pushLockedState();

	void addPopStateCommand();

	void addPushBrokenStateCommand();

	void addPushUnbrokenStateCommand(uint health);

	void addPushOpenStateCommand();

	void addPushClosedStateCommand();

	void addPushLockedStateCommand();

	import game.door.state : Input;
	void handleInput(Input input);
}

final class Door(A) : IDoor
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

	this(A allocator)
	{
		_allocator = allocator;

		import game.door.command : PushStateCommand;
		import game.door.state : UnbrokenState;
		addCommand!(PushStateCommand!UnbrokenState)(3);

		import game.door.state : OpenState;
		addCommand!(PushStateCommand!OpenState);
		update();
	}

	private void addCommand(C, Args...)(Args args) if (is(C : StateCommand))
	{
		import std.experimental.allocator : make;
		//_stateCommandsAllocator.make!C(args);
		stateCommands.insertBack(_allocator.make!C(this, args));
	}

	void addPopStateCommand()
	{
		import game.door.command : PopStateCommand;
		addCommand!PopStateCommand;
	}

	void addPushBrokenStateCommand()
	{
		import game.door.command : PushStateCommand;
		import game.door.state : BrokenState;
		addCommand!(PushStateCommand!BrokenState)();
	}

	void addPushUnbrokenStateCommand(uint health)
	{
		import game.door.command : PushStateCommand;
		import game.door.state : UnbrokenState;
		addCommand!(PushStateCommand!UnbrokenState)(health);
	}

	void addPushOpenStateCommand()
	{
		import game.door.command : PushStateCommand;
		import game.door.state : OpenState;
		addCommand!(PushStateCommand!OpenState)();
	}

	void addPushClosedStateCommand()
	{
		import game.door.command : PushStateCommand;
		import game.door.state : ClosedState;
		addCommand!(PushStateCommand!ClosedState)();
	}

	void addPushLockedStateCommand()
	{
		import game.door.command : PushStateCommand;
		import game.door.state : LockedState;
		addCommand!(PushStateCommand!LockedState)();
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

	private void pushState(C, Args...)(Args args)
	{
		import std.experimental.allocator : make;
		states.insertFront(_allocator.make!C(args));
	}

	void pushBrokenState()
	{
		import game.door.state : BrokenState;
		pushState!BrokenState();
	}

	void pushUnbrokenState(uint health)
	{
		import game.door.state : UnbrokenState;
		pushState!UnbrokenState(health);
	}

	void pushOpenState()
	{
		import game.door.state : OpenState;
		pushState!OpenState();
	}

	void pushClosedState()
	{
		import game.door.state : ClosedState;
		pushState!ClosedState();
	}

	void pushLockedState()
	{
		import game.door.state : LockedState;
		pushState!LockedState();
	}
}
