# OneCityRP

OneCityRP is a SA-MP 0.3.DL-R1 Pawn roleplay gamemode intended for Linux SA-MP servers. It does not depend on open.mp APIs or plugins.

## Layout

- `OneCityRP.pwn`: gamemode source, including account, character, jobs, government duty, economy, inventory, crime, jail, houses, vehicles, and administrator foundations.
- `pawno/include/a_samp.inc`: SA-MP API declarations used by this gamemode.
- `models/`: the dedicated location for all SA-MP 0.3.DL vehicle, skin, object, and other model assets.
- `scriptfiles/accounts/`: runtime-generated character profile saves.
- `server.cfg`: Linux server configuration that loads `OneCityRP`.

## Build

Install the official SA-MP 0.3.DL-R1 Linux server package, then run its standard Pawn compiler from the project root:

```sh
/path/to/pawncc OneCityRP.pwn -ipawno/include -oOneCityRP.amx
```

Copy `OneCityRP.amx` to the server `gamemodes/` directory, retain the `models/` directory at the server root for DL resources, and start the Linux SA-MP server using `server.cfg`.

The source deliberately uses only SA-MP APIs. Model resources should always be added under `models/`, rather than scattered through unrelated directories.
