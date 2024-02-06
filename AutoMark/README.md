# AutoMark v1.0

This is a recreation of an add-on I made for my guild back in Spring 2020. I forgot it existed and I have lost the code for it. This new version is far more robust with regard to how it detects players that are no longer present. The old add-on was called "Radar" and if you're one of the few who has a copy and still uses it, delete it and replace it with this instead.

AutoMark automatically "marks" enemy players by putting an icon over them that corresponds to the enemy player's career. The icon has a red circle outline to make it easier to see. Useful for tracking enemy players during intense visual effects or if they are hiding behind walls as UI markers are displayed on top of the 3D world. This is the same kind of marks that the "Enemy" add-on can do, but it just does them automatically. To mark an enemy player, you either need to make them your current hostile target or your current "mouse-over" target (i.e. the info box you get when you put the cursor over an enemy). I've tried to make it as performant as possible but if you try to mark up the entire enemy zerg then your frame-rate will start to drop.

I don't plan on updating this add-on with new features but I will look into any bugs people find.

## Chat Commands

`/automark clear` will clear all current markers

`/automark off` will disable the tracking of new enemy player targets but will keep existing marks in place. Use with `/automark clear` to completely stop everything.

`/automark on` will enable the tracking of new enemy player targets. Existing markers are unaffected. The add-on is on by default.