math.lerp = function(a, b, percentage)
    return a + (b - a) * percentage
end

color_t.fade_color = function(f, s, a)
    local r = math.lerp(f.r, s.r, a)
    local g = math.lerp(f.g, s.g, a)
    local b = math.lerp(f.b, s.b, a)
    local a = math.lerp(f.a, s.a, a)
    return color_t.new(r, g, b, a)
end

renderer.text_outline = function(text, font, pos, size, color)
    renderer.text(text, font, vec2_t.new(pos.x - 1, pos.y - 0), size, color)
    renderer.text(text, font, vec2_t.new(pos.x - 0, pos.y - 1), size, color)
    renderer.text(text, font, vec2_fat.new(pos.x + 1, pos.y + 0), size, color)
    renderer.text(text, font, vec2_t.new(pos.x + 0, pos.y + 1), size, color)
    renderer.text(text, font, vec2_t.new(pos.x - 1, pos.y - 1), size, color)
    renderer.text(text, font, vec2_t.new(pos.x + 1, pos.y + 1), size, color)
    renderer.text(text, font, vec2_t.new(pos.x + -1, pos.y + 1), size, color)
    renderer.text(text, font, vec2_t.new(pos.x - -1, pos.y - 1), size, color)
end

function DrawShadowedText(shadow, text, font, pos, size, color)
    renderer.text(text, font, vec2_t.new(pos.x + shadow, pos.y + shadow), size, color_t.new(0, 0, 0, color.a or 255))
    renderer.text(text, font, vec2_t.new(pos.x, pos.y), size, color)
end

function DrawEnchantedText(speed, text, font, pos, size, color, glow_color)
    local chars_x = 0
    local len = #text - 1
    for i = 1, len + 1 do
        local text_sub = string.sub(text, i, i)
        local text_size = renderer.get_text_size(font, size, text_sub .. "")
        local color_glowing = color_t.fade_color(glow_color, color, math.abs(math.sin((globalvars.get_real_time() - (i * 0.08)) * speed)))
        renderer.text(text_sub .. "", font, vec2_t.new(pos.x + chars_x, pos.y), size, color_glowing)
        chars_x = chars_x + text_size.x
    end
end

function DrawFadingText(speed, text, font, pos, size, color, fading_color)
    local color_fade = color_t.fade_color( color, fading_color, math.abs(math.sin((globalvars.get_real_time() - 0.08) * speed)))
    renderer.text(text, font, vec2_t.new(pos.x, pos.y), size, color_fade)
end


local col1 = color_t.new(0, 0, 0, 255)
local col2 = color_t.new(255, 255, 255, 255)
local next_col = 0

function DrawRainbowText(speed, text, font, pos, size)
    next_col = next_col + 1 / (100 / speed)
    if next_col >= 1 then
        next_col = 0
        col1 = col2
        col2 = color_t.new(math.random(0, 255), math.random(0, 255), math.random(0, 255), 255)
    end
    local color_fade = color_t.fade_color(col1, col2, next_col)
    renderer.text(text, font, vec2_t.new(pos.x, pos.y), size, color_fade)
end

function DrawGlowingText(static, text, font, pos, size, color, glow_color)
    local initial_a = 20
    local a_by_i = 2
    local alpha_glow = math.abs(math.sin((globalvars.get_real_time() - 0.1) * 2))
    if static then alpha_glow = 1 end
    for i = 1, 5 do
        renderer.text_outline(text, font, pos, size, color_t.new(glow_color.r, glow_color.g, glow_color.b, ((initial_a - (i * a_by_i)) * alpha_glow)))
    end
    renderer.text(text, font, pos, size, color)
end

function DrawBouncingText(style, intesity, text, font, pos, size, color)
    local chars_x = 0
    local len = #text - 1
    for i = 1, len + 1 do
        local text_sub = string.sub(text, i, i)
        local text_size = renderer.get_text_size(font, size, text_sub .. "")
        local y_pos = 1
        local mod = math.sin((globalvars.get_real_time() - (i * 0.1)) * (2 * intesity))
        if style == 1 then
            y_pos = y_pos - math.abs(mod)
        elseif style == 2 then
            y_pos = y_pos + math.abs(mod)
        else
            y_pos = y_pos - mod
        end
        renderer.text(text_sub .. "", font, vec2_t.new(pos.x + chars_x, pos.y - (5 * y_pos)), size, color)
        chars_x = chars_x + text_size.x
    end
end


local next_electic_effect = globalvars.get_current_time() + 0
local electric_effect_a = 0
function DrawElecticText(intensity, text, font, pos, size, color)
    local text_size = renderer.get_text_size(font, size, text)
    renderer.text(text, font, pos, size, color)
    if electric_effect_a > 0 then
        electric_effect_a = electric_effect_a - (1000 * globalvars.get_frame_time())
    end
    for i = 1, math.random(0, 5) do
        line_x = math.random(0, text_size.x)
        line_y = math.random(0, text_size.y)
        line_x2 = math.random(0, text_size.x)
        line_y2 = math.random(0, text_size.y)
        renderer.line(vec2_t.new(pos.x + line_x, pos.y + line_y), vec2_t.new(pos.x + line_x2, pos.y + line_y2), color_t.new(102, 255, 255, electric_effect_a))
    end
    local effect_min = 0.5 + ( 1 - intensity )
    local effect_max = 1.5 + ( 1 - intensity )
    if next_electic_effect <= globalvars.get_current_time() then
        next_electic_effect = globalvars.get_current_time() + math.random( effect_min, effect_max )
        electric_effect_a = 255
    end
end

function DrawFireText(intensity, text, font, pos, size, color, glow, glow_color, shadow)
    local text_size = renderer.get_text_size(font, size, text)
    local fire_height = text_size.y * intensity
    for i = 1, text_size.x do
        local line_y = math.random(fire_height, text_size.y)
        local line_x = math.random(-4, 4)
        local line_col = math.random(0, 255)
        renderer.line(vec2_t.new(pos.x - 1 + i, pos.y + text_size.y), vec2_t.new(pos.x - 1 + i + line_x, pos.y + line_y), color_t.new(255, line_col, 0, 150))
    end
    if glow then
        DrawGlowingText(true, text, font, pos, size, color, glow_color)
    end
    if shadow then
        renderer.text(text, font, vec2_t.new(pos.x + 1, pos.y + 1), size, color_t.new(0, 0, 0, 255))
    end
    renderer.text(text, font, pos, size, color)
end

function DrawSnowingText(intensity, text, font, pos, size, color, color2)
    local color2 = color2 or color_t.new(255, 255, 255, 255)
    renderer.text(text, font, pos, size, color)
    local text_size = renderer.get_text_size(font, size, text)
    for i = 1, intensity do
        local line_y = math.random(0, text_size.y)
        local line_x = math.random(0, text_size.x)
        renderer.line(vec2_t.new(pos.x + line_x, pos.y + line_y), vec2_t.new(pos.x + line_x, pos.y + line_y + 1), color_t.new(color2.r, color2.g, color2.b, 255))
    end
end

local userere = client.get_username()
if client.get_username() == userere then
end
if userere  == "yamaha" then
local script_tabs = ui.add_combo_box("avira.tech", "script_tab_selection", { "Main", "Values", "Visuals", "Anti-aim", "Misc" }, 0)


client.notify("welcome back "..userere)
client.notify("have a good day with avira.tech")


