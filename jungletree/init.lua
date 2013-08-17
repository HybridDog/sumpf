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
	is_ground_content = true,	
	groups = {tree=1,snappy=1,choppy=2,oddly_breakable_by_hand=1,flammable=2},
}) --]]

--minetest.register_alias("jungletree:tree", "default:jungletree")


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
				tree_branch({x=pos.x+1, y=pos.y+i, z=pos.z+1})
				tree_branch({x=pos.x+2, y=pos.y+i, z=pos.z-1})

				tree_branch({x=pos.x, y=pos.y+i, z=pos.z-2})
				tree_branch({x=pos.x-1, y=pos.y+i, z=pos.z})
				tree_branch({x=pos.x+1, y=pos.y+i, z=pos.z+2})
				tree_branch({x=pos.x+3, y=pos.y+i, z=pos.z-1})
				tree_branch({x=pos.x, y=pos.y+i, z=pos.z-3})

				tree_branch({x=pos.x-2, y=pos.y+i, z=pos.z})
				tree_branch({x=pos.x+1, y=pos.y+i, z=pos.z})
				tree_branch({x=pos.x+1, y=pos.y+i, z=pos.z-1})
				tree_branch({x=pos.x, y=pos.y+i, z=pos.z-1})
				tree_branch({x=pos.x, y=pos.y+i, z=pos.z})

			else
				nodes[area:index(pos.x+1, pos.y+i, pos.z)] = jungletree_c_jungletree
				nodes[area:index(pos.x+1, pos.y+i, pos.z-1)] = jungletree_c_jungletree
				nodes[area:index(pos.x, pos.y+i, pos.z-1)] = jungletree_c_jungletree
				nodes[area:index(pos.x, pos.y+i, pos.z)] = jungletree_c_jungletree

			end
		end
	end

	manip:set_data(nodes)
	manip:write_to_map()
	if not generated then	--info
		if sumpf_info_jg then
			print(string.format("[sumpf] a jungletree grew at ("..pos.x.."|"..pos.y.."|"..pos.z..") in: %.2fs", os.clock() - t1))
			local t1 = os.clock()
			manip:update_map()
			print(string.format("[sumpf] map updated in: %.2fs", os.clock() - t1))
		else
			manip:update_map()
		end
	end
--	area, nodes, jungletree_pr = nil
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
	
	minetest.env:add_node(pos, {name="default:jungletree"})
	for i = math.random(2), -math.random(2), -1 do
		for k =math.random(2), -math.random(2), -1 do
			local p = {x=pos.x+i, y=pos.y, z=pos.z+k}
			local n = minetest.env:get_node(p)
			if (n.name=="air") then
				minetest.env:add_node(p, {name=leave})
			end
			local chance = math.abs(i+k)
			if (chance < 1) then
				p = {x=pos.x+i, y=pos.y+1, z=pos.z+k}
				n = minetest.env:get_node(p)
				if (n.name=="air") then
					minetest.env:add_node(p, {name=leave})
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
				minetest.env:add_node(p, {name="default:jungletree"})
				if i == height then
					add_tree_branch({x=pos.x, y=pos.y+height+math.random(0, 1), z=pos.z})
					add_tree_branch({x=pos.x+1, y=pos.y+i-math.random(2), z=pos.z})
					add_tree_branch({x=pos.x-1, y=pos.y+i-math.random(2), z=pos.z})

					add_tree_branch({x=pos.x, y=pos.y+i-math.random(2), z=pos.z+1})
					add_tree_branch({x=pos.x, y=pos.y+i-math.random(2), z=pos.z-1})
				end
				if height <= 0 then
					minetest.env:add_node({x=pos.x+1, y=pos.y+i-math.random(2), z=pos.z}, {name="default:jungletree"})
					minetest.env:add_node({x=pos.x, y=pos.y+i-math.random(2), z=pos.z+1}, {name="default:jungletree"})
					minetest.env:add_node({x=pos.x-1, y=pos.y+i-math.random(2), z=pos.z}, {name="default:jungletree"})
					minetest.env:add_node({x=pos.x, y=pos.y+i-math.random(2), z=pos.z-1}, {name="default:jungletree"})
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
					minetest.env:add_node({x=pos.x+1, y=pos.y+i, z=pos.z+1}, {name="default:jungletree"})
					minetest.env:add_node({x=pos.x+2, y=pos.y+i, z=pos.z-1}, {name="default:jungletree"})
					minetest.env:add_node({x=pos.x, y=pos.y+i, z=pos.z-2}, {name="default:jungletree"})
					minetest.env:add_node({x=pos.x-1, y=pos.y+i, z=pos.z}, {name="default:jungletree"})
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
					minetest.env:add_node({x=pos.x+1, y=pos.y+i, z=pos.z}, {name="default:jungletree"})
					minetest.env:add_node({x=pos.x+1, y=pos.y+i, z=pos.z-1}, {name="default:jungletree"})
					minetest.env:add_node({x=pos.x, y=pos.y+i, z=pos.z-1}, {name="default:jungletree"})
					minetest.env:add_node({x=pos.x, y=pos.y+i, z=pos.z}, {name="default:jungletree"})
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
		if minetest.get_item_group(minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z}).name, "soil") ~= 1
		or not minetest.get_node_light(pos) then
			return
		end
		if minetest.env:get_node_light(pos, nil) > 6 then
			sumpf_make_jungletree(pos)
		end
	end
})

--very old mod compatible
--minetest.register_alias("jungletree:leaves", "jungletree:leaves_green")

print("[Jungletree] Loaded!")
