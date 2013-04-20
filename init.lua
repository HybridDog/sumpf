--[[
sumpf
Textures from: gimp, gamiano.de
sounds: GPL
I looked at snow mod for mapgen and
at the jungletree mod for birches.
]]

minetest.register_node("sumpf:gras", {
	description = "Swamp Grass",
	tile_images = {"sumpfgrass.png"},
	inventory_image = "sumpfgrass.png",
	drawtype = "plantlike",
	paramtype = "light",
	selection_box = {type = "fixed",fixed = {-1/3, -1/2, -1/3, 1/3, -1/5, 1/3},},
	buildable_to = true,
	walkable = false,
	groups = {snappy=3,flammable=2},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("sumpf:junglestone", {
	description = "Swamp Stone",
	tile_images = {"sumpfstein.png"},
	groups = {cracky=3},
	legacy_mineral = true,
	sounds = SOUND,
})

minetest.register_node("sumpf:peat", {
	description = "Peat",
	tiles = {"sumpf_peat.png"},
	groups = {crumbly=3, falling_node=1, sand=1},
	sounds = default.node_sound_sand_defaults({
		dig = {name="sumpf", gain=0.4},
		footstep = {name="sumpf", gain=0.4},
	}),
})

minetest.register_node("sumpf:kohle", {
	description = "Coal Ore",
	tiles = {"sumpfstein.png^default_mineral_coal.png"},
	groups = {cracky=3},
	drop = 'default:coal_lump',
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("sumpf:eisen", {
	description = "Iron Ore",
	tiles = {"sumpfstein.png^default_mineral_iron.png"},
	groups = {cracky=3},
	drop = 'default:iron_lump',
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("sumpf:sumpf", {
	description = "Swamp",
	tiles = {"sumpf.png"},
	groups = {crumbly=3},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="sumpf", gain=0.4},
	}),
})

minetest.register_node("sumpf:sumpf2", {
	tiles = {"sumpf.png","sumpfstein.png","sumpfstein.png^sumpf2.png"},
	groups = {cracky=3},
	drop = "sumpf:junglestone",
	sounds = default.node_sound_stone_defaults({
		footstep = {name="sumpf", gain=0.4},
	}),
})

minetest.register_node("sumpf:dirtywater_flowing", {
	drawtype = "flowingliquid",
	tiles = {"default_water.png"},
	special_tiles = {
		{name="sumpfwasser2.png", backface_culling=false,	animation={type="vertical_frames", aspect_w=32, aspect_h=32, length=1}},
		{name="sumpfwasser2.png", backface_culling=true,	animation={type="vertical_frames", aspect_w=32, aspect_h=32, length=1}},},
	alpha = WATER_ALPHA,
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	liquidtype = "flowing",
	liquid_alternative_flowing = "sumpf:dirtywater_flowing",
	liquid_alternative_source = "sumpf:dirtywater_source",
	liquid_viscosity = WATER_VISC,
	post_effect_color = {a=64, r=70, g=90, b=120},
	groups = {water=3, liquid=3, puts_out_fire=1, not_in_creative_inventory=1},
})

minetest.register_node("sumpf:dirtywater_source", {
	description = "Swampwater",
	drawtype = "liquid",
	tiles = {{name="sumpfwasser.png", animation={type="vertical_frames", aspect_w=32, aspect_h=32, length=1.0}}},
	special_tiles = {{name="sumpfwasser.png", backface_culling=false},},
	alpha = WATER_ALPHA,
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	liquidtype = "source",
	liquid_alternative_flowing = "sumpf:dirtywater_flowing",
	liquid_alternative_source = "sumpf:dirtywater_source",
	liquid_viscosity = WATER_VISC,
	post_effect_color = {a=64, r=70, g=90, b=120},
	groups = {water=3, liquid=3, puts_out_fire=1},
})

sumpf = {}
dofile(minetest.get_modpath("sumpf").."/settings.lua")
dofile(minetest.get_modpath("sumpf") .. "/birke.lua")
if sumpf.enable_mapgen then
	dofile(minetest.get_modpath("sumpf") .. "/mapgen.lua")
end

print("[Swamps] {13.01.12} Loaded!") 