client.register_callback('paint', on_intro_paint)


local hits = 0
local misses = 0

client.register_callback("shot_fired", function(shot_info)
    if shot_info.result ~= "hit" and not shot_info.manual then
        misses = misses + 1
    end
    if shot_info.result == "hit" and not shot_info.manual then
        hits = hits + 1
    end
end)


local slowWalkBint = ui.get_key_bind("antihit_extra_slowwalk_bind")
local m_bDucked = se.get_netvar("DT_BasePlayer", "m_bDucked")
local m_vecVelocity = {
    [0] = se.get_netvar("DT_BasePlayer", "m_vecVelocity[0]"),
    [1] = se.get_netvar("DT_BasePlayer", "m_vecVelocity[1]")
}

function get_cond()
    localPlayer = entitylist.get_local_player()
    m_hGroundEntity = localPlayer:get_prop_int(se.get_netvar("DT_BasePlayer", "m_hGroundEntity"))
    duck = localPlayer:get_prop_int(se.get_netvar("DT_BasePlayer", "m_bDucked"))
    velocity = math.sqrt(localPlayer:get_prop_float(m_vecVelocity[0]) ^ 2 + localPlayer:get_prop_float(m_vecVelocity[1]) ^ 2)
    if m_hGroundEntity == -1 then
        return "in air"
    elseif m_hGroundEntity ~= -1 and duck == 1 then
        return "crouch"
    elseif m_hGroundEntity ~= -1 and velocity > 5 then
        if not slowWalkBint:is_active() then
            return "move"
        else
            return "slowwalk"
        end
    elseif m_hGroundEntity ~= -1 and velocity < 5 then
        return "stand"
    end
end



local clantag = ui.add_check_box("Enable Clantag", "clantag", false)
local clantag_speed = ui.add_slider_int("Clantag Speed", "clantag_speed", 0, 100, 15)
local get_ct_speed = clantag_speed:get_value()

local m_iTeamNum = se.get_netvar("DT_BasePlayer", "m_iTeamNum")
local a1 = 1
local a2 = 1
local a3 =
{
   "",
  "a",
  "av",
  "avi",
  "avir",
  "avira",
  "avira",
  "avira",
  "avira",
  "avira",
  "avira",
  "avira",
  "avira",
  "avira",
  "avira",
  "avir",
  "avi",
  "av",
  "a",
  "",
}
function paint()

    if engine.is_in_game() then
        if a1 < globalvars.get_tick_count() and clantag:get_value() then
            a2 = a2 + 1
            if a2 > 33 then
                a2 = 0
            end
            se.set_clantag(a3[a2])
            a1 = globalvars.get_tick_count() + get_ct_speed
        end
    end
end

client.register_callback("paint", paint)

function get_invertion()
    local inverter = ui.get_key_bind("antihit_antiaim_flip_bind"):is_active()
    if inverter then
        return "1"
    else
        return "2"
    end
end

function get_cond()
    localPlayer = entitylist.get_local_player()
    m_hGroundEntity = localPlayer:get_prop_int(se.get_netvar("DT_BasePlayer", "m_hGroundEntity"))
    duck = localPlayer:get_prop_int(se.get_netvar("DT_BasePlayer", "m_bDucked"))
    velocity = math.sqrt(localPlayer:get_prop_float(m_vecVelocity[0]) ^ 2 + localPlayer:get_prop_float(m_vecVelocity[1]) ^ 2)
    if m_hGroundEntity == -1 then
        return "in air"
    elseif m_hGroundEntity ~= -1 and duck == 1 then
        return "crouch"
    elseif m_hGroundEntity ~= -1 and velocity > 5 then
        if not slowWalkBint:is_active() then
            return "move"
        else
            return "slowwalk"
        end
    elseif m_hGroundEntity ~= -1 and velocity < 5 then
        return "stand"
    end
end


   





local antiaim = ui.add_check_box('Desync jitter', 'antiaim', false)
local antihit_antiaim_flip_bind = ui.get_key_bind('antihit_antiaim_flip_bind')

local antiaim_enable = function() -- local function antiaim_enable()
    if clientstate.get_choked_commands() == 0 then
        if antihit_antiaim_flip_bind:get_type() == 0 then
            antihit_antiaim_flip_bind:set_type(2)
        else
            antihit_antiaim_flip_bind:set_type(0)
        end
    end
end

client.register_callback('create_move', function ()
    if antiaim:get_value() then
        antiaim_enable()
    end
end)

local hide_shots = ui.add_key_bind("Hideshots", "exploit_hide_shots", 0, 2)
local doubletap = ui.add_key_bind("Doubletap", "exploit_doubletap", 0, 2)

local function on_create_move(cmd)
    local is_hide_shots = ui.get_combo_box("rage_active_exploit")
    local is_doubletap = ui.get_combo_box("rage_active_exploit")
    local default = ui.get_combo_box("rage_active_exploit")

    if hide_shots:is_active() then
        is_hide_shots:set_value(1)
    end

    if doubletap:is_active() then
        is_doubletap:set_value(2)
    end

    if not hide_shots:is_active() and not doubletap:is_active() then
        default:set_value(0)
    end
end

local function on_unload()
    local default = ui.get_combo_box("rage_active_exploit")
    default:set_value(0)
end

client.register_callback("create_move", on_create_move)
client.register_callback("unload", on_unload)


local menu = {
    logs = ui.add_multi_combo_box('Logs', 'l_logs', { 'Damage Dealt', 'Damage Received', 'Misses', 'Purchases' }, { false, false, false, false }),
    position = ui.add_combo_box('Position', 'l_position', { 'Upper Left', 'Upper Right', 'Under Crosshair' }, 0),
    limit = ui.add_slider_int('Limit', 'l_limit', 5, 50, 40),
    damage_dealt_color = ui.add_color_edit('Damage Dealt Color', 'l_damage_dealt_color', true, color_t.new(255, 255, 255, 255)),
    damage_received_color = ui.add_color_edit('Damage Received Color', 'l_damage_received_color', true, color_t.new(255, 255, 255, 255)),
    misses_color = ui.add_color_edit('Misses Color', 'l_misses_color', true, color_t.new(255, 100, 100, 255)),
    purchases_color = ui.add_color_edit('Purchases Color', 'l_purchases_color', true, color_t.new(255, 255, 255, 255)),
    text_color = ui.add_color_edit('text color', 'l_purchases_color', true, color_t.new(255, 255, 255, 255))
}


ffi.cdef[[
    struct c_color { unsigned char clr[4];};
]]

local log = {}

local console_color = ffi.new('struct c_color')
log.console_print = function(color, text)
    local engine_cvar = ffi.cast('void***', se.create_interface('vstdlib.dll', 'VEngineCvar007'))
    local console_print = ffi.cast('void(__cdecl*)(void*, const struct c_color&, const char*, ...)', engine_cvar[0][25])
    console_color.clr = {[0] = color.r, [1] = color.g, [2] = color.b, [3] = color.a}
    console_print(engine_cvar, console_color, text)
end

local logs = {}

log.add = function(text, color)
    log.console_print(color, '' .. text .. '\n')
    table.insert(logs, 1, { text = text, color = color, alpha = 0, time = globalvars.get_current_time() + 4 })
end

math.lerp = function(a, b, time)
    return a + (b - a) * time
end

local font = renderer.setup_font('c:/windows/fonts/arial.ttf', 12, 400)

