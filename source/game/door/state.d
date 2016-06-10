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

	import std.experimental.allocator : IAllocator, theAllocator;
	private IAllocator _allocator;

	this(uint health, IAllocator allocator = theAllocator)
	{
		this._allocator = allocator;
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
					import std.range : walkLength;
					foreach (state; door.states)
					{
						import std.experimental.allocator : make;
						import game.door.command : PopStateCommand;
						auto popCommand = _allocator.make!PopStateCommand(door, _allocator);
						door.addCommand(popCommand);
					}

					import std.experimental.allocator : make;
					auto newState = _allocator.make!BrokenState;

					import game.door.command : PushStateCommand;
					auto pushCommand = _allocator.make!PushStateCommand(door, newState);
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
	import std.experimental.allocator : IAllocator, theAllocator;
	private IAllocator _allocator;

	this(IAllocator allocator = theAllocator)
	{
		this._allocator = allocator;
	}

	bool handleInput(IDoor door, Input input)
	{
		bool consumed = true;
		switch (input) with(Input)
		{
			case Repair:
				import std.experimental.allocator : make;
				import game.door.command : PopStateCommand;
				auto popCommand = _allocator.make!PopStateCommand(door, _allocator);
				door.addCommand(popCommand);

				auto newState = _allocator.make!UnbrokenState(3);

				import game.door.command : PushStateCommand;
				auto pushCommand = _allocator.make!PushStateCommand(door, newState);
				door.addCommand(pushCommand);

				auto newState2 = _allocator.make!OpenState;

				auto pushCommand2 = _allocator.make!PushStateCommand(door, newState2);
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
	import std.experimental.allocator : IAllocator, theAllocator;
	private IAllocator _allocator;

	this(IAllocator allocator = theAllocator)
	{
		this._allocator = allocator;
	}

	bool handleInput(IDoor door, Input input)
	{
		bool consumed = true;
		switch (input) with(Input)
		{
			case Close:
				import std.experimental.allocator : make;
				import game.door.command : PopStateCommand;
				auto popCommand = _allocator.make!PopStateCommand(door, _allocator);
				door.addCommand(popCommand);

				auto newState = _allocator.make!ClosedState;

				import game.door.command : PushStateCommand;
				auto pushCommand = _allocator.make!PushStateCommand(door, newState);
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
	import std.experimental.allocator : IAllocator, theAllocator;
	private IAllocator _allocator;

	this(IAllocator allocator = theAllocator)
	{
		this._allocator = allocator;
	}

	bool handleInput(IDoor door, Input input)
	{
		bool consumed = true;
		switch (input) with(Input)
		{
			case Open:
				import std.experimental.allocator : make;
				import game.door.command : PopStateCommand;
				auto popCommand = _allocator.make!PopStateCommand(door, _allocator);
				door.addCommand(popCommand);

				auto newState = _allocator.make!OpenState;
				import game.door.command : PushStateCommand;
				auto pushCommand = _allocator.make!PushStateCommand(door, newState);
				door.addCommand(pushCommand);
				break;
			case Lock:
				import std.experimental.allocator : make;
				auto newState = _allocator.make!LockedState;
				import game.door.command : PushStateCommand;
				auto pushCommand = _allocator.make!PushStateCommand(door, newState);
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
	import std.experimental.allocator : IAllocator, theAllocator;
	private IAllocator _allocator;

	this(IAllocator allocator = theAllocator)
	{
		this._allocator = allocator;
	}

	bool handleInput(IDoor door, Input input)
	{
		bool consumed = true;
		switch (input) with(Input)
		{
			case Unlock:
				import std.experimental.allocator : make;
				import game.door.command : PopStateCommand;
				auto popCommand = _allocator.make!PopStateCommand(door, _allocator);
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
