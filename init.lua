-- ==== IMPORTS ====
local waywall = require("waywall")
local helpers = require("waywall.helpers")


-- ==== STATE ====

-- Holds the optional center-screen crosshair while it is visible
local crosshair = nil


-- ==== KEYS ====

-- Resolution modes
local thin = "*-Caps_Lock"
local tall = "*-J"
local wide = "*-H"
local oneshot = "*-equal" -- physical "=" key

-- Ninjabrain
local launch_ninbot = "apostrophe" -- '
local toggle_ninbot = "backslash"  -- \

-- Other
local toggle_crosshair = "semicolon"
local fullscreen = "Shift-O"


-- ==== REMAPS ====
local REMAPS = {
    ["MB4"] = "F3",

    ["O"] = "A",
    ["A"] = "O",

    ["K"] = "D",
    ["D"] = "K",
}


-- ==== SENSITIVITIES ====
local normal_sens = 8
local tall_sens = 0.53967521
local oneshot_sens = 0.0000000001


-- ==== PATHS ====
local home_path = os.getenv("HOME") .. "/"

local nb_path =
    home_path .. "mcsr/Ninjabrain-Bot-1.5.2.jar"

local overlay_path =
    home_path .. ".config/waywall/measuring_overlay.png"

local crosshair_path =
    home_path .. ".config/waywall/crosshair-transparent.png"

local shader_path =
    home_path .. ".config/waywall/shaders/"


-- ==== HELPERS ====

-- Read a shader file so Waywall can compile it during startup
local read_file = function(path)
    local file = assert(io.open(path, "r"))
    local data = file:read("*a")
    file:close()

    return data
end


-- ==== MIRRORS ====

-- Keep the pie chart group in the bottom-right corner of the Waywall screen
local pie_chart_dst = {
    x = 1210,
    y = 720,
    w = 300,
    h = 320,
}

local pie_text_dst = {
    x = 1510,
    y = 720,
    w = 200,
    h = 128,
}


-- Thin E-count
helpers.res_mirror({
    src = {
        x = 0,
        y = 37,
        w = 85,
        h = 9,
    },

    dst = {
        x = 1130,
        y = 618,
        w = 4 * 85,
        h = 4 * 9,
    },
}, 340, 1080)


-- Thin pie chart; use the same filtered presentation as eyezoom mode
helpers.res_mirror({
    src = {
        x = 0,
        y = 674,
        w = 340,
        h = 178,
    },

    dst = pie_chart_dst,

    depth = 2,
    shader = "pie_chart",
}, 340, 1080)


-- Thin pie percentages; keep the values beside the chart
helpers.res_mirror({
    src = {
        x = 244,
        y = 859,
        w = 45,
        h = 25,
    },

    dst = pie_text_dst,

    depth = 3,
    shader = "pie_text",
}, 340, 1080)


-- Tall E-count
helpers.res_mirror({
    src = {
        x = 0,
        y = 37,
        w = 85,
        h = 9,
    },

    dst = {
        x = 1130,
        y = 618,
        w = 4 * 85,
        h = 4 * 9,
    },
}, 340, 16384)


-- Tall pie chart; the shader removes the surrounding debug text
helpers.res_mirror({
    src = {
        x = 0,
        y = 15978,
        w = 340,
        h = 178,
    },

    dst = pie_chart_dst,

    depth = 2,
    shader = "pie_chart",
}, 340, 16384)


-- Tall pie percentages; filtered separately so the numbers stay readable
helpers.res_mirror({
    src = {
        x = 244,
        y = 16163,
        w = 45,
        h = 25,
    },

    dst = pie_text_dst,

    depth = 3,
    shader = "pie_text",
}, 340, 16384)


-- Eye measuring mirror
helpers.res_mirror({
    src = {
        x = 155,
        y = 7902,
        w = 30,
        h = 580,
    },

    dst = {
        x = 0,
        y = 370,
        w = 790,
        h = 340,
    },
}, 340, 16384)


-- Eye measuring overlay
helpers.res_image(
    overlay_path,
    {
        dst = {
            x = 0,
            y = 370,
            w = 790,
            h = 340,
        },
    },
    340,
    16384
)


-- ==== RESOLUTIONS ====

local resolutions = {
    thin = helpers.toggle_res(
        340,
        1080
    ),

    tall = helpers.toggle_res(
        340,
        16384,
        tall_sens
    ),

    wide = helpers.toggle_res(
        1920,
        340
    ),

    oneshot = helpers.toggle_res(
        1920,
        1080,
        oneshot_sens
    ),
}


-- ==== CONFIG ====

local config = {
    input = {
        layout = "us",

        repeat_rate = 40,
        repeat_delay = 300,

        remaps = REMAPS,

        sensitivity = normal_sens,
        confine_pointer = false,
    },

    theme = {
        background = "#000000ff",

        ninb_anchor = "topright",
        ninb_opacity = 1,
    },

    -- Filter the pie chart and its percentages down to useful pixels
    shaders = {
        ["pie_chart"] = {
            vertex = read_file(shader_path .. "general.vert"),
            fragment = read_file(shader_path .. "pie_chart.frag"),
        },

        ["pie_text"] = {
            vertex = read_file(shader_path .. "general.vert"),
            fragment = read_file(shader_path .. "pie_text.frag"),
        },
    },
}


-- ==== ACTIONS ====

config.actions = {

    -- =========================
    -- RESOLUTIONS
    -- =========================

    [thin] = resolutions.thin,
    [tall] = resolutions.tall,
    [wide] = resolutions.wide,
    [oneshot] = resolutions.oneshot,


    -- =========================
    -- NINJABRAIN
    -- =========================

    -- ' launches Ninjabrain
    [launch_ninbot] = function()
        waywall.exec(
            "java -Dawt.useSystemAAFontSettings=on -jar " .. nb_path
        )
    end,

    -- \ hides/shows Ninjabrain
    [toggle_ninbot] = helpers.toggle_floating,


    -- =========================
    -- CROSSHAIR
    -- =========================

    -- ; toggles a transparent crosshair at the center of the screen
    [toggle_crosshair] = function()
        if crosshair then
            crosshair:close()
            crosshair = nil
        else
            crosshair = waywall.image(crosshair_path, {
                dst = {
                    x = 945,
                    y = 525,
                    w = 30,
                    h = 30,
                },

                depth = 10,
            })
        end
    end,


    -- =========================
    -- F3 + C
    -- =========================

    ["*-C"] = function()

        if waywall.get_key("F3") then
            waywall.show_floating(true)
        end

        -- Still send C through to Minecraft
        return false
    end,


    -- =========================
    -- FULLSCREEN
    -- =========================

    [fullscreen] = waywall.toggle_fullscreen,
}


return config