log.render = function()


    local offset = 0
    local local_player = entitylist.get_local_player()
    for i, v in pairs(logs) do
        if v.time > globalvars.get_current_time() and i <= menu.limit:get_value() and engine.is_connected() then
            v.alpha = math.lerp(v.alpha, 255, 0.13)
        else
            v.alpha = math.lerp(v.alpha, 0, 0.13)
            if v.alpha < 1 then
                table.remove(logs, i)
            end
        end

        local pos = {
            [0] = { x = 5, y = 5 },
            [1] = { x = engine.get_screen_size().x - renderer.get_text_size(font, 12, v.text).x - 5, y = 5 },
            [2] = { x = engine.get_screen_size().x / 2 - renderer.get_text_size(font, 12, v.text).x / 2, y = engine.get_screen_size().y / 2 + 100 },
        }

        renderer.text(v.text, font, vec2_t.new(pos[menu.position:get_value()].x + 1, pos[menu.position:get_value()].y + 1 + offset), 12, color_t.new(0, 0, 0, v.alpha))
        renderer.text(v.text, font, vec2_t.new(pos[menu.position:get_value()].x, pos[menu.position:get_value()].y + offset), 12, color_t.new(v.color.r, v.color.g, v.color.b, v.alpha))
        offset = offset + 16 * (v.alpha / 255)
    end
end

local hitgroups = {
    [0] = 'generic',
    [1] = 'head',
    [2] = 'body',
    [3] = 'body',
    [4] = 'left arm',
    [5] = 'right arm',
    [6] = 'left leg',
    [7] = 'right leg',
    [8] = 'neck',
    [10] = 'gear'
}

local hitboxes = {
    [0] = 'head',
    [4] = 'body',
    [5] = 'body',
    [6] = 'body',
    [2] = 'body',
    [3] = 'body',
    [13] = 'arm',
    [15] = 'arm',
    [16] = 'arm',
    [14] = 'arm',
    [17] = 'arm',
    [18] = 'arm',
    [7] = 'left leg',
    [9] = 'left leg',
    [11] = 'left leg',
    [8] = 'right leg',
    [10] = 'right leg', 
    [12] = 'right leg'
}

local weapon_to_verb = { hegrenade = 'Naded', inferno = 'Burned', knife = 'Knifed', taser = 'Zeused' }




log.player_hurt = function(event)
    local local_player = engine.get_player_info(entitylist.get_local_player():get_index()).name
    local target = engine.get_player_info(engine.get_player_for_user_id(event:get_int('userid', 0))).name
    local attacker = engine.get_player_info(engine.get_player_for_user_id(event:get_int('attacker', 0))).name
    local damage = event:get_int('dmg_health', 0)
    local hitgroup = hitgroups[event:get_int('hitgroup', 0)]
    local remaining = event:get_int('health', 0)
    local weapon = event:get_string('weapon', '')
    local verb = weapon_to_verb[weapon] ~= nil and weapon_to_verb[weapon] or 'hit'

    if menu.logs:get_value(0) and attacker == local_player and target ~= local_player and target ~= nil then
        if hitgroup == 'generic' then
            log.add(('%s %s in %s for %s hp'):format(verb,  target, damage), menu.damage_dealt_color:get_value())
        else
            log.add(('%s %s in %s for %s hp'):format(verb,  target, hitgroup, damage), menu.damage_dealt_color:get_value())
        end
    end

    if menu.logs:get_value(1) and target == local_player and attacker ~= local_player and attacker ~= nil then
        if hitgroup == 'generic' then
            log.add(('harmed by %s for %s damage (%s remaining)'):format(attacker, damage, remaining), menu.damage_received_color:get_value())
        else
            log.add(('harmed by %s in the %s for %s damage (%s remaining)'):format(attacker, hitgroup, damage, remaining), menu.damage_received_color:get_value())
        end
    end
end

log.shot_fired = function(shot_info)
    local target = engine.get_player_info(shot_info.target:get_index()).name
    local hitbox = hitboxes[shot_info.hitbox]
    local reason = shot_info.result ==  'desync' and 'resolver' or shot_info.result == 'unk' and 'unknown reason' or shot_info.result == 'death'and 'death' or shot_info.result == 'spread' and 'spread' or shot_info.result
    if menu.logs:get_value(2) and reason ~= 'hit' and target ~= nil then
        log.add(('Missed shot due to %s [ bt: unk | sp : unk]'):format(reason), menu.misses_color:get_value())
    end
end

log.item_purchase = function(event)
    local player = engine.get_player_info(engine.get_player_for_user_id(event:get_int('userid', 0))).name
    local weapon = event:get_string('weapon', '')
    local item = weapon:find('weapon_') and weapon:gsub('weapon_', '') or weapon:find('item_') and weapon:gsub('item_', '')
    
    if menu.logs:get_value(3) and weapon ~= 'weapon_unknown' then
        log.add(('%s purchase %s'):format(player, item), menu.purchases_color:get_value())
    end
end

client.register_callback('paint', log.render)
client.register_callback('player_hurt', log.player_hurt)
client.register_callback('shot_fired', log.shot_fired)
client.register_callback('item_purchase', log.item_purchase)




local mindamage_keybind = ui.add_key_bind("Mindamage keybind", "mindamage_keybind", 0, 1)
local mindamage_value = ui.add_slider_int("Min Damage Value", "dmg_value", 1, 120, 1)
local PingSpikeKey = ui.add_key_bind("Extended backtrack", "PingSpikeKey", 0, 1)
local PingSpikeValue = ui.add_slider_int("Ext.Backtrack value", "PingSpikeValue", 0, 200, 150)
local fb_bind = ui.add_key_bind("Force body aim","fb_bind", 0, 2)
local screen_ind = ui.add_multi_combo_box("Screen indicators", "screen_ind", { "Keybinds", "Watermark", "Info panel", "Watermark (Mercury NL style)", "Choked commands ind", "AA side ind" }, { false, false, false, false, false, false})
local watermarkusername = ui.add_text_input("Custom watermark username", "watermarkusername", "")
local animation_type = ui.add_combo_box("Animation type", "animation_type", { "Anim 1", "Anim 2" }, 0)
local auto_resize_width = ui.add_check_box("Auto resize width", "auto_resize_width", true)
local style_line = ui.add_combo_box("Style line", "style_line", { "Static", "Fade", "Reverse fade", "Gradient", "Avira.tech UI", "Chroma" }, 0)
local chroma_dir = ui.add_combo_box("Chroma direction", "chroma_dir", { "Left", "Right", "Static" }, 0)
local color_line = ui.add_color_edit("Color line", "color_line", true, color_t.new(52, 164, 235, 255))
local keybinds_x = ui.add_slider_int("keybind_x", "keybinds_x", 0, engine.get_screen_size().x, 345)
local keybinds_y = ui.add_slider_int("keybind_y", "keybinds_y", 0, engine.get_screen_size().y, 215)


local fonts = renderer.setup_font("c:/windows/fonts/verdana.ttf", 12, 44)
local verdana = renderer.setup_font("c:/windows/fonts/verdana.ttf", 12, 0)
local verdanab = renderer.setup_font("c:/windows/fonts/verdanab.ttf", 12, 0)
local smp = renderer.setup_font("nix/smp.ttf", 24, 0)
local smal = renderer.setup_font("nix/smp.ttf", 13, 0)
local keyboard = renderer.setup_font("nix/font.ttf", 13, 0)


