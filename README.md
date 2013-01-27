This mod adds swamps to minetest.
If you have got some ideas, tell them to me.

[b]Depends:[/b] [url=http://minetest.net/forum/viewtopic.php?pid=39943#p39943]jungletree, habitat[/url], default
[b]License:[/b] GPL [i](sounds)[/i], WTFPL [i](code, textures except birch)[/i]

[quote][i]Delete following lines of the jungletree mod:[/i][code]--function anti_generate(node, surfaces, minp, maxp, height_min, height_max, spread, habitat_size, habitat_nodes) 
minetest.register_on_generated(function(minp, maxp, seed)
    generate("jungletree:sapling", {"default:dirt_with_grass"}, minp, maxp, 0, 20, 10, 50, {"default:water_source"}, 30, {"default:desert_sand"})
end)[/code][/quote]
