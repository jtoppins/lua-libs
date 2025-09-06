Coding/Naming Standards:
* lowercase if module returns a single function or set of functions/classes
* uppercase if module is a single class, filename must match classname
* All classes begin with uppercase all others are lowercase
* All public methods are camel case
* All internal/local fields begin with underscore
* All internal/local functions are lower case like_this()
* naming prefers verbs first then noun: readDocs()

Todo Modules:
- [ ] 'ui.Player'    - a container class that manages queuing messages
                       to the player and managing the menu
- [ ] 'ui.Menu'         - F10 Other menu manipulation
- [ ] 'ui.MessageQueue' - message queue for the player
- [ ] 'world.toCardinalDirection' - convert bearing to cardinal direction
       dct.ui.human.get_compass_direction
- [ ] 'world.BRAA'   - get bearing, range, altitude [, aspect] about
                       a unit from a reference
- [ ] 'world.aspect' - the USAF defines aspect for a given observer as the
                       angle theta formed by the vector out of the nose of
                       the observer aircraft and the vector formed from the
                       observer to the target. This makes the target's
                       heading irrelevant in calculating the observer's
                       aspect to the target.
- [ ] 'env.Weather'  - process the weather table
- [ ] 'env.terrain'  - contains data about the map like the list of towns,
                       navigation beacons, etc.
- [ ] callsign manager - should track state of which callsigns are
                         active and generate non-collidiable new
                         callsigns. Have the following API:
                         * generate(callsign_base)
                         * remove(callsign)
                         * property format = {"nato", "russian"}
                         The russian format is simply three numbers,
                         NATO is WORD-#-# where word is from a list.
- [ ] spatial hashing with nearest neighbor search