local types = { "[always on]", "[holding]", "[toggled]", "[always off]" }

local function hsv2rgb(h, s, v, a)
    local r, g, b

    local i = math.floor(h * 6);
    local f = h * 6 - i;
    local p = v * (1 - s);
    local q = v * (1 - f * s);
    local t = v * (1 - (1 - f) * s);

    i = i % 6

    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q
    end

    return color_t.new(r * 255, g * 255, b * 255, a * 255)
end
function math.lerp(a, b, t) return a + (b - a) * t end
local function drag(x, y, width, height, xmenu, ymenu, item)
    local cursor = renderer.get_cursor_pos()
    if (cursor.x >= x) and (cursor.x <= x + width) and (cursor.y >= y) and (cursor.y <= y + height) then
        if client.is_key_pressed(1) and item[1] == 0 then
            item[1] = 1
            item[2] = x - cursor.x
            item[3] = y - cursor.y
        end
    end
    if not client.is_key_pressed(1) then item[1] = 0 end
    if item[1] == 1 and ui.is_visible() then
		xmenu:set_value(cursor.x + item[2])
		ymenu:set_value(cursor.y + item[3])
    end
end
local function filledbox(x, y, w, h, al)
	local rgb = hsv2rgb(globalvars.get_real_time() / 4, 0.9, 1, 1)
	local chromd = chroma_dir:get_value()
	local col = color_line:get_value()
	local stl = style_line:get_value()

    if stl ~= 4 then
    renderer.rect_filled(vec2_t.new(x, y), vec2_t.new(x + w, y + h), color_t.new(15, 15, 15, col.a * al))
    else
    renderer.rect_filled_fade(vec2_t.new(x, y - 2), vec2_t.new(x + w, y + h), color_t.new(col.r, col.g, col.b, 255 * al), color_t.new(col.r, col.g, col.b, 255 * al), color_t.new(0, 0, 0, 0), color_t.new(50, 48, 47, 0))
    renderer.rect_filled_fade(vec2_t.new(x + 1, y - 1), vec2_t.new(x + w / 2, y), color_t.new(0, 0, 0, 0), color_t.new(0, 0, 0, 0), color_t.new(0, 0, 0, 0), color_t.new(0, 0, 0, 0))
    renderer.rect_filled_fade(vec2_t.new(x + (w / 2), y - 1), vec2_t.new(x + w - 1, y), color_t.new(0, 0, 0, 0), color_t.new(0, 0, 0, 0), color_t.new(0, 0, 0, 0), color_t.new(0, 0, 0, 0))
	
	
	gradient_color = stl == 0 and color_t.new(col.r, col.g, col.b, 255 * al) or stl == 1 and color_t.new(0, 0, 0, 255 * al) or stl == 2 and color_t.new(col.r, col.g, col.b, 255 * al) or stl == 3 and color_t.new(0, 213, 255, 255 * al) or stl == 5 and color_t.new(chromd==1 and rgb.g or rgb.r, chromd==1 and rgb.b or rgb.g, chromd ==1 and rgb.g or rgb.b, 255 * al) or color_t.new(0, 0, 0, 0)
	gradient_color1 = stl == 0 and color_t.new(col.r, col.g, col.b, 255 * al) or stl == 1 and color_t.new(col.r, col.g, col.b, 255 * al) or stl == 2 and color_t.new(0, 0, 0, 255 * al) or stl == 3 and color_t.new(204, 18, 204, 255 * al) or stl == 5 and color_t.new(chromd==2 and rgb.r or rgb.b, chromd==2 and rgb.g or rgb.r, chromd==2 and rgb.b or rgb.g, 255 * al) or color_t.new(0, 0, 0, 0)
	gradient_color2 = stl == 0 and color_t.new(col.r, col.g, col.b, 255 * al) or stl == 1 and color_t.new(0, 0, 0, 255 * al) or stl == 2 and color_t.new(col.r, col.g, col.b, 255 * al) or stl == 3 and color_t.new(255, 250, 0, 255 * al) or stl == 5 and color_t.new(chromd==0 and rgb.g or rgb.r, chromd==0 and rgb.b or rgb.g, chromd ==0 and rgb.g or rgb.b, 255 * al) or color_t.new(0, 0, 0, 0)

    if stl ~= 4 then
        renderer.rect_filled_fade(vec2_t.new(x, y - 2), vec2_t.new(x + w / 2, y), gradient_color, gradient_color1, gradient_color1, gradient_color)
        renderer.rect_filled_fade(vec2_t.new(x + (w / 2), y - 2), vec2_t.new(x + w, y), gradient_color1, gradient_color2, gradient_color2, gradient_color1)
    end
end

