_G.Saw_Noise_Indicator = _G.Saw_Noise_Indicator or {}
Saw_Noise_Indicator._path = ModPath
Saw_Noise_Indicator.data_path = SavePath .. 'Saw_Noise_Indicator.txt'
Saw_Noise_Indicator.silent_deadline = 0
Saw_Noise_Indicator.default_settings = {
	enabled = true,
	prediction_value = 0.50,
	loud_saw_effect = true,
	silent_saw_color = "7FFF00",
	loud_saw_color = "8B0000",
	palettes = { --for ColorPicker
		"ADFF2F",
		"7FFF00",
		"7CFC00",
		"00FF00",
		"32CD32",
		"00FA9A",
		"3CB371",
		"228B22",
		"008000",
		"9ACD32",
		"556B2F",
		"00FFFF",
		"AFEEEE",
		"40E0D0",
		"7FFFD4",
		"C71585",
		"CD5C5C",
		"F08080",
		"FA8072",
		"E9967A",
		"FFA07A",
		"DC143C",
		"FF0000",
		"B22222",
		"8B0000"
	}
}
Saw_Noise_Indicator.settings = table.deep_map_copy(Saw_Noise_Indicator.default_settings)

function Saw_Noise_Indicator:set_colorpicker_menu(menu)
	Saw_Noise_Indicator._colorpicker = menu
end

function Saw_Noise_Indicator.clbk_show_colorpicker_with_callbacks(color, changed_callback, done_callback)
	Saw_Noise_Indicator._colorpicker:Show({color = color,changed_callback = changed_callback,done_callback = done_callback,palettes = Saw_Noise_Indicator:GetPaletteColors(),blur_bg_x = 750})
end

function Saw_Noise_Indicator:GetPaletteColors()
	local result = {}
	for i,hex in ipairs(self.settings.palettes) do 
		result[i] = Color(hex)
	end
	return result
end

function Saw_Noise_Indicator:SetPaletteCodes(tbl)
	if type(tbl) == "table" then 
		for i,color in ipairs(tbl) do 
			self.settings.palettes[i] = color:to_hex()
		end
	else
		self:log("Error: SetPaletteCodes(" .. tostring(tbl) .. ") Bad palettes table from ColorPicker callback")
	end
end

function Saw_Noise_Indicator:IsEnabled()
	return self.settings.enabled
end

function Saw_Noise_Indicator:DebugEnabled() 
	return false
end

function Saw_Noise_Indicator:log(a,...)
	if not self:DebugEnabled() then 
		return
	end
	if Console then
		return Console:Log(a,...)
	else
		return log("[Saw_Noise_Indicator] " .. tostring(a))
	end
end

function Saw_Noise_Indicator:Save()
	local file = io.open(self.data_path,"w+")
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

function Saw_Noise_Indicator:Load()
	local file = io.open(self.data_path, "r")
	if (file) then
		for k, v in pairs(json.decode(file:read("*all"))) do
			self.settings[k] = v
		end
	else
		self:Save()
	end
end

function Saw_Noise_Indicator:LoadTextures()
	for _, file in pairs(file.GetFiles(Saw_Noise_Indicator._path.. "assets/guis/textures/")) do
		DB:create_entry(Idstring("texture"), Idstring("assets/guis/textures/".. file:gsub(".texture", "")), Saw_Noise_Indicator._path.. "assets/guis/textures/".. file)
	end
end

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_Saw_Noise_Indicator", function( loc )
	if file.DirectoryExists(Saw_Noise_Indicator._path .. "loc/") then
		for _, filename in pairs(file.GetFiles(Saw_Noise_Indicator._path .. "loc/")) do
			local str = filename:match('^(.*).json$')
			if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
				loc:load_localization_file(Saw_Noise_Indicator._path .. "loc/" .. filename)
				break
			end
		end
	end
	loc:load_localization_file(Saw_Noise_Indicator._path .. "loc/english.json", false)
