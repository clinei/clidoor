module game.door.state;

enum Input : uint
{
	None,
	Lock,
	Unlock,
	Open,
	Close
}

import std.pattern.state : CommandState;
import game.door.door : Door;
alias DoorState = CommandState!(Door, Input);

class OpenState : DoorState
{
	void handleInput(Door door, Input input)
	{
		switch (input)
		{
			case Input.Close:
				import game.door.command : PopStateCommand;
				auto popCommand = new PopStateCommand(door);
				door.addCommand(popCommand);

				auto newState = new ClosedState;
				import game.door.command : PushStateCommand;
				auto pushCommand = new PushStateCommand(door, newState);
				door.addCommand(pushCommand);
				break;
			default:
				break;
		}
	}
}

class ClosedState : DoorState
{
	void handleInput(Door door, Input input)
	{
		switch (input)
		{
			case Input.Open:
				import game.door.command : PopStateCommand;
				auto popCommand = new PopStateCommand(door);
				door.addCommand(popCommand);

				auto newState = new OpenState;
				import game.door.command : PushStateCommand;
				auto pushCommand = new PushStateCommand(door, newState);
				door.addCommand(pushCommand);
				break;
			case Input.Lock:
				auto newState = new LockedState;
				import game.door.command : PushStateCommand;
				auto pushCommand = new PushStateCommand(door, newState);
				door.addCommand(pushCommand);
				break;
			default:
				break;
		}
	}
}

class LockedState : DoorState
{
	void handleInput(Door door, Input input)
	{
		switch (input)
		{
			case Input.Unlock:
				import game.door.command : PopStateCommand;
				auto popCommand = new PopStateCommand(door);
				door.addCommand(popCommand);
				break;
			default:
				break;
		}
	}
}
