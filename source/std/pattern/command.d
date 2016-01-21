module std.pattern.command;

interface Executable
{
	void exec();
}

interface Undoable
{
	void undo();
}
