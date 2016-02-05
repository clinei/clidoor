module game.cli.data.text;

immutable cursor = ">>";

immutable help =
"Record commands for a door and apply
the recorded commands to update.
You can also chain the commands
e.g. 'cla' -> close, lock and apply.";

immutable commandList =
"h - show help
q - quit
s - show state
m - show recorded commands
a - apply recorded commands
c - close door
o - open door
l - lock door
n - unlock door
k - kick door
r - repair door";

immutable commands =
"Commands:
" ~ commandList;