end
--indicators
local item = { 0, 0, 0 }
local animwidth = 0;
local alpha = { 0 }
local bind = {
["Double tap"] = {reference = doubletap, exploit = 0, add = 0, multiply = 0},
["Hide shots"] = {reference = hide_shots, exploit = 0, add = 0, multiply = 0},
["Auto peek"] = {reference = ui.get_key_bind("antihit_extra_autopeek_bind"), exploit = 0, add = 0, multiply = 0},
["Slow walk"] = {reference = ui.get_key_bind("antihit_extra_slowwalk_bind"), exploit = 0, add = 0, multiply = 0},
["Fake duck"] = {reference = ui.get_key_bind("antihit_extra_fakeduck_bind"), exploit = 0, add = 0, multiply = 0},
["Jump bug"] = {reference = ui.get_key_bind("misc_jump_bug_bind"), exploit = 0, add = 0, multiply = 0},
["Edge jump"] = {reference = ui.get_key_bind("misc_edge_jump_bind"), exploit = 0, add = 0, multiply = 0},
["Damage override"] = {reference = mindamage_keybind, exploit = 0, add = 0, multiply = 0},
["Body aim"] = {reference = fb_bind, exploit = 0, add = 0, multiply = 0},
["Fake latency"] = {reference = PingSpikeKey, exploit = 0, add = 0, multiply = 0},
--["Название бинда"] = {reference = получение бинда, exploit = 0 (это не трогать), add = 0 (это не трогать), multiply = 0 (это не трогать)},
};
client.register_callback("paint", function()
	--ui visible
	local screen = screen_ind:get_value(1) or screen_ind:get_value(0) or screen_ind:get_value(2) or screen_ind:get_value(3)
	--timer
	local function watermark()
	--watermark
		if screen_ind:get_value(1) then
			local user = client.get_username()
			if watermarkusername:get_value() ~= "" then user = tostring(watermarkusername:get_value()) else user = client.get_username() end
			local username = client.get_username()
			local ping = se.get_latency()
			local fps = math.floor(1 / globalvars.get_frame_time())
			local text = ""
            local aviragg = "[nightly]"
			if engine.is_connected() then
			text = "                 " .. user .. " "..ping.."ms " .. os.date("%X") else 
			text = "                 " .. user .. " " .. os.date("%X") end
			local screen = engine.get_screen_size()
			local w = renderer.get_text_size(fonts, 12, text).x + 10
			local h = 19
			local x = screen.x - w - 10
			filledbox(x, 8, w, h, 1)
            DrawEnchantedText(1.5, "             ", fonts, vec2_t.new(x + 5, 12), 12, color_t.new(15, 15, 15, 0), color_t.new(255, 255, 255, 255))
            DrawShadowedText(0, "avira.tech ", fonts, vec2_t.new(x + 5, 12), 12, color_t.new(255, 255, 255, 255))
			renderer.text(text, fonts, vec2_t.new(x + 5, 12), 12, color_t.new(255, 255, 255, 255))
		end
	end
    --watermark 2
    if screen_ind:get_value(2) then
        DrawShadowedText(0.6, ">\\ avira nixware cord", fonts, vec2_t.new(10, 500), 12, color_t.new(255, 255, 255, 255))
        DrawShadowedText(0.6, "  ver. beta", fonts, vec2_t.new(10, 510), 12, color_t.new(255, 255, 255, 255))
        DrawShadowedText(0.6, "  username - "..userere, fonts, vec2_t.new(10, 520), 12, color_t.new(255, 255, 255, 255))
    end

    --watermark 3
    if screen_ind:get_value(3) then
            renderer.rect_filled_fade(vec2_t.new(10, 10), vec2_t.new(200, 50), color_t.new(138, 156, 255, 255), color_t.new(138, 156, 255, 0), color_t.new(138, 156, 255, 0), color_t.new(138, 156, 255, 255))
            DrawShadowedText(2, "AVIRA", verdana, vec2_t.new(60, 15), 24, color_t.new(255, 255, 255, 255))
            DrawShadowedText(2, "[BETA] "..userere, smp, vec2_t.new(60, 36), 13, color_t.new(255, 255, 255, 255))
            local my_texture = renderer.setup_texture("nix/aviratech/e34.jpg")
             renderer.texture(my_texture, vec2_t.new(15, 10), vec2_t.new(50, 50), color_t.new(255, 255, 255, 255))
    end
        --FL

        if screen_ind:get_value(4) then
        local choke = clientstate.get_choked_commands()
        filledbox(1840, 40, 65, 19, 1)
        renderer.text("choked: "..choke, fonts, vec2_t.new(1840, 45), 12, color_t.new(255, 255, 255, 255))
    end
    --aa

    if screen_ind:get_value(5) then
        filledbox(1780, 40, 40, 19, 1)
        renderer.text("side: "..get_invertion(), fonts, vec2_t.new(1781, 45), 12, color_t.new(255, 255, 255, 255))
    end
	--keybinds
	local function keybinds()
		if screen_ind:get_value(0) and engine.is_connected() then
			local pos = {x = keybinds_x:get_value(), y = keybinds_y:get_value()}
			local alphak, keybinds = {}, {}
			local width, maxwidth = 39, 0;
			local height = 19;
			local bind_y = height + 5
			
			for i,v in pairs(bind) do
				local exploits = ui.get_combo_box("rage_active_exploit"):get_value(); 
				v.add = math.lerp(v.add, v.reference:is_active() and 255 or 0, 0.4);
				v.multiply = v.add > 4 and 1 or 0;
				if v.add > 4 then 
					if v.exploit == 0 then 
						table.insert(keybinds, i) 
					end; 
					if v.exploit ~= 0 and exploits == v.exploit then 
						table.insert(keybinds, i) 
					end; 
				end;
				if v.exploit == 0 and v.reference:is_active() then 
					table.insert(alphak, i) 
				end; 
				if v.exploit ~= 0 and exploits == v.exploit and v.reference:is_active() then 
					table.insert(alphak, i) 
				end;
			end

			if #alphak ~= 0 or ui.is_visible() then alpha[1] = math.lerp(alpha[1], 255, 0.1) end; if #alphak == 0 and not ui.is_visible() then alpha[1] = math.lerp(alpha[1], 0, 0.1) end		
			for k,f in pairs(keybinds) do if renderer.get_text_size(fonts, 12, f .. "["..types[bind[f].reference:get_type() + 1].."]").x > maxwidth then maxwidth = renderer.get_text_size(fonts, 12, f .. "["..types[bind[f].reference:get_type() + 1].."]").x; end; end
			if maxwidth == 0 then maxwidth = 50 end; width = width + maxwidth; if width < 140 then width = 140 end if animwidth == 0 then animwidth = width end; animwidth = math.lerp(animwidth, width, 0.1)
			w = auto_resize_width:get_value() and (animation_type:get_value() == 1 and animwidth or width) or 140
			for k,f in pairs(keybinds) do  
				local v = bind[f]; bind_y = bind_y + (animation_type:get_value() == 1 and 20 * (v.add / 255) or 20 * v.multiply); plus = bind_y - (animation_type:get_value() == 1 and 20 * (v.add / 255) or 20 * v.multiply);
				renderer.text(f, fonts, vec2_t.new(pos.x + 5, pos.y + plus + 1), 12, color_t.new(0, 0, 0, 255 * (v.add / 255)))
				renderer.text(f, fonts, vec2_t.new(pos.x + 4, pos.y + plus), 12, color_t.new(255, 255, 255, 255 * (v.add / 255)))
				renderer.text("  "..types[v.reference:get_type() + 1].."  ", fonts, vec2_t.new(pos.x + w - renderer.get_text_size(fonts, 12, "["..types[v.reference:get_type() + 1].."]").x - 3, pos.y + plus + 1), 12, color_t.new(0, 0, 0, 255 * (v.add / 255)))
				renderer.text("  "..types[v.reference:get_type() + 1].."  ", fonts, vec2_t.new(pos.x + w - renderer.get_text_size(fonts, 12, "["..types[v.reference:get_type() + 1].."]").x - 4, pos.y + plus), 12, color_t.new(255, 255, 255, 255 * (v.add / 255)))
			end
			if alpha[1] > 1 then
				filledbox(pos.x, pos.y, w, height, (alpha[1] / 255))
				renderer.text("keybinds", fonts, vec2_t.new(pos.x + (w /2) - (renderer.get_text_size(fonts, 12, "keybinds").x /2) + 1, pos.y + 3), 12, color_t.new(0, 0, 0, 255 * (alpha[1] / 255)))
				renderer.text("keybinds", fonts, vec2_t.new(pos.x + (w /2) - (renderer.get_text_size(fonts, 12, "keybinds").x /2), pos.y + 3), 12, color_t.new(255, 255, 255, 255 * (alpha[1] / 255)))
				drag(pos.x, pos.y, w, height + 2, keybinds_x, keybinds_y, item)
			end
		end
	end
	watermark(); keybinds();
end)






local function create_move()
    local players = entitylist.get_players(0)

    if mindamage_keybind:is_active() == true then
        for i = 1, #players do
            local player = players[i]
          
            ragebot.override_min_damage(player:get_index(), mindamage_value:get_value())
          
        end
    end
end

client.register_callback("create_move", create_move)



local function create_move()
    local players = entitylist.get_players(0)

    if mindamage_keybind:is_active() == true then
        for i = 1, #players do
            local player = players[i]
          
            ragebot.override_min_damage(player:get_index(), mindamage_value:get_value())
          
        end
    end
end

client.register_callback("create_move", create_move)

local function baim()

	local players = entitylist.get_players(0)
  
	for i = 1, #players do
			local entity_index = players[i]:get_index()
			if fb_bind:is_active() then
				ragebot.override_hitscan(entity_index, 0, false)
			end
	end
  end
  
  client.register_callback("create_move", baim)





