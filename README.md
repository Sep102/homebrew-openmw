This homebrew repo contains modified formulae for dependencies of Mac version of [OpenMW][openmw]

Please note that all formulae have prefix `openmw-` to avoid name clashes with
homebrew master repo. Also all formulae are keg-only, it means that they won't
be linked to your homebrew prefix (`/usr/local` by default), avoiding any conflicts
with master repo formuale. It's builder responsibility to provide correct paths
when configuring `cmake` for OpenMW.

Check our [wiki page][openmw-devsetup-wiki] for more details.

[openmw]: http://openmw.org
[openmw-devsetup-wiki]: https://wiki.openmw.org/index.php?title=Development_Environment_Setup#OS_X
