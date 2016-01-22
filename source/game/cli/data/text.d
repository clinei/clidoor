module game.cli.data.text;

immutable cursor = ">>";

immutable help =
"Record commands for a door and update
to apply the recorded commands.";

import std.format : format;
import game.cli.data.commands;
immutable commandList =
"h - show help
q - quit
s - show state
m - show recorded commands
a - apply recorded commands
c - close door
o - open door
l - lock door
n - unlock door";

immutable commands =
"Commands:
" ~ commandList;
