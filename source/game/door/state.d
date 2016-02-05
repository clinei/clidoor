module game.door.state;

enum Input : uint
{
	None,
	Lock,
	Unlock,
	Open,
	Close,
	Kick,
	Repair
}

import std.pattern.state : CommandState;
import game.door.door : Door;
alias DoorState = CommandState!(Door, Input);

final class UnbrokenState : DoorState
{
	uint health;

	this(uint health)
	{
		this.health = health;
	}

	bool handleInput(Door door, Input input)
	{
		bool consumed = true;
		switch (input) with(Input)
		{
			case Kick:
				if (health > 1)
				{
					health -= 1;
				}
				else
				{
					foreach (state; door.states)
					{
						import game.door.command : PopStateCommand;
						auto popCommand = new PopStateCommand(door);
						door.addCommand(popCommand);
					}

					auto newState = new BrokenState;

					import game.door.command : PushStateCommand;
					auto pushCommand = new PushStateCommand(door, newState);
					door.addCommand(pushCommand);
				}
				break;
			default:
				consumed = false;
				break;
		}
		return consumed;
	}

	override string toString()
	{
		import std.conv : to;
		return "Unbroken(" ~ health.to!string ~ ")";
	}
}

final class BrokenState : DoorState
{
	bool handleInput(Door door, Input input)
	{
		bool consumed = true;
		switch (input) with(Input)
		{
			case Repair:
				import game.door.command : PopStateCommand;
				auto popCommand = new PopStateCommand(door);
				door.addCommand(popCommand);

				auto newState = new UnbrokenState(3);

				import game.door.command : PushStateCommand;
				auto pushCommand = new PushStateCommand(door, newState);
				door.addCommand(pushCommand);

				auto newState2 = new OpenState;

				auto pushCommand2 = new PushStateCommand(door, newState2);
				door.addCommand(pushCommand2);
				break;
			default:
				consumed = false;
				break;
		}
		return consumed;
	}

	override string toString()
	{
		return "Broken";
	}
}

final class OpenState : DoorState
{
	bool handleInput(Door door, Input input)
	{
		bool consumed = true;
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
				consumed = false;
				break;
		}
		return consumed;
	}

	override string toString()
	{
		return "Open";
	}
}

final class ClosedState : DoorState
{
	bool handleInput(Door door, Input input)
	{
		bool consumed = true;
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
				consumed = false;
				break;
		}
		return consumed;
	}

	override string toString()
	{
		return "Closed";
	}
}

final class LockedState : DoorState
{
	bool handleInput(Door door, Input input)
	{
		bool consumed = true;
		switch (input) with(Input)
		{
			case Unlock:
				import game.door.command : PopStateCommand;
				auto popCommand = new PopStateCommand(door);
				door.addCommand(popCommand);
				break;
			default:
				consumed = false;
				break;
		}
		return consumed;
	}

	override string toString()
	{
		return "Locked";
	}
}
