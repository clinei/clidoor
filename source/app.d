void main()
{
	import game.door.door : Door;
	auto door = new Door;

	import game.door.state : Input;
	door.handleInput(Input.Lock);
	door.update();

	door.handleInput(Input.Close);
	door.update();

	door.handleInput(Input.Lock); // Should lock, doesn't, because pushes and pops at front
	door.update();

	door.handleInput(Input.Open);
	door.update();

	door.handleInput(Input.Unlock);
	door.update();

	door.handleInput(Input.Open);
	door.update();
}
