obs = obslua

time_source_name = ""
chrono_source_name = ""
race_start_str = ""
race_end_str = ""
interval = 200

race_start_ts = nil
race_end_ts = nil
max_chrono_secs = nil

-- ------------------------------------------------------------

function parse_datetime(str)
    local y, mo, d, h, m, s = str:match("(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
    if y then
        return os.time({
            year = tonumber(y), month = tonumber(mo), day = tonumber(d),
            hour = tonumber(h), min = tonumber(m), sec = tonumber(s)
        })
    end
    return nil
end

function to_hhmmss(secs)
    local h = math.floor(secs / 3600)
    local m = math.floor((secs % 3600) / 60)
    local s = secs % 60
    return string.format("%02d:%02d:%02d", h, m, s)
end

function set_source_text(source_name, text)
    local source = obs.obs_get_source_by_name(source_name)
    if source ~= nil then
        local settings = obs.obs_data_create()
        obs.obs_data_set_string(settings, "text", text)
        obs.obs_source_update(source, settings)
        obs.obs_data_release(settings)
        obs.obs_source_release(source)
    end
end

function update_texts()
    local now = os.time()

    if time_source_name ~= "" then
        set_source_text(time_source_name, os.date("%H:%M:%S", now))
    end

    if chrono_source_name ~= "" and race_start_ts ~= nil and max_chrono_secs ~= nil then
        local elapsed = now - race_start_ts
        if elapsed < 0 then elapsed = 0 end
        if elapsed > max_chrono_secs then elapsed = max_chrono_secs end
        set_source_text(chrono_source_name, to_hhmmss(elapsed))
    end
end

-- ------------------------------------------------------------

function script_description()
    return "Updates two OBS text sources with the current time and race chrono."
end

function script_update(settings)
    time_source_name = obs.obs_data_get_string(settings, "time_source")
    chrono_source_name = obs.obs_data_get_string(settings, "chrono_source")
    race_start_str = obs.obs_data_get_string(settings, "race_start")
    race_end_str = obs.obs_data_get_string(settings, "race_end")
    interval = obs.obs_data_get_int(settings, "interval")

    race_start_ts = parse_datetime(race_start_str)
    local race_end_ts_local = parse_datetime(race_end_str)

    if race_start_ts ~= nil and race_end_ts_local ~= nil then
        max_chrono_secs = race_end_ts_local - race_start_ts
    else
        max_chrono_secs = nil
    end

    obs.timer_remove(update_texts)

    if time_source_name ~= "" or chrono_source_name ~= "" then
        obs.timer_add(update_texts, interval)
    end
end

function script_defaults(settings)
    obs.obs_data_set_default_int(settings, "interval", 200)
end

function script_properties()
    local props = obs.obs_properties_create()

    local function add_source_list(prop_name, label)
        local p = obs.obs_properties_add_list(
            props, prop_name, label,
            obs.OBS_COMBO_TYPE_EDITABLE,
            obs.OBS_COMBO_FORMAT_STRING
        )
        local sources = obs.obs_enum_sources()
        if sources ~= nil then
            for _, source in ipairs(sources) do
                local source_id = obs.obs_source_get_unversioned_id(source)
                if source_id == "text_gdiplus" or source_id == "text_ft2_source" then
                    local name = obs.obs_source_get_name(source)
                    obs.obs_property_list_add_string(p, name, name)
                end
            end
            obs.source_list_release(sources)
        end
    end

    add_source_list("time_source", "Time Text Source")
    add_source_list("chrono_source", "Chrono Text Source")

    obs.obs_properties_add_text(props, "race_start", "Race Start (YYYY-MM-DD HH:MM:SS)", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(props, "race_end", "Race End (YYYY-MM-DD HH:MM:SS)", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_int(props, "interval", "Update Interval (ms)", 100, 10000, 100)

    return props
end
