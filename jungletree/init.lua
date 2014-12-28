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

local plantlike_leaves = not minetest.setting_getbool("new_style_leaves")
local rt2 = math.sqrt(2)
local tex_sc = (1-(1/rt2))*100-4 --doesn't seem to work right
local tab = {
	description = "Jungle Tree Leaves",
	--is_ground_content = false,
	waving = 1, --warum 1?
	paramtype = "light",
	groups = {snappy=3, leafdecay=3, flammable=2, leaves=1},
	drop = {
		max_items = 1,
		items = {
			{
				items = {'jungletree:sapling'},
				rarity = 20,
			},
			{
				items = {},
			}
		}
	},
	sounds = default.node_sound_leaves_defaults(),
}
if plantlike_leaves then
	for color = 1, 3 do
		local leaf_name = "jungletree:leaves_"..leaves[color]
		tab.visual_scale = math.sqrt(rt2)
		tab.drawtype = "plantlike"
		tab.tiles = {"jungletree_leaves_"..leaves[color]..".png^[lowpart:"..tex_sc..":jungletree_invmat.png^[makealpha:255,126,126"}
		tab.inventory_image = minetest.inventorycube("jungletree_leaves_"..leaves[color]..".png")
		tab.drop.items[2].items[1] = leaf_name
		minetest.register_node(leaf_name, tab)
	end
else
	for color = 1, 3 do
		local leaf_name = "jungletree:leaves_"..leaves[color]
		tab.visual_scale = math.sqrt(rt2)
		tab.drawtype = "allfaces_optional"
		tab.tiles = {"jungletree_leaves_"..leaves[color]..".png"}
		tab.drop.items[2].items[1] = leaf_name
		minetest.register_node(leaf_name, tab)
	end
end

jungletree_c_air = minetest.get_content_id("air")
jungletree_c_leaves_green = minetest.get_content_id("jungletree:leaves_green")
jungletree_c_leaves_red = minetest.get_content_id("jungletree:leaves_red")
jungletree_c_leaves_yellow = minetest.get_content_id("jungletree:leaves_yellow")
jungletree_c_jungletree = minetest.get_content_id("default:jungletree")
jungletree_ndtable = {jungletree_c_jungletree, jungletree_c_leaves_green, jungletree_c_leaves_red, jungletree_c_leaves_yellow}


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

minetest.log("info", "[Jungletree] Loaded!")
