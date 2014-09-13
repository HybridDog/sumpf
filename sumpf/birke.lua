local sumpf_birch_seed = 113

function sumpf_birch_get_random(pos)
	return PseudoRandom(math.abs(pos.x+pos.y*3+pos.z*5)+sumpf_birch_seed)
end

minetest.register_node("sumpf:sapling", {
	description = "Birch",	
	drawtype = "plantlike",	
	tiles = {"birke_sapling.png"},	
	inventory_image = "birke_sapling.png",	
	wield_image = "birke_sapling.png",	
	paramtype = "light",	
	waving = 1,
	walkable = false,	
	groups = {snappy=2,dig_immediate=3,flammable=2,attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
	furnace_burntime = 9,
})

minetest.register_node("sumpf:birk", {
	tiles = {"birke_mossytree.png"},	
	inventory_image = "birke_mossytree.png^birke_sapling.png",	
	paramtype = "light",	
	stack_max = 1024,
	groups = {snappy=2,dig_immediate=3},
	sounds = default.node_sound_leaves_defaults(),
	on_construct = function(pos)
		mache_birke(pos)
	end,
--[[	on_use = function()
		mache_birke(pos)
	end,]]
})

minetest.register_node("sumpf:leaves", {
	description = "Birch Leaves",
	drawtype = "glasslike",
	tiles = {"birke_leaves.png"},
	paramtype = "light",
	groups = {snappy=3, leafdecay=3, flammable=2, leaves=1},
	drop = {
		max_items = 1,
		items = {
			{
				items = {'sumpf:sapling'},
				rarity = 20,
			},
			{
				items = {'sumpf:leaves'},
				rarity = 20,
			}
		}
	},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("sumpf:tree", {
	description = "Birch Trunk",	
	tiles = {"birke_tree_top.png",	"birke_tree_top.png",	"birke_tree.png"},	
	groups = {tree=1,snappy=1,choppy=2,oddly_breakable_by_hand=1,flammable=2},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("sumpf:tree_horizontal", {
	description = "Horizontal Birch Trunk",	
	tiles = {"birke_tree.png",	"birke_tree.png",	"birke_tree.png^[transformR90", --transform is useful
			"birke_tree.png^[transformR90", "birke_tree_top.png", "birke_tree_top.png"},	
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	groups = {tree=1,snappy=1,choppy=2,oddly_breakable_by_hand=1,flammable=2},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("sumpf:mossytree", {
	description = "Mossy Birch Trunk",	
	tiles = {"birke_tree_top.png",	"sumpf.png",	"birke_mossytree.png"},	
	groups = {tree=1,snappy=1,choppy=2,oddly_breakable_by_hand=1,flammable=2},
	sounds = default.node_sound_wood_defaults(),
})

local function tree_crafts(input)
	local hori = input.."_horizontal"

	minetest.register_craft({
		output = 'default:wood 4',
		recipe = {{input},}
	})

	minetest.register_craft({
		output = 'default:wood 4',
		recipe = {{hori},}
	})

	minetest.register_craft({
		output = hori.." 2",
		recipe = {{input, input},}
	})

	minetest.register_craft({
		output = input.." 2",
		recipe = {{hori},
				  {hori}}
	})
end

tree_crafts("sumpf:tree")

minetest.register_craft({
	output = 'default:wood 4',
	recipe = {{"sumpf:mossytree"},}
})

function sumpf_get_volume(pos1, pos2)
	return (pos2.x - pos1.x + 1) * (pos2.y - pos1.y + 1) * (pos2.z - pos1.z + 1)
end

sumpf_c_air = minetest.get_content_id("air")
sumpf_c_mossytree = minetest.get_content_id("sumpf:mossytree")
sumpf_c_tree = minetest.get_content_id("sumpf:tree")
sumpf_c_tree_horizontal = minetest.get_content_id("sumpf:tree_horizontal")
sumpf_c_leaves = minetest.get_content_id("sumpf:leaves")
sumpf_ndtable = {sumpf_c_tree_horizontal, sumpf_c_leaves}


local area, nodes, param2s, sumpf_birch_pr

local function tree_branch(pos, dir)	

	local p_pos = area:indexp(pos)
	nodes[p_pos] = sumpf_c_tree_horizontal
	if dir ~= 0 then
		param2s[p_pos] = 1
	end
	for i = sumpf_birch_pr:next(1,2), -sumpf_birch_pr:next(1,2), -1 do		
		for k = sumpf_birch_pr:next(1,2), -sumpf_birch_pr:next(1,2), -1 do
			local p_p = area:index(pos.x+i, pos.y, pos.z+k)
			if nodes[p_p] == sumpf_c_air then
				nodes[p_p] = sumpf_c_leaves
			end
			local chance = math.abs(i+k)
			if (chance < 1) then	
				local p_p = area:index(pos.x+i, pos.y+1, pos.z+k)
				if nodes[p_p] == sumpf_c_air then
					nodes[p_p] = sumpf_c_leaves
				end
			end
		end	
	end
end

function mache_birke(pos, generated)	

	local t1 = os.clock()
	local manip = minetest.get_voxel_manip()
	local vwidth = 7
	local vheight = 13
	local emerged_pos1, emerged_pos2 = manip:read_from_map({x=pos.x-vwidth, y=pos.y-3, z=pos.z-vwidth},
		{x=pos.x+vwidth, y=pos.y+vheight, z=pos.z+vwidth})
	area = VoxelArea:new({MinEdge=emerged_pos1, MaxEdge=emerged_pos2})
	nodes = manip:get_data()
	param2s = manip:get_param2_data() 

	sumpf_birch_pr = sumpf_birch_get_random(pos)

	nodes[area:index(pos.x, pos.y, pos.z)] = sumpf_c_mossytree
	local height = 3 + sumpf_birch_pr:next(1,2)
	for i = height, 1, -1 do
		local p = {x=pos.x, y=pos.y+i, z=pos.z}
		nodes[area:index(p.x, p.y, p.z)] = sumpf_c_tree
		if (math.sin(i/height*i) < 0.2 and i > 3 and sumpf_birch_pr:next(0,2) < 1.5) then
			branch_pos = {x=pos.x+sumpf_birch_pr:next(0,1), y=pos.y+i, z=pos.z-sumpf_birch_pr:next(0,1)}
			tree_branch(branch_pos, sumpf_birch_pr:next(0,1))
		end
	end
	tree_branch({x=pos.x, y=pos.y+height+sumpf_birch_pr:next(0,1),z=pos.z}, sumpf_birch_pr:next(0,1))
	tree_branch({x=pos.x+1, y=pos.y+height-sumpf_birch_pr:next(1,2), z=pos.z,}, 1)
	tree_branch({x=pos.x-1, y=pos.y+height-sumpf_birch_pr:next(1,2), z=pos.z}, 1)
	tree_branch({x=pos.x, y=pos.y+height-sumpf_birch_pr:next(1,2), z=pos.z+1}, 0)
	tree_branch({x=pos.x, y=pos.y+height-sumpf_birch_pr:next(1,2), z=pos.z-1}, 0)

	manip:set_data(nodes)
	manip:set_param2_data(param2s)
	manip:write_to_map()
	local spam = 2
	if generated then
		spam = 3
	end
	sumpf.inform("a birch grew at ("..pos.x.."|"..pos.y.."|"..pos.z..")", spam, t1)
	if not generated then	--info
		local t1 = os.clock()
		manip:update_map()
		sumpf.inform("map updated", spam, t1)
	end
end

minetest.register_abm({	
	nodenames = {"sumpf:sapling"},	
	neighbors = {"group:soil"},
	interval = 20,	
	chance = 8,	
	action = function(pos)
		if sumpf.tree_allowed(pos, 8) then
			mache_birke(pos)
		end
	end
})

if sumpf.spawn_plants
and habitat then
	habitat:generate("sumpf:sapling", {"default:dirt_with_grass"},
		minp, maxp, 20, 25, 100, 500, {"default:water_source"},30,{"default:desert_sand"})
	habitat:generate("sumpf:gras", {"default:dirt_with_grass"},
		minp, maxp, 0, 25, 90, 100, {"default:water_source"},30,{"default:desert_sand"})
end
