local function file(filename)
    return "__ufo__/graphics/research-center/base/" .. filename
end

local function file2(filename)
    return "__base__/graphics/entity/assembling-machine-3/" .. filename
end

return {
    graphics_set = {
        animation = {
            layers = {
                {
                    scale = 0.25,
                    filenames = {
                        file("research-center-animation.png"),
                    },
                    blend_mode = "normal",
                    width = 590,
                    height = 640,
                    line_length = 10,
                    lines_per_file = 8,
                    frame_count = 80,
                    shift = util.by_pixel_hr(0, 0),
                    tint = { r = 1, g = 1, b = 1, a = 1 },
                },
                {
                    scale = 0.25,
                    filenames = {
                        file("research-center-color1.png"),
                    },
                    blend_mode = "normal",
                    width = 590,
                    height = 640,
                    line_length = 10,
                    lines_per_file = 8,
                    frame_count = 80,
                    shift = util.by_pixel_hr(0, 0),
                    tint = { r = 0.44313725490196076, g = 0.9215686274509803, b = 0.6627450980392157, a = 1 },
                },
                {
                    scale = 0.25,
                    filenames = {
                        file("research-center-color2.png"),
                    },
                    blend_mode = "additive-soft",
                    width = 590,
                    height = 640,
                    line_length = 10,
                    lines_per_file = 8,
                    frame_count = 80,
                    shift = util.by_pixel_hr(0, 0),
                    tint = { r = 0, g = 0.403921568627451, b = 0.9137254901960784, a = 1 },
                },
            },
        },
        working_visualisations = {
            {
                animation = {
                    layers = {
                        {
                            scale = 0.25,
                            filenames = {
                                file("research-center-color3.png"),
                            },
                            blend_mode = "normal",
                            draw_as_glow = true,
                            width = 590,
                            height = 640,
                            line_length = 10,
                            lines_per_file = 8,
                            frame_count = 80,
                            shift = util.by_pixel_hr(0, 0),
                            tint = { r = 0.3137254901960784, g = 0.6078431372549019, b = 0.796078431372549, a = 1 },
                        },
                        {
                            scale = 0.25,
                            filenames = {
                                file("research-center-emission2.png"),
                            },
                            blend_mode = "additive",
                            draw_as_glow = true,
                            width = 590,
                            height = 640,
                            line_length = 10,
                            lines_per_file = 8,
                            frame_count = 80,
                            shift = util.by_pixel_hr(0, 0),
                            tint = { r = 1, g = 1, b = 1, a = 1 },
                        },
                    }
                }
            }
        }
    },
    circuit_connector = circuit_connector_definitions.create_vector(
            universal_connector_template,
            {
                {
                    variation = 33,
                    main_offset = util.by_pixel_hr(-100, 15),
                    shadow_offset = util.by_pixel_hr(-100, 15),
                    show_shadow = false,
                },
                {
                    variation = 33,
                    main_offset = util.by_pixel_hr(-100, 15),
                    shadow_offset = util.by_pixel_hr(-100, 15),
                    show_shadow = false,
                },
                {
                    variation = 33,
                    main_offset = util.by_pixel_hr(-100, 15),
                    shadow_offset = util.by_pixel_hr(-100, 15),
                    show_shadow = false,
                },
                {
                    variation = 33,
                    main_offset = util.by_pixel_hr(-100, 15),
                    shadow_offset = util.by_pixel_hr(-100, 15),
                    show_shadow = false,
                },
            }
    ),
    fluid_boxes = {
        {
            pipe_covers = pipecoverspictures(),
            pipe_picture = {
                scale = 0.5,
                filename = file2("assembling-machine-3-pipe-W.png"),
                blend_mode = "normal",
                width = 39,
                height = 73,
                shift = util.by_pixel_hr(50, 0),
                position = { 0, 0 },
            },
            pipe_connections = {
                {
                    direction = defines.direction.west,
                    position = { -4/3, -0.5 },
                    flow_direction = "input",
                },
            },
            secondary_draw_orders = {
                north = -1,
            },
            production_type = "input",
            volume = 1000
       },
        {
            pipe_covers = pipecoverspictures(),
            pipe_picture = {
                scale = 0.5,
                filename = file2("assembling-machine-3-pipe-E.png"),
                blend_mode = "normal",
                width = 42,
                height = 76,
                shift = util.by_pixel_hr(-50, 0),
                position = { 0, 0 },
            },
            pipe_connections = {
                {
                    direction = defines.direction.east,
                    position = { 4/3, -0.5 },
                    flow_direction = "output",
                },
            },
            secondary_draw_orders = {
                north = -1,
            },
            production_type = "output",
            volume = 1000
        },
    },
}