local function create_move()
    local players = entitylist.get_players(0)

    if mindamage_keybind:is_active() == true then
        for i = 1, #players do
            local player = players[i]
          
            ragebot.override_min_damage(player:get_index(), mindamage_value:get_value())
          
        end
    end
end

client.register_callback("create_move", create_move)

local function on_create_move(cmd)
    local override = {
        PingSpike = { PingSpikeKey:is_active(), PingSpikeValue:get_value() }
    }
    if override.PingSpike[1] then
        local ping = ui.get_slider_int("misc_ping_spike_amount")
        ping:set_value(override.PingSpike[2])
    else
        local ping = ui.get_slider_int("misc_ping_spike_amount")
        ping:set_value(0)
    end
        if ignore_head:is_active() then
			ragebot.override_hitscan(player:get_index(), 0, false)
    end
end
client.register_callback('create_move', on_create_move)
client.register_callback("paint", on_paint)







local ind_under_cross = ui.add_check_box("Crosshair Indicator", "ind_under_cross", false)
local verdana = renderer.setup_font("C:/windows/fonts/verdana.ttf", 12, 0)
local x_offset = ui.add_slider_int("X offset", "indicators_x_offset", -100, 100, 3)
local y_offset = ui.add_slider_int("Y offset", "indicators_y_offset", -100, 100, 1)
local center = ui.add_check_box("Center", "indicators_cetner", true)
local m_vecVelocity = {
    [0] = se.get_netvar("DT_BasePlayer", "m_vecVelocity[0]"),
    [1] = se.get_netvar("DT_BasePlayer", "m_vecVelocity[1]")
}



local function hsv2rgb(h, s, v, a)
    local r, g, b

    local i = math.floor(h * 6);
    local f = h * 6 - i;
    local p = v * (1 - s);
    local q = v * (1 - f * s);
    local t = v * (1 - (1 - f) * s);

    i = i % 6

    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q
    end

    return color_t.new(r * 255, g * 255, b * 255, a * 255)
end

color1 = color1 or color_t.new(0, 0, 0, 255)

--function for fast indicator adding
local function indicator(var, name, color, logic)
    logic = logic or nil
    return {
        ["var"] = var,
        ["name"] = name,
        ["color"] = color,
        ["alpha"] = 0,
        ["logic"] = logic
    }
end


--some shit
local function clamp(v, min, max) return math.min(math.max(v, min), max) end
local bind = ui.get_key_bind
local active_exploit, active_exploit_bind = ui.get_combo_box("rage_active_exploit"), ui.get_key_bind("rage_active_exploit_bind")
function get_cond()
    localPlayer = entitylist.get_local_player()
    m_hGroundEntity = localPlayer:get_prop_int(se.get_netvar("DT_BasePlayer", "m_hGroundEntity"))
    duck = localPlayer:get_prop_int(se.get_netvar("DT_BasePlayer", "m_bDucked"))
    velocity = math.sqrt(localPlayer:get_prop_float(m_vecVelocity[0]) ^ 2 + localPlayer:get_prop_float(m_vecVelocity[1]) ^ 2)
    if m_hGroundEntity == -1 then
        return "in air"
    elseif m_hGroundEntity ~= -1 and duck == 1 then
        return "crouch"
    elseif m_hGroundEntity ~= -1 and velocity > 5 then
        if not slowWalkBint:is_active() then
            return "move"
        else
            return "slowwalk"
        end
    elseif m_hGroundEntity ~= -1 and velocity < 5 then
        return "stand"
    end
end


--defining array with indicators
 local local_player = entitylist.get_local_player()
 
local indicators = {
    indicator(nil, "", color_t.new(213, 213, 46, 255), function() return true end), --0.486, 0.482, 0.988
        indicator(nil, "avira.lua", color_t.new(255, 255, 255, 255), function() return true end), --0.486, 0.482, 0.988          
    indicator(nil, "DT", color_t.new(255, 255, 255, 255), function()
        return (active_exploit:get_value() == 2 and active_exploit_bind:is_active())
    end),
    indicator(nil, "HS", color_t.new(255, 255, 255, 255), function()
        return (active_exploit:get_value() == 1 and active_exploit_bind:is_active())
    end),
    indicator(bind("antihit_extra_fakeduck_bind"), "DUCK",color_t.new(255, 255, 255, 255)),

    indicator(mindamage_keybind, "DMG", color_t.new(255, 255, 255, 255)),

    indicator(bind("antihit_extra_autopeek_bind"), "PEEK", color_t.new(255, 255, 255, 255)),

    indicator(fb_bind, "BODY",color_t.new(255, 255, 255, 255)),


    indicator(PingSpikeKey, "PING", color_t.new(255, 255, 255, 255)),

}



local margin, speed, size = 11, 11, 11
local font = renderer.setup_font("c:/windows/fonts/verdana.ttf", 11, 0)
client.register_callback("paint", function ()
    local lp = entitylist.get_local_player()
    if not lp:is_alive() then return end
    local speed = speed * globalvars.get_absolute_frametime() * 120
    local screen = engine.get_screen_size()
    local centering = center:get_value() and 1 or 0
    local cx = screen.x / 2 + x_offset:get_value()
    local cy = screen.y / 2
    local y = cy + 9 + y_offset:get_value()
    for i = 1, #indicators do
        local bind = indicators[i]
        local active = (bind.var ~= nil and bind.var:is_active()) or (bind.var == nil and bind.logic())
        if not ind_under_cross:get_value() then return end
        bind.alpha = clamp(bind.alpha + (active and speed or (speed * -1)), 0, 1)
        if bind.alpha == 0 then goto skip end
        local text_size = renderer.get_text_size(font, size, bind.name)
        local bx, by, col = cx - ((text_size.x / 2) * centering), y - margin + (bind.alpha * margin), bind.color
        col.a = bind.alpha * 255
        renderer.text(bind.name, font, vec2_t.new(bx, by + 1), size, color_t.new(0, 0, 0, col.a / 1))
        renderer.text(bind.name, font, vec2_t.new(bx, by), size, col)
        y = y + (bind.alpha * margin)
        ::skip::
    end
end)










            



-- updater: anthologie
-- Improved by: ListerStellar#0017

local messagesRU = {
    "хуйпачос падает)))",
    "уебище падает изично я рот ебал",
    "1",
    "хуйпаклык оправдайся",
    "что,supenepasta.tech не забустила?(",
    "печально что ты долбоёб",
    "so easy for avira.technology",
    "не устану орать тебе в ебало nixware > all",
    "avira > your mother",
    "brain?",
    "нет мозгов считай нл юзер",
    "ахуеть уебище",
    "навернека в консоли Missed shot due to resolver",
    "чё чит высрал? misprediction/prediction/resolver ?",
    "не я рот ебал ты такой изичный",
    "купи нормальный скрипт - nixware.cc/threads/20633 , не позорься",
    "ez owned by avira.technology",
    "пизда у меня пингануло",
    "сука найс конфиг ретард, надамажить смог((",
    "ацыдтек? не, не слышал (◣_◢)",
    "не ну этот хуйпачос падает сочно",
    "ретарднутое чудо выйди нахуй отсюда",
    "отсосёшь мне за кряк рейвтрипа?)",
    "сосать уебище, оправдания в хуй жду.",
   
}

