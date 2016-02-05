module std.pattern.state;

interface State(Owner, Input)
{
	State handleInput(Owner owner, Input input);
}

interface CommandState(Owner, Input)
{
	bool handleInput(Owner owner, Input input);
}

interface Enterable(Owner)
{
	void enter(Owner owner);
}

interface Exitable(Owner)
{
	void exit(Owner owner);
}
