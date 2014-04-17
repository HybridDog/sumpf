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