local deathmsg = {
    "СУКА Я ПИНГСПАЙК ОТЖАЛ",
   "блять миндамаг слетел ебанный никсвар",
   "не я рот ебал этой игры",
   "радуйся 2 минуты уебище лохматое",
   "у вас тоже в консоли миссед шот дуе то коррекшн?",
    "НУ ЭТОТ ЕБАННЫЙ НЕВЕРПАСТА УЗЕР",
    "не буду оправдаваться. - Kawasaki",
    "хуйпачос хуйпасос - fipp1337",
    "блять ну какого хуя вылетел резольвер я рот ебал этой жизни",
}

local trashtalk_enabled = ui.add_check_box("Trashtalk", "trashtalk_enabled", false)



client.register_callback("player_death", function(event)
   
    local attacker_index = engine.get_player_for_user_id(event:get_int("attacker",0))
    local died_index = engine.get_player_for_user_id(event:get_int("userid",1))
    local me = engine.get_local_player()
   
    math.randomseed(os.clock()*100000000000)

        if attacker_index == me and died_index ~= me then     
            if trashtalk_enabled:get_value()  then   
                engine.execute_client_cmd("say " .. tostring(messagesRU[math.random(0, #messagesRU)]))
            end
        end  
        if attacker_index ~= me and died_index == me then
            if trashtalk_enabled:get_value() then
                engine.execute_client_cmd("say " .. tostring(deathmsg[math.random(0, #deathmsg)]))
            end
        end
end)





    math.randomseed(os.clock()*100000000000)

      




local tahomabd = renderer.setup_font("C:/windows/fonts/tahomabd.ttf", 12, 0)

local enable = ui.add_check_box("Enable", "enable", false)
local calibrib23 = renderer.setup_font("C:/windows/fonts/calibrib.ttf", 23, 0)
local m_vecVelocity = {
    [0] = se.get_netvar("DT_BasePlayer", "m_vecVelocity[0]"),
    [1] = se.get_netvar("DT_BasePlayer", "m_vecVelocity[1]")
}
local velocity = nil
local curtick = 0
local planting = false
local fill = 0
local bombsiteonplant = ""
local on_plant_time = 0
local bombsite = 0
local APlants = 0
local player = entitylist.get_entity_by_index(engine.get_local_player())
  
function getSite(c4)
    local bombsite = c4:get_prop_float(se.get_netvar("DT_PlantedC4", "m_nBombSite"))
    if bombsite == 0 then
        return "A - ";
    else
        return "B - ";
    end
end
local function render_arc( x, y, r1, r2, s, d, col )
    local i = s
  
    while i < s + d do
        i = i + 1
      
        local m_rad = i * math.pi / 180
        renderer.line( vec2_t.new( x + math.cos( m_rad ) * r1, y + math.sin( m_rad ) * r1 ), vec2_t.new( x + math.cos( m_rad ) * r2, y + math.sin( m_rad ) * r2 ), col )
  
    end
end
Render_OutlineCircle = function(x, y, what, col)
    render_arc(x, y, 10, 5, 32, 360, color_t.new(0, 0, 0, 255));
    render_arc(x, y, 9, 6, 32, 360 * what, col);
    --render_arc(x, y, 9, 4, 0, 360, 32, [0, 0, 0, 255])
    --render_arc(x, y, 8, 5, 0, what * 360, 32, col)
end
client.register_callback("bomb_beginplant", function(event)
    on_plant_time = globalvars.get_current_time();
    bombsite = event:get_int("site", 0);
    APlants = (454 or 372 or 102 or 276 or 174 or 121 or 301 or 142 or 408 or 97 or 213 or 216)
    if bombsite == APlants then
        bombsiteonplant = "A"
    else
        bombsiteonplant = "B"
    end
    planting = true
end)
local offsets =
{
    m_flC4Blow = se.get_netvar("DT_PlantedC4", "m_flC4Blow"),
    m_flDefuseCountDown = se.get_netvar( "DT_PlantedC4", "m_flDefuseCountDown" ),
    m_flTimerLength = se.get_netvar( "DT_PlantedC4", "m_flTimerLength" ),
    m_hBombDefuser = se.get_netvar( "DT_PlantedC4", "m_hBombDefuser" ),
    m_bStartedArming = se.get_netvar( "DT_WeaponC4", "m_bStartedArming" ),
    m_fArmedTime = se.get_netvar( "DT_WeaponC4", "m_fArmedTime" ),
    m_flDefuseLength = se.get_netvar( "DT_PlantedC4", "m_flDefuseLength" ),
    m_bombsiteCenterA = se.get_netvar( "DT_CSPlayerResource", "m_bombsiteCenterA" ),
    m_bombsiteCenterB = se.get_netvar( "DT_CSPlayerResource", "m_bombsiteCenterB" ),
}
local bomb_site = nil
client.register_callback("bomb_abortplant", function()
    on_plant_time = 0
    fill = 0
    planting = false
end)
client.register_callback("bomb_defused", function()
    on_plant_time = 0
    fill = 0
    planting = false
end)
client.register_callback("bomb_planted", function()
    on_plant_time = 0
    fill = 0
    planting = false
end)
client.register_callback("round_start", function()
    on_plant_time = 0
    fill = 0
    planting = false
    curtick = globalvars.get_tick_count()
end)
local function skeepaste()
    screen = engine.get_screen_size()
    --isBody = force_body:is_active()
  
  
    isAt = ui.get_check_box("antihit_antiaim_at_targets"):get_value()
    isDoubletap = ui.get_key_bind("rage_active_exploit_bind"):is_active() and ui.get_combo_box("rage_active_exploit"):get_value() == 2
    isDuck = ui.get_key_bind("antihit_extra_fakeduck_bind"):is_active() and ui.get_check_box("antihit_extra_fakeduck")
    isHideshots = ui.get_key_bind("rage_active_exploit_bind"):is_active() and ui.get_combo_box("rage_active_exploit"):get_value() == 1
    isPeek = ui.get_key_bind("antihit_extra_autopeek_bind"):is_active() and ui.get_check_box("antihit_extra_autopeek")
    --isSafe = ui.get_combo_box("rage_pistols_safepoints"):get_value() == 2
    fakelag1 = clientstate.get_choked_commands()
    isDmg = mindamage_keybind:is_active()
    cur_dmg = mindamage_value:get_value()
    isshit = mindamage_value:get_value()
    isPing = PingSpikeKey:is_active()
    --fix_posdmg = renderer.get_text_size(tahomabd, 12, "" .. cur_dmg .. "").x / 2
    add_y = 0


    
   
  
    Render_Indicator = function(text, col)
        x = screen.x / 100
        y = screen.y / 1.33
      
        text_size = renderer.get_text_size(calibrib23, 23, text)
        width = text_size.x + 30;
        add_y = add_y + 33
        renderer.rect_filled_fade(vec2_t.new(13, y - add_y - 3), vec2_t.new(width / 2 , y - add_y - 2), color_t.new(0, 0, 0, 0), color_t.new(0, 0, 0, 10), color_t.new(0, 0, 0, 10), color_t.new(0, 0, 0, 0))
        renderer.rect_filled_fade(vec2_t.new((width / 2), y - add_y - 3), vec2_t.new(width - 13, y - add_y - 2 ), color_t.new(0, 0, 0, 10), color_t.new(0, 0, 0, 0), color_t.new(0, 0, 0, 0), color_t.new(0, 0, 0, 10))
        renderer.rect_filled_fade(vec2_t.new(13, y - add_y - 3 + 27), vec2_t.new(width / 2 , y - add_y + 2 + 21), color_t.new(0, 0, 0, 0), color_t.new(0, 0, 0, 10), color_t.new(0, 0, 0, 10), color_t.new(0, 0, 0, 0))
        renderer.rect_filled_fade(vec2_t.new((width / 2), y - add_y - 3 + 27), vec2_t.new(width - 13, y - add_y + 2 + 21), color_t.new(0, 0, 0, 10), color_t.new(0, 0, 0, 0), color_t.new(0, 0, 0, 0), color_t.new(0, 0, 0, 10))
        renderer.rect_filled_fade(vec2_t.new(13, y - add_y - 3), vec2_t.new(width / 2 , y - add_y + 24), color_t.new(0, 0, 0, 0), color_t.new(0, 0, 0, 55), color_t.new(0, 0, 0, 55), color_t.new(0, 0, 0, 0))
        renderer.rect_filled_fade(vec2_t.new((width / 2), y - add_y - 3), vec2_t.new(width - 13, y - add_y + 24 ), color_t.new(0, 0, 0, 55), color_t.new(0, 0, 0, 0), color_t.new(0, 0, 0, 0), color_t.new(0, 0, 0, 55))
        renderer.text(text, calibrib23, vec2_t.new(x, y + 1 - add_y), 23, color_t.new(33, 33, 33, 180))
        renderer.text(text, calibrib23, vec2_t.new(x, y - add_y), 23, col)
    end
    fill = 3.125 - (3.125 + on_plant_time - globalvars.get_current_time())
    if fill > 3.125 then
        fill = 3.125
    end
    --[[if isBody then
        Render_Indicator("BAIM", color_t.new(255, 0, 0, 255))
    end--]]
  
  
    if isPing then
        Render_Indicator("PING", color_t.new(123, 194, 21, 255))
    end
  
    if isDmg then
      
        Render_Indicator("Damage : " .. cur_dmg .. "", color_t.new(255, 255, 255, 200));
      
          
      
    end

    
    if isPeek then
        Render_Indicator("PEEK", color_t.new(255, 255, 255, 200));
    end
    --convar:get_int()
    if se.get_convar("weapon_accuracy_nospread"):get_int() ~= 0 then
        Render_Indicator("NS", color_t.new(255, 0, 0, 255))
    end
    if isAt then
        Render_Indicator("AT", color_t.new(123, 194, 21, 255))
    end

    if isshit then
        Render_Indicator(""..hits.." / "..misses.."", color_t.new(255, 255, 255, 200))
    end

    --if isFLind then
    textsize_FL = renderer.get_text_size(calibrib23, 23, "FL").x + 15
  
    --Render.OutlineCircle(x + textsize_FL, y - 25 - add_y + 35, (Globals.ChokedCommands() / 14), [135, 147, 255, 255])
--end
if player then
    velocity = math.sqrt(player:get_prop_float(m_vecVelocity[0]) ^ 2 + player:get_prop_float(m_vecVelocity[1]) ^ 2)
end
if (velocity > 255 and velocity < 275) then
    Render_Indicator("LC", color_t.new(255, 0, 0, 255))
elseif (velocity > 275) then
    Render_Indicator("LC", color_t.new(123, 194, 21, 255))
end
if isHideshots then
    Render_Indicator("ONSHOT", color_t.new(123, 194, 21, 255))
end
if isDuck then
    Render_Indicator("DUCK", color_t.new(255, 255, 255, 200))
end
if isDoubletap then
    Render_Indicator("DT", color_t.new(255, 255, 255, 200))
end
    local bombs_planted = entitylist.get_entities_by_class( "CPlantedC4" )
  
    if planting then
        textsize_C4 = renderer.get_text_size(calibrib23, 23, "Bombsite " .. bombsiteonplant).x + 15;
        Render_Indicator("Bombsite " .. bombsiteonplant, color_t.new(252, 243, 105, 255))
        Render_OutlineCircle(x + textsize_C4, y - 25 - add_y + 35, fill / 3.3, color_t.new(255, 255, 255, 200))
    end
    if #bombs_planted == 1 then
        Render_Indicator("Bombsite " .. bombsiteonplant, color_t.new(252, 243, 105, 255))
      
      
    end
end
draww = function ()
    if enable:get_value() and engine.is_connected() and entitylist.get_local_player():is_alive() then
    skeepaste()
    end
end
client.register_callback("paint", draww)






function on_paint()
    -- Script tabs
    if script_tabs:get_value() ~= 0 then
        doubletap:set_visible(false)
        hide_shots:set_visible(false)
        PingSpikeKey:set_visible(false)
        fb_bind:set_visible(false)
        mindamage_keybind:set_visible(false)
    else
        PingSpikeKey:set_visible(true)
        mindamage_keybind:set_visible(true)
        fb_bind:set_visible(true)
        hide_shots:set_visible(true)
        doubletap:set_visible(true)
    end

    if script_tabs:get_value() ~= 1 then 
        mindamage_value :set_visible(false)
        PingSpikeValue:set_visible(false)
	else
        mindamage_value :set_visible(true)
        PingSpikeValue:set_visible(true)
	end

	if script_tabs:get_value() ~= 2 then 
        keybinds_y:set_visible(false)
        keybinds_x:set_visible(false)
        color_line:set_visible(false)
        chroma_dir:set_visible(false)
        style_line:set_visible(false)
        auto_resize_width:set_visible(false)
        animation_type:set_visible(false)
        watermarkusername:set_visible(false)
        screen_ind:set_visible(false)
      
	else
        keybinds_y:set_visible(false)
        keybinds_x:set_visible(false)
        color_line:set_visible(true)
        chroma_dir:set_visible(false)
        style_line:set_visible(false)
        auto_resize_width:set_visible(false)
        animation_type:set_visible(true)
        watermarkusername:set_visible(true)
        screen_ind:set_visible(true)
      
	end

    if script_tabs:get_value() ~= 3 then 
    antiaim:set_visible(false)
    else
      antiaim:set_visible(true)

    end
    if script_tabs:get_value() ~= 4 then
        trashtalk_enabled:set_visible(false)
        enable:set_visible(false)
        ind_under_cross:set_visible(false)
        x_offset:set_visible(false)
        y_offset:set_visible(false)
        center:set_visible(false)
        clantag:set_visible(false)
        clantag_speed:set_visible(false)
        menu.logs:set_visible(false)
        menu.position:set_visible(false)
        menu.limit:set_visible(false)
        menu.damage_dealt_color:set_visible(false)
        menu.damage_received_color:set_visible(false)
        menu.misses_color:set_visible(false)
        menu.purchases_color:set_visible(false)
        menu.text_color:set_visible(false)
    else  
        ind_under_cross:set_visible(true)
        x_offset:set_visible(false)
        y_offset:set_visible(false)
        center:set_visible(false)
        trashtalk_enabled:set_visible(true)
        clantag:set_visible(true)
        clantag_speed:set_visible(false)
        enable:set_visible(true)
        menu.logs:set_visible(true)
        menu.position:set_visible(true)
        menu.limit:set_visible(false)
        menu.damage_dealt_color:set_visible(false)
        menu.damage_received_color:set_visible(false)
        menu.misses_color:set_visible(false)
        menu.purchases_color:set_visible(false)
        menu.text_color:set_visible(true)
    end

end
client.register_callback("create_move", on_create_move)
client.register_callback("paint", on_paint)
end
