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

	this()
	{
		import game.door.state : UnbrokenState;
		states.insertFront(new UnbrokenState(3));

		import game.door.state : OpenState;
		states.insertFront(new OpenState);
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
		import game.door.command : InputCommand;
		auto inputCommand = new InputCommand(this, input);
		addCommand(inputCommand);
	}

	void updateState()
	{
		foreach (stateCommand; stateCommands)
		{
			stateCommand.exec();
		}
		stateCommands.clear();
	}

	void update()
	{
		foreach (inputCommand; inputCommands)
		{
			updateState();
			inputCommand.exec();
		}
		updateState();
		inputCommands.clear();
	}
}
