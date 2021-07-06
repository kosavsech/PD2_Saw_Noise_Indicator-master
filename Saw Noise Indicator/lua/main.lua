if not Saw_Noise_Indicator then 
	dofile(ModPath .. 'lua/menumanager.lua')
end
local function round(number, scale)
	return math.floor( (0.5 * scale + number) / scale ) * scale
end

function Saw_Noise_Indicator:AnimatedScreenEffect(self)
	self:set_visible(true)
	local hudinfo = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
	self:animate(hudinfo.flash_icon, 4000000000)
end

function Saw_Noise_Indicator:StopScreenEffect(self)
	self:stop()
	self:set_visible(false)
end

function Saw_Noise_Indicator:ScreenEffectApplier(self, color_req)
	color_solved = color_req == "silent" and Color(Saw_Noise_Indicator.settings.silent_saw_color) or Color(Saw_Noise_Indicator.settings.loud_saw_color)
	self:set_color(color_solved)
	Saw_Noise_Indicator:AnimatedScreenEffect(self)
end

function Saw_Noise_Indicator:CurrentWeaponID()
	local player = managers.player and managers.player:local_player()
	local weapon = player and player:inventory():equipped_unit()
	local id = weapon and weapon:base()._name_id
	return id
end

function Saw_Noise_Indicator:ScreenEffectSetup()
	local hud = managers.hud:script( PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
	if not hud.panel:child("Saw_Noise_Indicator_effect") then
		local Saw_Noise_Indicator_effect = hud.panel:bitmap({
			name = "Saw_Noise_Indicator_effect",
			visible = false,
			texture = "assets/guis/textures/saw_indicator_effect",
			layer = 0,
			blend_mode = "add",
			w = hud.panel:w(),
			h = hud.panel:h(),
			x = 0,
			y = 0 
		})
	end
end

Hooks:PostHook(RaycastWeaponBase, "_check_alert", "Saw_Noise_Indicator_RaycastWeaponBase__check_alert", function(self, rays, fire_pos, direction, user_unit)
	if not Saw_Noise_Indicator:IsEnabled() then
		return
	end
	local equipped_saw = Saw_Noise_Indicator:CurrentWeaponID() == "saw" or Saw_Noise_Indicator:CurrentWeaponID() == "saw_secondary"
	if equipped_saw then
		Saw_Noise_Indicator:log( self._alert_size,{color = Color.blue} )
		if self._alert_size == 200 then
			Saw_Noise_Indicator.silent_deadline = TimerManager:game():time() + 1.5
		end
	end
end)

Hooks:PostHook(HUDManager, "update", "Saw_Noise_Indicator_HUDManager_update", function(self, t, dt)
	if not Saw_Noise_Indicator:IsEnabled() then
		return
	end

	Saw_Noise_Indicator:ScreenEffectSetup()
	local hud = managers.hud:script( PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2 )
	local Saw_Noise_Indicator_effect = hud.panel:child("Saw_Noise_Indicator_effect")

	local equipped_saw = Saw_Noise_Indicator:CurrentWeaponID() == "saw" or Saw_Noise_Indicator:CurrentWeaponID() == "saw_secondary"
	if equipped_saw then
		if round( Saw_Noise_Indicator.silent_deadline - t, 0.01 ) > Saw_Noise_Indicator.settings.prediction_value then
			Saw_Noise_Indicator:log( round( Saw_Noise_Indicator.silent_deadline - t, 0.01 ) .. " > " .. Saw_Noise_Indicator.settings.prediction_value, {color = Color.blue} )
			Saw_Noise_Indicator:ScreenEffectApplier(Saw_Noise_Indicator_effect, "silent")
		else
			if Saw_Noise_Indicator.settings.loud_saw_effect then
				Saw_Noise_Indicator:ScreenEffectApplier(Saw_Noise_Indicator_effect, "loud")
			else
				Saw_Noise_Indicator:StopScreenEffect(Saw_Noise_Indicator_effect)
			end
		end
	else
		Saw_Noise_Indicator:StopScreenEffect(Saw_Noise_Indicator_effect)
	end
end)