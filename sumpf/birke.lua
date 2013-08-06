minetest.register_node("sumpf:sapling", {
	description = "Birch",	
	drawtype = "plantlike",	
	tiles = {"birke_sapling.png"},	
	inventory_image = "birke_sapling.png",	
	wield_image = "birke_sapling.png",	
	paramtype = "light",	
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


local function tree_branch(ignore, area, nodes, pos, dir)	
	local num = 1
	local tab = {}

	if dir ~= 0 then
		minetest.env:set_node(pos, {name="sumpf:tree_horizontal", param2=dir})
	end
	for i = math.random(2), -math.random(2), -1 do		
		for k = math.random(2), -math.random(2), -1 do
			local p = {x=pos.x+i, y=pos.y, z=pos.z+k}
			local n = minetest.env:get_node(p)
			if (n.name=="air")
			and nodes[area:index(p.x, p.y, p.z)] == ignore then	
				tab[num] = {2, p.x, p.y, p.z}
				num = num+1
			end
			local chance = math.abs(i+k)
			if (chance < 1) then	
				p = {x=pos.x+i, y=pos.y+1, z=pos.z+k}
				n = minetest.env:get_node(p)	
				if (n.name=="air")
				and nodes[area:index(p.x, p.y, p.z)] == ignore then
					tab[num] = {2, p.x, p.y, p.z}
					num = num+1
				end
			end
		end	
	end
	if dir == 0 then
		tab[num] = {1, pos.x, pos.y, pos.z}
		num = num+1
	end
	return tab
end

function mache_birke(pos, generated)	

	local t1 = os.clock()
	local manip = minetest.get_voxel_manip()
	local vwidth = 7
	local vheight = 13
	local emerged_pos1, emerged_pos2 = manip:read_from_map({x=pos.x-vwidth, y=pos.y-3, z=pos.z-vwidth},
		{x=pos.x+vwidth, y=pos.y+vheight, z=pos.z+vwidth})
	local area = VoxelArea:new({MinEdge=emerged_pos1, MaxEdge=emerged_pos2})

	local nodes = {}
	local ignore = minetest.get_content_id("ignore")
	for i = 1, sumpf_get_volume(emerged_pos1, emerged_pos2) do
		nodes[i] = ignore
	end

	local c_mossytree = minetest.get_content_id("sumpf:mossytree")
	local c_tree = minetest.get_content_id("sumpf:tree")
	local c_tree_horizontal = minetest.get_content_id("sumpf:tree_horizontal")
	local c_leaves = minetest.get_content_id("sumpf:leaves")
	local ndtable = {c_tree_horizontal, c_leaves}

	nodes[area:index(pos.x, pos.y, pos.z)] = c_mossytree
	local height = 3 + math.random(2)
	for i = height, 1, -1 do
		local p = {x=pos.x, y=pos.y+i, z=pos.z}
		nodes[area:index(p.x, p.y, p.z)] = c_tree
		if (math.sin(i/height*i) < 0.2 and i > 3 and math.random(0,2) < 1.5) then
			branch_pos = {x=pos.x+math.random(0,1), y=pos.y+i, z=pos.z-math.random(0,1)}
			for _,nds in ipairs(area, nodes, tree_branch(ignore, area, nodes, branch_pos, math.random(0,1))) do
				nodes[area:index(nds[2], nds[3], nds[4])] = ndtable[nds[1] ]
			end
		end
	end
	local branches = {
		tree_branch(ignore, area, nodes, {x=pos.x, y=pos.y+height+math.random(0, 1),z=pos.z}, math.random(0,1)),
		tree_branch(ignore, area, nodes, {x=pos.x+1, y=pos.y+height-math.random(2), z=pos.z,}, 1),
		tree_branch(ignore, area, nodes, {x=pos.x-1, y=pos.y+height-math.random(2), z=pos.z}, 1),
		tree_branch(ignore, area, nodes, {x=pos.x, y=pos.y+height-math.random(2), z=pos.z+1}, 0),
		tree_branch(ignore, area, nodes, {x=pos.x, y=pos.y+height-math.random(2), z=pos.z-1}, 0)
	}
	for _,tbr in ipairs(branches) do
		for _,nds in ipairs(tbr) do
			nodes[area:index(nds[2], nds[3], nds[4])] = ndtable[nds[1] ]
		end
	end
	manip:set_data(nodes)
	manip:write_to_map()
	if not generated then	--info
		if sumpf_info_birch then
			print(string.format("[sumpf] a birch grew at ("..pos.x.."|"..pos.y.."|"..pos.z..") in: %.2fms", (os.clock() - t1) * 1000))
			local t1 = os.clock()
			manip:update_map()
			print(string.format("[sumpf] map updated in: %.2fms", (os.clock() - t1) * 1000))
		else
			manip:update_map()
		end
	end
end

--[[
local function add_tree_branch(pos, dir)	
	minetest.env:set_node(pos, {name="sumpf:tree_horizontal", param2=dir})
	for i = math.random(2), -math.random(2), -1 do		
		for k = math.random(2), -math.random(2), -1 do
			local p = {x=pos.x+i, y=pos.y, z=pos.z+k}
			local n = minetest.env:get_node(p)
			if (n.name=="air") then	
				minetest.env:add_node(p, {name="sumpf:leaves"})
			end
			local chance = math.abs(i+k)
			if (chance < 1) then	
				p = {x=pos.x+i, y=pos.y+1, z=pos.z+k}	
				n = minetest.env:get_node(p)	
				if (n.name=="air") then		
					minetest.env:add_node(p, {name="sumpf:leaves"})
				end
			end
		end	
	end
end

function mache_birke(pos)	
	local t1 = os.clock()
	minetest.env:add_node(pos, {name="sumpf:mossytree"})
	local height = 3 + math.random(2)
	for i = height, 1, -1 do
		local p = {x=pos.x, y=pos.y+i, z=pos.z}
		minetest.env:add_node(p, {name="sumpf:tree"})		
		if (math.sin(i/height*i) < 0.2 and i > 3 and math.random(0,2) < 1.5) then		
			branch_pos = {x=pos.x+math.random(0,1), y=pos.y+i, z=pos.z-math.random(0,1)}		
			add_tree_branch(branch_pos, math.random(1,2))	
		end
	end
	add_tree_branch({x=pos.x, y=pos.y+height+math.random(0, 1),z=pos.z}, math.random(1,2))	
	add_tree_branch({x=pos.x+1, y=pos.y+height-math.random(2), z=pos.z,}, 1)		
	add_tree_branch({x=pos.x-1, y=pos.y+height-math.random(2), z=pos.z}, 1)		
	add_tree_branch({x=pos.x, y=pos.y+height-math.random(2), z=pos.z+1}, 2)		
	add_tree_branch({x=pos.x, y=pos.y+height-math.random(2), z=pos.z-1}, 2)		
	if sumpf_info_birch then
		print(string.format("[sumpf] a birch grew at ("..pos.x.."|"..pos.y.."|"..pos.z..") in: %.2fms", (os.clock() - t1) * 1000))
	end
end]]

minetest.register_abm({	
	nodenames = {"sumpf:sapling"},	
	neighbors = {"group:soil"},
	interval = 20,	
	chance = 8,	
	action = function(pos)	
		if minetest.get_item_group(minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z}).name, "soil") ~= 1
		or not minetest.get_node_light(pos) then
			return
		end
		if minetest.env:get_node_light(pos, nil) > 7 then
			mache_birke(pos)
		end
	end
})

if sumpf.spawn_plants
and minetest.get_modpath("habitat") then
	habitat:generate("sumpf:sapling", {"default:dirt_with_grass"},
		minp, maxp, 20, 25, 100, 500, {"default:water_source"},30,{"default:desert_sand"})
	habitat:generate("sumpf:gras", {"default:dirt_with_grass"},
		minp, maxp, 0, 25, 90, 100, {"default:water_source"},30,{"default:desert_sand"})
end