end)

Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_Saw_Noise_Indicator", function(menu_manager)
	MenuCallbackHandler.Saw_Noise_Indicator_toggle = function(self, item)
		Saw_Noise_Indicator.settings[item:name()] = (item:value() == "on")
		Saw_Noise_Indicator:Save()
	end
	
	MenuCallbackHandler.Saw_Noise_Indicator_value = function(self, item)
		Saw_Noise_Indicator.settings[item:name()] = item:value()
		Saw_Noise_Indicator:Save()
	end
	MenuCallbackHandler.callback_Saw_Noise_Indicator_silent_saw_color = function(self, item)
		local function clbk_colorpicker (color, palettes, success)
			--save color to settings
			if success then 
				Saw_Noise_Indicator.settings.silent_saw_color = color:to_hex()
				Saw_Noise_Indicator:Save()
			end
			--save palette swatches to settings
			if palettes then 
				Saw_Noise_Indicator:SetPaletteCodes(palettes)
			end
		end
		Saw_Noise_Indicator.clbk_show_colorpicker_with_callbacks(Color(Saw_Noise_Indicator.settings.silent_saw_color), clbk_colorpicker, clbk_colorpicker)
	end
	
	MenuCallbackHandler.callback_Saw_Noise_Indicator_loud_saw_color = function(self, item)
		local function clbk_colorpicker (color, palettes, success)
			--save color to settings
			if success then 
				Saw_Noise_Indicator.settings.loud_saw_color = color:to_hex()
				Saw_Noise_Indicator:Save()
			end
			--save palette swatches to settings
			if palettes then 
				Saw_Noise_Indicator:SetPaletteCodes(palettes)
			end
		end
		Saw_Noise_Indicator.clbk_show_colorpicker_with_callbacks(Color(Saw_Noise_Indicator.settings.loud_saw_color), clbk_colorpicker, clbk_colorpicker)
	end

	MenuCallbackHandler.callback_Saw_Noise_Indicator_back = function(self,item)
		Saw_Noise_Indicator:Save()
	end
	
	Saw_Noise_Indicator:Load()

	Saw_Noise_Indicator._colorpicker = Saw_Noise_Indicator._colorpicker or (ColorPicker and ColorPicker:new("Saw_Noise_Indicator_colorpicker_menu_id",colorpicker_data,callback(Saw_Noise_Indicator,Saw_Noise_Indicator,"set_colorpicker_menu")))
	
	-- Main Menu
	Hooks:Add("MenuManagerSetupCustomMenus", "Base_SetupCustomMenus_Json_Saw_Noise_Indicator_main_menu", function( menu_manager, nodes)
		MenuHelper:NewMenu( "Saw_Noise_Indicator_main_menu" )
	end)

	Hooks:Add("MenuManagerBuildCustomMenus", "Base_BuildCustomMenus_Json_Saw_Noise_Indicator_main_menu", function(menu_manager, nodes)
		local parent_menu = "blt_options"
		local menu_id = "Saw_Noise_Indicator_main_menu"
		local menu_name = "Saw_Noise_Indicator_main_menu_title"
		local menu_desc = "Saw_Noise_Indicator_main_menu_desc"

		local data = {
			focus_changed_callback = nil,
			back_callback = "callback_Saw_Noise_Indicator_back",
			area_bg = nil,
		}
		nodes[menu_id] = MenuHelper:BuildMenu( menu_id, data )

		MenuHelper:AddMenuItem( nodes[parent_menu], menu_id, menu_name, menu_desc, nil )
	end)
end)

Hooks:Add("MenuManagerPopulateCustomMenus", "Base_PopulateCustomMenus_Json_Saw_Noise_Indicator_main_menu", function(menu_manager, nodes)
	MenuHelper:AddToggle({
		id = "enabled",
		title = "Saw_Noise_Indicator_enabled_title",
		desc = "Saw_Noise_Indicator_enabled_desc",
		callback = "Saw_Noise_Indicator_toggle",
		value = Saw_Noise_Indicator.settings.enabled,
		menu_id = "Saw_Noise_Indicator_main_menu",
		priority = 6
	})
	MenuHelper:AddDivider({
		id = "Saw_Noise_Indicator_divider_0",
		size = 24,
		menu_id = "Saw_Noise_Indicator_main_menu",
		priority = 5
	})
	MenuHelper:AddSlider({
		id = "prediction_value",
		title = "Saw_Noise_Indicator_prediction_value_title",
		desc = "Saw_Noise_Indicator_prediction_value_desc",
		callback = "Saw_Noise_Indicator_value",
		value = Saw_Noise_Indicator.settings.prediction_value,
		min = 0,
		max = 1,
		step = 0.01,
		show_value = true,
		menu_id = "Saw_Noise_Indicator_main_menu",
		priority = 4
	})
	MenuHelper:AddToggle({
		id = "loud_saw_effect",
		title = "Saw_Noise_Indicator_loud_saw_effect_title",
		desc = "Saw_Noise_Indicator_loud_saw_effect_desc",
		callback = "Saw_Noise_Indicator_toggle",
		value = Saw_Noise_Indicator.settings.loud_saw_effect,
		menu_id = "Saw_Noise_Indicator_main_menu",
		priority = 2
	})
	if Saw_Noise_Indicator._colorpicker then
		MenuHelper:AddButton({
			id = "Saw_Noise_Indicator_silent_saw_color_ColorPicker",
			title = "Saw_Noise_Indicator_silent_saw_color_title",
			desc = "Saw_Noise_Indicator_silent_saw_color_desc",
			callback = "callback_Saw_Noise_Indicator_silent_saw_color",
			menu_id = "Saw_Noise_Indicator_main_menu",
			priority = 3
		})
		MenuHelper:AddButton({
			id = "Saw_Noise_Indicator_loud_saw_color_ColorPicker",
			title = "Saw_Noise_Indicator_loud_saw_color_title",
			desc = "Saw_Noise_Indicator_loud_saw_color_desc",
			callback = "callback_Saw_Noise_Indicator_loud_saw_color",
			menu_id = "Saw_Noise_Indicator_main_menu",
			priority = 1
		})
	elseif not _G.ColorPicker then
		MenuHelper:AddInput({
			id = "silent_saw_color",
			title = "Saw_Noise_Indicator_silent_saw_color_input_title",
			desc = "Saw_Noise_Indicator_silent_saw_color_input_desc",
			callback = "Saw_Noise_Indicator_value",
			value = Saw_Noise_Indicator.settings.silent_saw_color,
			menu_id = "Saw_Noise_Indicator_main_menu",
			priority = 3
		})
		MenuHelper:AddInput({
			id = "loud_saw_color",
			title = "Saw_Noise_Indicator_loud_saw_color_input_title",
			desc = "Saw_Noise_Indicator_loud_saw_color_input_desc",
			callback = "Saw_Noise_Indicator_value",
			value = Saw_Noise_Indicator.settings.loud_saw_color,
			menu_id = "Saw_Noise_Indicator_main_menu",
			priority = 1
		})
	end
end)

Saw_Noise_Indicator:LoadTextures()