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
						door.addPopStateCommand();
					}
					door.addPushBrokenStateCommand();
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
				door.addPopStateCommand();

				door.addPushUnbrokenStateCommand(3);
				door.addPushOpenStateCommand();
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
				door.addPopStateCommand();
				door.addPushClosedStateCommand();
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
				door.addPopStateCommand();
				door.addPushOpenStateCommand();
				break;
			case Lock:
				door.addPushLockedStateCommand();
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
				door.addPopStateCommand();
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
