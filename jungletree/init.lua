local leaves = {"green","yellow","red"}
local jungletree_seed = 112

function jungletree_get_random(pos)
	return PseudoRandom(math.abs(pos.x+pos.y*3+pos.z*5)+jungletree_seed)
end

minetest.register_node("jungletree:sapling", {
	description = "Jungle Tree Sapling",	
	drawtype = "plantlike",	
	visual_scale = 1.0,	
	tiles = {"jungletree_sapling.png"},	
	inventory_image = "jungletree_sapling.png",	
	wield_image = "default_sapling.png",	
	paramtype = "light",	
	walkable = false,	
	groups = {snappy=2,dig_immediate=3,flammable=2,attached_node=1},
	on_construct = function(pos)
		if minetest.setting_getbool("creative_mode") then
			sumpf_make_jungletree(pos)
		end
	end
})

--if minetest.setting_get("new_style_leaves") == true then
	--leavesimg = {"jungletree_leaves_trans.png"}
--else
	--leavesimg = {"jungletree_leaves.png"}
--end
--[[
local slvs = {
	description = "Jungle Tree Leaves",
	drawtype = "allfaces_optional",
	paramtype = "light",
	groups = {snappy=3, leafdecay=3, flammable=2, leaves=1},
	drop = {
		max_items = 1,
		items = {
			{
				-- player will get sapling with 1/20 chance
				items = {'jungletree:sapling'},
				rarity = 20,
			},
		}
	},
	sounds = default.node_sound_leaves_defaults(),
}
if plantlike_leaves then
	slvs.drawtype = "plantlike"
	slvs.visual_scale = math.sqrt(math.sqrt(2))
end

for color = 1, 3 do
	local leaf_name = "jungletree:leaves_"..leaves[color]
	slvs.tiles = {"jungletree_leaves_"..leaves[color]..".png"}
	slvs.drop["items"][2] = {
		-- player will get leaves only if he get no saplings,
		-- this is because max_items is 1
		items = {leaf_name},
	}
	if plantlike_leaves then
		slvs.inventory_image = minetest.inventorycube("jungletree_leaves_"..leaves[color]..".png")
	end
	minetest.register_node(leaf_name, slvs)
end
]]
local plantlike_leaves = 1
if plantlike_leaves then
for color = 1, 3 do
	local leave_name = "jungletree:leaves_"..leaves[color]
	minetest.register_node(leave_name, {
		description = "Jungle Tree Leaves",
		drawtype = "plantlike",
		visual_scale = math.sqrt(math.sqrt(2)),
		tiles = {"jungletree_leaves_"..leaves[color]..".png"},
		inventory_image = minetest.inventorycube("jungletree_leaves_"..leaves[color]..".png"),
		waving = 1, --warum 1?
		paramtype = "light",
		groups = {snappy=3, leafdecay=3, flammable=2, leaves=1},
		drop = {
			max_items = 1,
			items = {
				{

					-- player will get sapling with 1/20 chance
					items = {'jungletree:sapling'},
					rarity = 20,
				},
				{
					-- player will get leaves only if he get no saplings,

					-- this is because max_items is 1
					items = {leave_name},
				}
			}
		},

		sounds = default.node_sound_leaves_defaults(),
	})
end
else
for color = 1, 3 do
	local leave_name = "jungletree:leaves_"..leaves[color]
	minetest.register_node(leave_name, {
		description = "Jungle Tree Leaves",
		drawtype = "allfaces_optional",
		tiles = {"jungletree_leaves_"..leaves[color]..".png"},
		paramtype = "light",
		groups = {snappy=3, leafdecay=3, flammable=2, leaves=1},
		drop = {
			max_items = 1,
			items = {
				{

					-- player will get sapling with 1/20 chance
					items = {'jungletree:sapling'},
					rarity = 20,
				},
				{
					-- player will get leaves only if he get no saplings,

					-- this is because max_items is 1
					items = {leave_name},
				}
			}
		},

		sounds = default.node_sound_leaves_defaults(),
	})
end
end

