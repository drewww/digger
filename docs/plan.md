# NEXT
 - [DONE] Try putting valuable stuff around. Just an actor that has a gold color. Produce it with a simple "vein" agent that moves around in walls.
- Make a dynamite action that drops dynamite that remote activates? Save on countdown system.
- [DONE] Make the player tiny and have the big thing be a drill?? 
   - make a push action
   - if you push, drill on the opposite side of the drill
   - can only do a dig if you're within range of the drill
      - could have there be a cable connection that traces back and limits your range
      - what if it's docked TO the drill? it moves around w/ the drill and then you bump it to pick it up. 
- [DONE] make player 1x1
- [DONE] make bump to mine action, leave "rubble" behind
   - consider fun rubble dynamics -- can it fill up and spill out?? where does it go for big miner activities?
- [done] make big thing
- [done] make big thing pushable
   - [done] make push action
- [done] make pushing big thing mine big
- [done] make pull
   - [done] could be first "push" into something makes it a unit for moving 
   - then when you move it moves anything connected to you in the same vector
   - if the move fails, disconnect


- think about how to do multi-piece gold?
   - this is tractable but not exactly a top priority. but it would allow for strangely shaped "whole" pieces which is a cool thing I want to feel out
   - would this be the same system for other oddly shaped actors?
   - move
      - crawl the tree of any attached entities
      - do they attach to each other or attach to the player? probably the player directly, avoid having a tree structure.
      - does it attach automatically, like a system? if a gold touches another gold link them?
   - depends also if I want to have the ability to have a "native" structure, i.e. it spawns in as a 3x2 rectangle and if you drop it it reverts to that. i guess that could be a separate tree-style linkage?? can always add later
   - but generally speaking there's convenience bulk carrying and there's getting something pristine extracted
   - give it a try...
      - change to flat yellow block
      - add a link to the player if, after a move, a held block is adjacent to an unheld block
      - when we drop ... unlink everyting?
         - that creates a funny dynamic when you pick up.
         - so for now keep it all linked. 
- stop merging automatically; on grab, look for all adjacent ones and grab them at once.
- build the range-based dig ability
   - have an entity that when bumped basically "picks up" an item.
   - visually would we show the player holding it? ideally yes, that matches other things
   - draw a path from the player back to the "home" entity
   - re-bump the home entity to drop it and rest
- do the multi-sized pushing behavior -- make a 4x4 pushable into walls and digging?
   - if we only did square then this is okay but if we wanted, say, a 3x1 drill THEN we have to build rotation.
   - maybe if you attach at the angle you can rotate it? but the middle is push mode?

what's the deal with rubble? that feels like potentially interesting friction. do you need to go get a shovel or something to compact it? if you don't, what's the cost? hmmm.