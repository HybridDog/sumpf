minetest.register_node("sumpf:sapling", {
	description = "Birch",	
	drawtype = "plantlike",	
	tiles = {"birke_sapling.png"},	
	inventory_image = "birke_sapling.png",	
	wield_image = "birke_sapling.png",	
	paramtype = "light",	
	walkable = false,	
	groups = {snappy=2,dig_immediate=3,flammable=2},
})
minetest.register_node("sumpf:birk", {
	tiles = {"birke_mossytree.png"},	
	inventory_image = "birke_mossytree.png^birke_sapling.png",	
	paramtype = "light",	
	stack_max = 1024,
	groups = {snappy=2,dig_immediate=3},
	on_construct = function(pos)
		mache_birke(pos)
	end,
})

minetest.register_node("sumpf:leaves", {
	description = "Birch Leaves",
	drawtype = "glasslike",
	tiles = {"birke_leaves.png"},
	paramtype = "light",
	groups = {snappy=3, leafdecay=3, flammable=2},
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
})

minetest.register_node("sumpf:tree_horizontal", {
	description = "Horizontal Birch Trunk",	
	tiles = {"birke_tree.png",	"birke_tree.png",	"birke_tree.png^[transformR90", --transform is useful
			"birke_tree.png^[transformR90", "birke_tree_top.png", "birke_tree_top.png"},	
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	groups = {tree=1,snappy=1,choppy=2,oddly_breakable_by_hand=1,flammable=2},
})

minetest.register_node("sumpf:mossytree", {
	description = "Mossy Birch Trunk",	
	tiles = {"birke_tree_top.png",	"sumpf.png",	"birke_mossytree.png"},	
	groups = {tree=1,snappy=1,choppy=2,oddly_breakable_by_hand=1,flammable=2},
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
end

minetest.register_abm({	
	nodenames = {"sumpf:sapling"},	
	interval = 10,	
	chance = 6,	
	action = function(pos)	
		mache_birke(pos)
	end
,})

--function anti_generate(node, surfaces, minp, maxp, height_min, height_max, spread, habitat_size, habitat_nodes)
--habitat:generate("sumpf:birk", {"default:dirt_with_grass"}, minp, maxp, 20, 25, 100, 500, {"default:water_source"},30,{"default:desert_sand"})
