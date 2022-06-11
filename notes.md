# Tower Story

### Wtf i s this

A 3D SimTower, basically... it would be cool to have a "Story" be traceable via the denizens, if not playable, but perhaps injectable. Perhaps one person needs a certain kind of store to open up to help them get closer to another person, and when you do that their story progresses. Maybe it's an upfront way to move gameplay along, maybe it's a easter egg type thing.

Also, "story" is a decent pun here given stories in a building but... yeah.

"Story" could also be a decent moniker for a series of games (Farm Story etc)

But mostly, a 3D Sim Tower.

I would love to have a "base" game, a vanilla tower builder that focuses on the basics, but have an open "modding" system to make my own tropico tower style game afterwards on top of, if it's possible.

The modding opportunity for others would be cool, it would be a neat programming challenge for me, plus it is an opportunity to try and not just make two games, but to really cleanly separate systems from content and really think about those layers of abstraction well before most do.

I do think Godot offers a neat way to do this all with the editor, or perhaps by adjusting the editor -- which is something that I should find far more approachable now that I've futzed with C++ somewhat. It may be a good idea to start contributing open source aid eventually to Godot etc.

Anyway, the game.

Modding may be a more uphill battle than I'm willing to admit; however, it would be a way to draw a fine line between "universal" and "my own bullshit".

It could just be a whole-ass second game, or, just a box to put my ideas into that are out of scope for game one.

Hmm.

Either way, modding doesn't need to be thought of immediately, but to a light extent.

Maybe. Need to keep researching.




### 6.5.22 Making basic abstractions

Right now a floor is a prototype basically. What should be the base abstractions containing the basic components of a building? With disrespect to the current contents of the prototype scene.

- Building (this probably just needs to be represented in data, there may be a "city wide" type view"... OR, it could be the main scene, haha)
- Floor
- Room... ?
  - Would have to figure out how to best assemble what's needed here vs. a floor
    - given everything is dynamic this isn't too hard, maybe the "interior" walls can be drawn by a rooms' definition

Other considerations -- how to format data; probbaly best to be somewhat flat / not get into nested issues early possible.

Separating Floors & Room data makes sense. Currently one set of sets of x,y placements of tiles is fine for reprsenting multiple floor layouts w/n a building. Rooms can be indexed in a separate dictionary against their floors. Given "moving a whole floor" is an unlikely / understandably not supportable feature, this should be safe / with minimal error.

That said it doesn't matter much at first. I can alter the disk / memory storage formats given this is a game pretty easily later on (famous last words).
