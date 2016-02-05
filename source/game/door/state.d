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

final class OpenState : DoorState
{
	void handleInput(Door door, Input input)
	{
		switch (input) with(Input)
		{
			case Close:
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

	override string toString()
	{
		return "Open";
	}
}

final class ClosedState : DoorState
{
	void handleInput(Door door, Input input)
	{
		switch (input) with(Input)
		{
			case Open:
				import game.door.command : PopStateCommand;
				auto popCommand = new PopStateCommand(door);
				door.addCommand(popCommand);

				auto newState = new OpenState;
				import game.door.command : PushStateCommand;
				auto pushCommand = new PushStateCommand(door, newState);
				door.addCommand(pushCommand);
				break;
			case Lock:
				auto newState = new LockedState;
				import game.door.command : PushStateCommand;
				auto pushCommand = new PushStateCommand(door, newState);
				door.addCommand(pushCommand);
				break;
			default:
				break;
		}
	}

	override string toString()
	{
		return "Closed";
	}
}

final class LockedState : DoorState
{
	void handleInput(Door door, Input input)
	{
		switch (input) with(Input)
		{
			case Unlock:
				import game.door.command : PopStateCommand;
				auto popCommand = new PopStateCommand(door);
				door.addCommand(popCommand);
				break;
			default:
				break;
		}
	}

	override string toString()
	{
		return "Locked";
	}
}
