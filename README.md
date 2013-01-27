This mod adds swamps to minetest.  If you have got some ideas, tell them to me.

**Depends:** [jungletree, habitat,](http://minetest.net/forum/viewtopic.php?pid=39943#p39943) default  **License:** GPL *(sounds)*, WTFPL *(code, textures except birch)*

*Delete following lines of the jungletree mod:*[code]--function anti_generate(node, surfaces, minp, maxp, height_min, height_max, spread, habitat_size, habitat_nodes) 
minetest.register_on_generated(function(minp, maxp, seed)
    generate("jungletree:sapling", {"default:dirt_with_grass"}, minp, maxp, 0, 20, 10, 50, {"default:water_source"}, 30, {"default:desert_sand"})
end)[/code]
