local function file(filename, base)
    base = base or "base"
    return "__ufo-assets__/graphics/electrodynamic-fragmentation-device/" .. base .."/" .. filename
end

local function file2(filename)
    return "__base__/graphics/entity/assembling-machine-3/" .. filename
end


local function pipe_covers_pictures(layer, shift)
    local pcp = pipecoverspictures()
    if layer and shift then
        local layers = pcp[layer].layers
        layers[1].shift = shift
        layers[2].shift = shift
    end
    return pcp
end


return {
    graphics_set = {
        animation = {
            layers = {
                {
                    scale = 0.2,
                    filename = file("electrodynamic-fragmentation-device-animation.png"),
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
                    scale = 0.2,
                    filename = file("electrodynamic-fragmentation-device-color1.png"),
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
                    scale = 0.2,
                    filename = file("electrodynamic-fragmentation-device-color2.png"),
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
                            scale = 0.2,
                            filename = file("electrodynamic-fragmentation-device-color3.png"),
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
                            scale = 0.2,
                            filename = file("electrodynamic-fragmentation-device-emission2.png"),
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
                main_offset = util.by_pixel_hr(-85, 15),
                shadow_offset = util.by_pixel_hr(-85, 15),
                show_shadow = false,
            },
            {
                variation = 33,
                main_offset = util.by_pixel_hr(-85, 15),
                shadow_offset = util.by_pixel_hr(-85, 15),
                show_shadow = false,
            },
            {
                variation = 33,
                main_offset = util.by_pixel_hr(-85, 15),
                shadow_offset = util.by_pixel_hr(-85, 15),
                show_shadow = false,
            },
            {
                variation = 33,
                main_offset = util.by_pixel_hr(-85, 15),
                shadow_offset = util.by_pixel_hr(-85, 15),
                show_shadow = false,
            },
        }
    ),
    fluid_boxes = {
        {
            pipe_covers = pipe_covers_pictures("west", util.by_pixel_hr(4, 0)),
            pipe_picture = {
                scale = 0.5,
                filename = file2("assembling-machine-3-pipe-W.png"),
                blend_mode = "normal",
                width = 32,
                height = 72,
                shift = util.by_pixel_hr(50, 2),
                position = { 0, 0 },
            },
            pipe_connections = {
                {
                    direction = defines.direction.west,
                    position = { -1.55, -0.5 },
                    flow_direction = "input",
                },
            },
            production_type = "input",
            volume = 1000
        },
        {
            pipe_covers = pipe_covers_pictures("east", util.by_pixel_hr(-3, 0)),
            pipe_picture = {
                scale = 0.5,
                filename = file2("assembling-machine-3-pipe-E.png"),
                blend_mode = "normal",
                width = 32,
                height = 74,
                shift = util.by_pixel_hr(-50, 2),
                position = { 0, 0 },
            },
            pipe_connections = {
                {
                    direction = defines.direction.east,
                    position = { 1.55, -0.5 },
                    flow_direction = "output",
                },
            },
            production_type = "output",
            volume = 1000
        },
    },
    icon = file("electrodynamic-fragmentation-device.png", "icon"),
}