jungletree_c_air = minetest.get_content_id("air")
jungletree_c_leaves_green = minetest.get_content_id("jungletree:leaves_green")
jungletree_c_leaves_red = minetest.get_content_id("jungletree:leaves_red")
jungletree_c_leaves_yellow = minetest.get_content_id("jungletree:leaves_yellow")
jungletree_c_jungletree = minetest.get_content_id("default:jungletree")
jungletree_ndtable = {jungletree_c_jungletree, jungletree_c_leaves_green, jungletree_c_leaves_red, jungletree_c_leaves_yellow}


--[[ minetest.register_node("jungletree:tree", {
	description = "Tree",	
	tiles = {"default_tree_top.png", 
	"default_tree_top.png",
	"jungletree_bark.png"},	
	groups = {tree=1,snappy=1,choppy=2,oddly_breakable_by_hand=1,flammable=2},
}) --]]

--minetest.register_alias("jungletree:tree", "default:jungletree")


local area, nodes, jungletree_pr

local function tree_branch(pos)

	--choose random leave
	--green leaves are more common
	local chance = jungletree_pr:next(1,5)
	local leaf = 2
	if (chance < 2) then
		leaf = jungletree_pr:next(2,4)
	end
	
	nodes[area:index(pos.x, pos.y, pos.z)] = jungletree_c_jungletree
	for i = jungletree_pr:next(1,2), -jungletree_pr:next(1,2), -1 do
		for k =jungletree_pr:next(1,2), -jungletree_pr:next(1,2), -1 do
			local p_p = area:index(pos.x+i, pos.y, pos.z+k)
			if nodes[p_p] == jungletree_c_air then
				nodes[p_p] = jungletree_ndtable[leaf]
			end
			local chance = math.abs(i+k)
			if (chance < 1) then
				local p_p = area:index(pos.x+i, pos.y+1, pos.z+k)
				if nodes[p_p] == jungletree_c_air then
					nodes[p_p] = jungletree_ndtable[leaf]
				end
			end
		end
	end
end


