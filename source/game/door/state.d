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
import game.door.door : IDoor;
alias DoorState = CommandState!(IDoor, Input);

final class UnbrokenState : DoorState
{
	uint health;

	this(uint health)
	{
		this.health = health;
	}

	bool handleInput(IDoor door, Input input)
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
						door.addCommand!PopStateCommand;
					}

					import game.door.command : PushStateCommand;
					door.addCommand!(PushStateCommand!BrokenState);
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
	bool handleInput(IDoor door, Input input)
	{
		bool consumed = true;
		switch (input) with(Input)
		{
			case Repair:
				import game.door.command : PopStateCommand;
				door.addCommand!PopStateCommand;

				import game.door.command : PushStateCommand;
				door.addCommand!(PushStateCommand!UnbrokenState)(3);
				door.addCommand!(PushStateCommand!OpenState);
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
	bool handleInput(IDoor door, Input input)
	{
		bool consumed = true;
		switch (input) with(Input)
		{
			case Close:
				import game.door.command : PopStateCommand;
				door.addCommand!PopStateCommand;

				import game.door.command : PushStateCommand;
				door.addCommand!(PushStateCommand!ClosedState);
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
	bool handleInput(IDoor door, Input input)
	{
		bool consumed = true;
		switch (input) with(Input)
		{
			case Open:
				import game.door.command : PopStateCommand;
				door.addCommand!PopStateCommand;

				import game.door.command : PushStateCommand;
				door.addCommand!(PushStateCommand!OpenState);
				break;
			case Lock:
				import game.door.command : PushStateCommand;
				door.addCommand!(PushStateCommand!LockedState);
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
	bool handleInput(IDoor door, Input input)
	{
		bool consumed = true;
		switch (input) with(Input)
		{
			case Unlock:
				import std.experimental.allocator : make;
				import game.door.command : PopStateCommand;
				door.addCommand!PopStateCommand;
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
