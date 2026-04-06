obs = obslua

time_file_path = ""
chrono_file_path = ""
interval = 1000
time_source_name = ""
chrono_source_name = ""
previous_time = ""
previous_chrono = ""

-- ------------------------------------------------------------

function update_source(source_name, file_path, previous_content)
    local source = obs.obs_get_source_by_name(source_name)
    if source ~= nil then
        local file = io.open(file_path, "r")

        if file ~= nil then
            local text = file:read("*a")
            file:close()

            if text ~= previous_content then
                local settings = obs.obs_data_create()
                obs.obs_data_set_string(settings, "text", text)
                obs.obs_source_update(source, settings)
                obs.obs_data_release(settings)
                previous_content = text
            end
        else
            obs.script_log(obs.LOG_WARNING, "File not found: " .. file_path)
        end

        obs.obs_source_release(source)
    end
    return previous_content
end

function update_texts()
    if time_file_path ~= "" and time_source_name ~= "" then
        previous_time = update_source(time_source_name, time_file_path, previous_time)
    end
    if chrono_file_path ~= "" and chrono_source_name ~= "" then
        previous_chrono = update_source(chrono_source_name, chrono_file_path, previous_chrono)
    end
end

function refresh_pressed(props, prop)
    update_texts()
    return true
end

-- ------------------------------------------------------------

function script_description()
    return "Updates two text sources (time and chrono) from files at specified intervals."
end

function script_update(settings)
    time_file_path = obs.obs_data_get_string(settings, "time_file_path")
    chrono_file_path = obs.obs_data_get_string(settings, "chrono_file_path")
    interval = obs.obs_data_get_int(settings, "interval")
    time_source_name = obs.obs_data_get_string(settings, "time_source")
    chrono_source_name = obs.obs_data_get_string(settings, "chrono_source")

    obs.timer_remove(update_texts)

    local time_ready = time_file_path ~= "" and time_source_name ~= ""
    local chrono_ready = chrono_file_path ~= "" and chrono_source_name ~= ""

    if time_ready or chrono_ready then
        obs.timer_add(update_texts, interval)
    end
end

function script_defaults(settings)
    obs.obs_data_set_default_int(settings, "interval", 100)
end

function script_properties()
    local props = obs.obs_properties_create()

    obs.obs_properties_add_text(props, "time_file_path", "Time File Path", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_text(props, "chrono_file_path", "Chrono File Path", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_int(props, "interval", "Update Interval (ms)", 10, 10000, 1)

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

    obs.obs_properties_add_button(props, "refresh", "Refresh", refresh_pressed)

    return props
end