function sumpf_make_jungletree(pos, generated)

	local t1 = os.clock()
	local manip = minetest.get_voxel_manip()
	local vwidth = 7
	local vheight = 25
	local emerged_pos1, emerged_pos2 = manip:read_from_map({x=pos.x-vwidth, y=pos.y-3, z=pos.z-vwidth},
		{x=pos.x+vwidth, y=pos.y+vheight, z=pos.z+vwidth})
	area = VoxelArea:new({MinEdge=emerged_pos1, MaxEdge=emerged_pos2})
	nodes = manip:get_data()

	jungletree_pr = jungletree_get_random(pos)
	local height = 5 + jungletree_pr:next(1,15)
	if height < 10 then
		for i = height, -1, -1 do
			local p = {x=pos.x, y=pos.y+i, z=pos.z}
			nodes[area:index(pos.x, pos.y+i, pos.z)] = jungletree_c_jungletree
			if i == height then
				tree_branch({x=pos.x, y=pos.y+height+jungletree_pr:next(0,1), z=pos.z})
				tree_branch({x=pos.x, y=pos.y+height+jungletree_pr:next(0,1), z=pos.z})
				tree_branch({x=pos.x+1, y=pos.y+i-jungletree_pr:next(1,2), z=pos.z})
				tree_branch({x=pos.x-1, y=pos.y+i-jungletree_pr:next(1,2), z=pos.z})

				tree_branch({x=pos.x, y=pos.y+i-jungletree_pr:next(1,2), z=pos.z+1})
				tree_branch({x=pos.x, y=pos.y+i-jungletree_pr:next(1,2), z=pos.z-1})

			end
			if height <= 0 then

				nodes[area:index(pos.x+1, pos.y+i-jungletree_pr:next(1,2), pos.z)] = jungletree_c_jungletree
				nodes[area:index(pos.x, pos.y+i-jungletree_pr:next(1,2), pos.z+1)] = jungletree_c_jungletree
				nodes[area:index(pos.x-1, pos.y+i-jungletree_pr:next(1,2), pos.z)] = jungletree_c_jungletree
				nodes[area:index(pos.x, pos.y+i-jungletree_pr:next(1,2), pos.z-1)] = jungletree_c_jungletree
			end

			if (math.sin(i/height*i) < 0.2
			and i > 3
			and jungletree_pr:next(0,2) < 1.5) then
				tree_branch({x=pos.x+jungletree_pr:next(0,1), y=pos.y+i, z=pos.z-jungletree_pr:next(0,1)})
			end
		end

	else
		for i = height, -2, -1 do
			if (math.sin(i/height*i) < 0.2
			and i > 3
			and jungletree_pr:next(0,2) < 1.5) then
				tree_branch({x=pos.x+jungletree_pr:next(0,1), y=pos.y+i, z=pos.z-jungletree_pr:next(0,1)})

			end
			if i < jungletree_pr:next(0,1) then
				nodes[area:index(pos.x+1, pos.y+i, pos.z+1)] = jungletree_c_jungletree
				nodes[area:index(pos.x+2, pos.y+i, pos.z-1)] = jungletree_c_jungletree
				nodes[area:index(pos.x, pos.y+i, pos.z-2)] = jungletree_c_jungletree

				nodes[area:index(pos.x-1, pos.y+i, pos.z)] = jungletree_c_jungletree
			end
			if i == height then
				for _,p in ipairs({
					{x=pos.x+1, y=pos.y+i, z=pos.z+1},
					{x=pos.x+2, y=pos.y+i, z=pos.z-1},

					{x=pos.x, y=pos.y+i, z=pos.z-2},
					{x=pos.x-1, y=pos.y+i, z=pos.z},
					{x=pos.x+1, y=pos.y+i, z=pos.z+2},
					{x=pos.x+3, y=pos.y+i, z=pos.z-1},
					{x=pos.x, y=pos.y+i, z=pos.z-3},

					{x=pos.x-2, y=pos.y+i, z=pos.z},
					{x=pos.x+1, y=pos.y+i, z=pos.z},
					{x=pos.x+1, y=pos.y+i, z=pos.z-1},
					{x=pos.x, y=pos.y+i, z=pos.z-1},
					{x=pos.x, y=pos.y+i, z=pos.z},
				}) do
					tree_branch(p)
				end
			else
				for _,p in ipairs({
					{pos.x+1, pos.y+i, pos.z},
					{pos.x+1, pos.y+i, pos.z-1},
					{pos.x, pos.y+i, pos.z-1},
					{pos.x, pos.y+i, pos.z},
				}) do
					nodes[area:index(p[1], p[2], p[3])] = jungletree_c_jungletree
				end
			end
		end
	end

	manip:set_data(nodes)
	manip:write_to_map()
	local spam = 2
	if generated then
		spam = 3
	end
	sumpf.inform("a jungletree grew at ("..pos.x.."|"..pos.y.."|"..pos.z..")", spam, t1)
	if not generated then	--info
		local t1 = os.clock()
		manip:update_map()
		sumpf.inform("map updated", spam, t1)
	end
end

