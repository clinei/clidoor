module game.cli;

/// Command line interface

import std.experimental.allocator : theAllocator;
void interactive(A)(auto ref A allocator)
{
	scope(exit)
	{
		import std.stdio : writeln;
		writeln("Quitting...");
	}

	import std.experimental.allocator : make;
	import game.door.door : Door;
	auto door = allocator.make!(Door!A)(allocator);

	printHelp();
	printCommands();

	string req;
	while (true)
	{
		printCursor();
		import std.stdio : readln;
		req = readln();
		req.length -= 1; // pop off the '\n'

		foreach (c; req)
		{
			import game.door.state : Input;
			switch (c)
			{
				case 's':
					import std.stdio : writeln;
					writeln(door.states[]);
					break;
				case 'm':
					import std.stdio : writeln;
					writeln(door.inputCommands[]);
					break;
				case 'h':
					printHelp();
					printCommands();
					break;
				case 'c':
					door.handleInput(Input.Close);
					break;
				case 'o':
					door.handleInput(Input.Open);
					break;
				case 'l':
					door.handleInput(Input.Lock);
					break;
				case 'n':
					door.handleInput(Input.Unlock);
					break;
				case 'k':
					door.handleInput(Input.Kick);
					break;
				case 'r':
					door.handleInput(Input.Repair);
					break;
				case 'a':
					door.update();
					break;
				case 'q':
					return;
				default:
					import std.conv : to;
					printUnrecognized(c.to!string);
					break;
			}
		}

		string res;
	}
}

void printCursor()
{
	import std.stdio : write;
	import game.cli.data.text : cursor;
	write(cursor);
}

void printUnrecognized(string req)
{
	import std.stdio : writeln;
	writeln("Command '" ~ req ~ "' not recognized. ");
}

void printHelp()
{
	import std.stdio : writeln;
	import game.cli.data.text : help;
	writeln(help);
}

void printCommands()
{
	import std.stdio : writeln;
	import game.cli.data.text : commands;
	writeln(commands);
}
