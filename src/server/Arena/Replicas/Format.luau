export type FaceStringSpecial = "normal_special"
    | "shy_special" | "scared_special" | "dead_special" | "no_mouth_special"
    | "laughing_special" | "angry_special" | "unamused_special"
    | "nerd_special" | "happy_special" | "looking_special" | "alien_special"

    | "att_def_tru_icon_special" | "click_button_icon_special" | "color_event_icon_special"
    | "combo_event_icon_special" | "even_odd_event_icon_special"

export type FaceString = "normal"
    | "shy" | "scared" | "dead" | "no_mouth"
    | "laughing" | "angry" | "unamused"
    | "nerd" | "happy" | "looking" | "alien"

    | "att_def_tru_icon" | "click_button_icon" | "color_event_icon"
    | "combo_event_icon" | "even_odd_event_icon"
    | FaceStringSpecial

export type FaceObject = { text: string, face: FaceString? }
export type Face = FaceString | FaceObject

export type Template = {
    text: string,
    requiredKeys: {string}?,
    face: Face?
}

return function(template: Template, data: {[string]: any}?): { text: string, face: Face }
    if template.requiredKeys then
        for _, key in ipairs(template.requiredKeys) do
            if data == nil or data[key] == nil then
                warn("No key found for '" .. template.text .. "'. Key: " .. key)
            end
        end
    end

    local text = template.text
    if data ~= nil then
        text = template.text:gsub("{(.-)}", function(key)
            local value = data[key]
            if typeof(value) == "Instance" and value:IsA("Player") then
                return value.DisplayName
            end
            return tostring(value or "{" .. key .. "}")
        end)
    end

    return { text = text, face = template.face }
end