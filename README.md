# Orbits
This app simulates the behaviour of bodies moving under the influence of mutual gravitational forces. It is intended as a pleasant and soothing way of doodling with gravity.

The app has two modes of operation, “Normal” and “Central sun”. The mode of operation can be changed by tapping “Settings” at the top left of the screen and selecting the desired mode. To hide the settings, tap “Settings” again”.

In “Normal” mode you start with a blank canvas, and can place bodies of different types with varying initial velocities and watch the system evolve. To add a new body, select the body type, tap, and drag. The white curve will give a guess as to the initial path of the body.

In “Central sun” mode you start with a sun-sized body in the centre of the screen, and can place bodies which initially move in a circular orbit around the central sun.  To add a new body, select the body type, and tap. The program will do its best to place the new body in a circular orbit around the initial sun.

Zoom and pan gestures with two fingers should work as expected by a normal iOS user.

The type of the next body to be placed is selected on the list at the bottom of the screen. In normal mode the body types available are:

Earth (1 Earth mass)
Super Earth (5 Earth masses)
Ice giant (15 Earth masses)
Gas giant (300 Earth masses)
Brown dwarf (5,000 Earth masses)
Dwarf star (30,000 Earth masses)
Sun (330,000 Earth masses)
Giant star (10 Sun masses)

In “Central sun” mode, the “Sun” and “Giant star” options are not available.

Apart from the “Mode” setting, other settings available are:

Speed - slow down or speed up the motion of the bodies
Show trails - if on, will show the path of each body over the last few seconds
Reset - clear all bodies from the current list
Help - display this text

Bodies are shown in the centre of mass (CM) frame. This may cause some apparently odd behaviour, especially when adding a massive body moving at high speed, but on the whole it works well at keeping as many bodies on screen as possible.

The number of bodies is capped at 200 for computational reasons. Bodies that drift too far off screen are quietly removed from the list, which may also occasionally result in odd behaviour when the CM frame velocity is re-calculated without the missing body.

Such are my limitations, I have not managed to achieve perfect accuracy on an iPad running in real time, especially when the distance between two bodies is close to zero and the force approaches infinity. To avoid division by zero a bodge, aka “easing factor”, aka “accommodation coefficient” is applied. Cranking up the speed and showing trails at the same time may cause inaccuracies to become apparent, especially in the case of highly elliptical orbits when the bodies are close together.