--[[
local function add_tree_branch(pos)

	--chooze random leave
	--green leaves are more common
	local chance = math.random(5)
	local leave = "jungletree:leaves_"..leaves[1]
	if (chance < 2) then
		leave = "jungletree:leaves_"..leaves[math.random(1,3)]
	end
	
	minetest.add_node(pos, {name="default:jungletree"})
	for i = math.random(2), -math.random(2), -1 do
		for k =math.random(2), -math.random(2), -1 do
			local p = {x=pos.x+i, y=pos.y, z=pos.z+k}
			local n = minetest.get_node(p)
			if (n.name=="air") then
				minetest.add_node(p, {name=leave})
			end
			local chance = math.abs(i+k)
			if (chance < 1) then
				p = {x=pos.x+i, y=pos.y+1, z=pos.z+k}
				n = minetest.get_node(p)
				if (n.name=="air") then
					minetest.add_node(p, {name=leave})
				end
			end
		end
	end
end

function sumpf_make_jungletree(pos)
		local t1 = os.clock()
		local height = 5 + math.random(15)
		if height < 10 then
			for i = height, -1, -1 do
				local p = {x=pos.x, y=pos.y+i, z=pos.z}
				minetest.add_node(p, {name="default:jungletree"})
				if i == height then
					add_tree_branch({x=pos.x, y=pos.y+height+math.random(0, 1), z=pos.z})
					add_tree_branch({x=pos.x+1, y=pos.y+i-math.random(2), z=pos.z})
					add_tree_branch({x=pos.x-1, y=pos.y+i-math.random(2), z=pos.z})

					add_tree_branch({x=pos.x, y=pos.y+i-math.random(2), z=pos.z+1})
					add_tree_branch({x=pos.x, y=pos.y+i-math.random(2), z=pos.z-1})
				end
				if height <= 0 then
					minetest.add_node({x=pos.x+1, y=pos.y+i-math.random(2), z=pos.z}, {name="default:jungletree"})
					minetest.add_node({x=pos.x, y=pos.y+i-math.random(2), z=pos.z+1}, {name="default:jungletree"})
					minetest.add_node({x=pos.x-1, y=pos.y+i-math.random(2), z=pos.z}, {name="default:jungletree"})
					minetest.add_node({x=pos.x, y=pos.y+i-math.random(2), z=pos.z-1}, {name="default:jungletree"})
				end
				if (math.sin(i/height*i) < 0.2 and i > 3 and math.random(0,2) < 1.5) then
					branch_pos = {x=pos.x+math.random(0,1), y=pos.y+i, z=pos.z-math.random(0,1)}
					add_tree_branch(branch_pos)
				end
			end
		else
			for i = height, -2, -1 do
				if (math.sin(i/height*i) < 0.2 and i > 3 and math.random(0,2) < 1.5) then
					branch_pos = {x=pos.x+math.random(0,1), y=pos.y+i, z=pos.z-math.random(0,1)}
					add_tree_branch(branch_pos)
				end
				if i < math.random(0,1) then
					minetest.add_node({x=pos.x+1, y=pos.y+i, z=pos.z+1}, {name="default:jungletree"})
					minetest.add_node({x=pos.x+2, y=pos.y+i, z=pos.z-1}, {name="default:jungletree"})
					minetest.add_node({x=pos.x, y=pos.y+i, z=pos.z-2}, {name="default:jungletree"})
					minetest.add_node({x=pos.x-1, y=pos.y+i, z=pos.z}, {name="default:jungletree"})
				end
				if i == height then
					add_tree_branch({x=pos.x+1, y=pos.y+i, z=pos.z+1})
					add_tree_branch({x=pos.x+2, y=pos.y+i, z=pos.z-1})
					add_tree_branch({x=pos.x, y=pos.y+i, z=pos.z-2})
					add_tree_branch({x=pos.x-1, y=pos.y+i, z=pos.z})
					add_tree_branch({x=pos.x+1, y=pos.y+i, z=pos.z+2})
					add_tree_branch({x=pos.x+3, y=pos.y+i, z=pos.z-1})
					add_tree_branch({x=pos.x, y=pos.y+i, z=pos.z-3})
					add_tree_branch({x=pos.x-2, y=pos.y+i, z=pos.z})
					add_tree_branch({x=pos.x+1, y=pos.y+i, z=pos.z})
					add_tree_branch({x=pos.x+1, y=pos.y+i, z=pos.z-1})
					add_tree_branch({x=pos.x, y=pos.y+i, z=pos.z-1})
					add_tree_branch({x=pos.x, y=pos.y+i, z=pos.z})
				else
					minetest.add_node({x=pos.x+1, y=pos.y+i, z=pos.z}, {name="default:jungletree"})
					minetest.add_node({x=pos.x+1, y=pos.y+i, z=pos.z-1}, {name="default:jungletree"})
					minetest.add_node({x=pos.x, y=pos.y+i, z=pos.z-1}, {name="default:jungletree"})
					minetest.add_node({x=pos.x, y=pos.y+i, z=pos.z}, {name="default:jungletree"})
				end
			end
		end
	if sumpf_info_jg then
		print(string.format("[sumpf] a jungletree grew at ("..pos.x.."|"..pos.y.."|"..pos.z..") in: %.2fms", (os.clock() - t1) * 1000))
	end
end]]
--[[minetest.register_abm({
	nodenames = {"jungletree:sapling"},
	interval = 1,
	chance = 1,
	action = function(pos)
		sumpf_make_jungletree(pos)
	end
})]]

minetest.register_abm({	
	nodenames = {"jungletree:sapling"},	
	neighbors = {"group:soil"},
	interval = 40,	
	chance = 5,	
	action = function(pos)	
		if sumpf.tree_allowed(pos, 7) then
			sumpf_make_jungletree(pos)
		end
	end
})

--very old mod compatible
--minetest.register_alias("jungletree:leaves", "jungletree:leaves_green")

print("[Jungletree] Loaded!")
