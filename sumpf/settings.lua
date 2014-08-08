--This file contains configuration options for swamp mod.

sumpf.enable_mapgen = true

--Always generate swamps (causes some lag)
sumpf.always_generate = false

--Enables smooth transition of biomes.
sumpf.smooth = true

--rarity in %
sumpf.mapgen_rarity = 4

--size of the generated... (has an effect to the rarity, too)
sumpf.mapgen_size = 100

--approximate size of smooth transitions
sumpf.smooth_trans_size = 4

--Disable for testing
sumpf.enable_plants = true

--Enables swampwater - it doesn't work correctly yet.
sumpf.swampwater = false

sumpf.wet_beaches = false --currently the plants would be generated on this water

--habitat stuff (no vm yet)
sumpf.spawn_plants = true

--says some information.
sumpf.info = true

--informs the players, too
sumpf.inform_all = minetest.is_singleplayer()

--1:<a bit of information> 2:<acceptable amount of information> 3:<lots of text>
sumpf.max_spam = 2
