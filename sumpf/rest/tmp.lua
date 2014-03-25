local function fix_light(minp, maxp)
	local manip = minetest.get_voxel_manip()
	local emerged_pos1, emerged_pos2 = manip:read_from_map(minp, maxp)
	area = VoxelArea:new({MinEdge=emerged_pos1, MaxEdge=emerged_pos2})
	nodes = manip:get_data()

	manip:set_data(nodes)
	manip:write_to_map()
	manip:update_map()
end

local function table_contains(v, t)
	for _,i in ipairs(t) do
		if v == i then
			return true
		end
	end
	return false
end

local function pstost(minp, maxp)
	return "x=["..minp.x.."; "..maxp.x.."]; y=["..minp.y.."; "..maxp.y.."]; z=["..minp.z.."; "..maxp.z.."]"
end

--[[
param = {
	description = string,
	usual_stuff = datatab,
	ground = datatab,
	miny = int,
	maxy = int,
	settings = {
		always_generate = bool,
		smooth = bool,
		plants_enabled = bool,
		mapgen_rarity = float,
		mapgen_size = int,
	},
	generate_ground = function(pos, area, data) --data,
	generate_plants = function(pos, area, data) --data, (structp),
	make_structures = function(tab),
	structures = bool,
}
]]

function add_biome(param)

local config = param.settings

local smooth = config.smooth
local plants_enabled = config.enable_plants

local rarity = config.mapgen_rarity
local size = config.mapgen_size

local nosmooth_rarity = -(rarity/50)+1
local perlin_scale = size*100/rarity
local smooth_rarity_full = nosmooth_rarity+perlin_scale/(20*size)
local smooth_rarity_ran = nosmooth_rarity-perlin_scale/(40*size)
local smooth_rarity_dif = (smooth_rarity_full-smooth_rarity_ran)*100-1

minetest.register_on_generated(function(minp, maxp, seed)

	--avoid calculating perlin noises for unneeded places
	if maxp.y <= param.miny
	or minp.y >= param.maxy then
		return
	end

	local x0,z0,x1,z1 = minp.x,minp.z,maxp.x,maxp.z	-- Assume X and Z lengths are equal
	local perlin1 = minetest.get_perlin(config.seeddif, 3, 0.5, perlin_scale)	--Get map specific perlin

	--[[if not (perlin1:get2d({x=x0, y=z0}) > 0.53) and not (perlin1:get2d({x=x1, y=z1}) > 0.53)
	and not (perlin1:get2d({x=x0, y=z1}) > 0.53) and not (perlin1:get2d({x=x1, y=z0}) > 0.53)
	and not (perlin1:get2d({x=(x1-x0)/2, y=(z1-z0)/2}) > 0.53) then]]

	if not config.always_generate
	and not ( perlin1:get2d( {x=x0, y=z0} ) > nosmooth_rarity ) 					--top left
	and not ( perlin1:get2d( { x = x0 + ( (x1-x0)/2), y=z0 } ) > nosmooth_rarity )--top middle
	and not (perlin1:get2d({x=x1, y=z1}) > nosmooth_rarity) 						--bottom right
	and not (perlin1:get2d({x=x1, y=z0+((z1-z0)/2)}) > nosmooth_rarity) 			--right middle
	and not (perlin1:get2d({x=x0, y=z1}) > nosmooth_rarity)  						--bottom left
	and not (perlin1:get2d({x=x1, y=z0}) > nosmooth_rarity)						--top right
	and not (perlin1:get2d({x=x0+((x1-x0)/2), y=z1}) > nosmooth_rarity) 			--left middle
	and not (perlin1:get2d({x=(x1-x0)/2, y=(z1-z0)/2}) > nosmooth_rarity) 			--middle
	and not (perlin1:get2d({x=x0, y=z1+((z1-z0)/2)}) > nosmooth_rarity) then		--bottom middle
		return
	end

	local t1 = os.clock()

	local divs = maxp.x-minp.x
	pr = PseudoRandom(seed+68)

		--Information:
	sumpf.inform("tries to generate "..param.description.." at: "..pstost(minp, maxp), 2)

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local data = vm:get_data()
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}

	for p_pos in area:iterp(minp, maxp) do
		local d_p_pos = data[p_pos]
		for _,nam in ipairs(param.unwanted_nodes) do			
			if d_p_pos == nam then
				data[p_pos] = c.air
				break
			end
		end
	end

	local num = 1
	local tab = {}

	for j=0,divs do
		for i=0,divs do
			local x,z = x0+i,z0+j

			--Check if we are in a "Swamp biome"
			local in_biome = false
			local test = perlin1:get2d({x=x, y=z})
			--smooth mapgen
			if config.always_generate then
				in_biome = true
			elseif smooth
			and (
				test > smooth_rarity_full
				or (
					test > smooth_rarity_ran
					and pr:next(0,smooth_rarity_dif) > (smooth_rarity_full - test) * 100
				)
			) then
				in_biome = true
			elseif (not smooth)
			and test > nosmooth_rarity then
				in_biome = true
			end

			if in_biome then

				local usual_stuff = param.usual_stuff
				if usual_stuff then
					for b = minp.y,maxp.y,1 do	--remove usual stuff
						local p_pos = area:index(x, b, z)
						local d_p_pos = data[p_pos]
						for _,nam in ipairs(usual_stuff) do			
							if d_p_pos == nam then
								data[p_pos] = c.air
								break
							end
						end
					end
				end

				local ground_y = nil --get ground_y:
--				for y=maxp.y,0,-1 do
				for y=maxp.y,-5,-1 do	--because of the caves
					if table_contains(data[area:index(x, y, z)], param.ground) then
						ground_y = y
						break
					end
				end

				if ground_y then
					local pos = {x=x, y=ground_y, z=z}
					data = param.generate_ground(pos, area, data)
					if plants_enabled then
						local structp = nil
						data, structp = param.generate_plants(pos, area, data)
						if structp then
							tab[num] = structp
							num = num+1
						end
					end
				end
			end
		end
	end
	vm:set_data(data)
	vm:write_to_map()
	sumpf.inform("ground finished", 2, t1)

	if param.structures then
		local t2 = os.clock()
		param.make_structures(tab)
		sumpf.inform("structures added", 2, t2)
	end

	local t2 = os.clock()
	fix_light(minp, maxp)
	sumpf.inform("shadows added", 2, t2)

	sumpf.inform("done", 1, t1)
end)
end
