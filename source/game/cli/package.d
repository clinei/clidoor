module game.cli;

/// Command line interface

void interactive()
{
	scope(exit)
	{
		import std.stdio : writeln;
		writeln("Quitting...");
	}

	import game.door.door : Door;
	auto door = new Door;

	printHelp();
	printCommands();

	string req;
	while (true)
	{
		printCursor();
		import std.stdio : readln;
		req = readln();
		req.length -= 1; // pop off the '\n'

		import game.door.state : Input;
		switch (req)
		{
			case "s":
				import std.stdio : writeln;
				writeln(door.states);
				break;
			case "h":
// 				printHelp();
				printCommands();
				break;
			case "c":
				door.handleInput(Input.Close);
				break;
			case "o":
				door.handleInput(Input.Open);
				break;
			case "l":
				door.handleInput(Input.Lock);
				break;
			case "n":
				door.handleInput(Input.Unlock);
				break;
			case "u":
				import std.stdio : writeln;
				door.update();
				break;
			case "q":
				return;
			default:
				printUnrecognized(req);
				break;
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
