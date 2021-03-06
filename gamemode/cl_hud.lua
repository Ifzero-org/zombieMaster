local skullMaterial  = surface.GetTextureID("VGUI/miniskull")
local popMaterial	 = surface.GetTextureID("VGUI/minifigures")
local selection_color_outline = Color(255, 0, 0, 255)
local selection_color_box 	  = Color(120, 0, 0, 80)
local h, w = ScrH(), ScrW()

function GM:HUDPaint()
	local myteam = LocalPlayer():Team()
	local screenscale = BetterScreenScale()
	local wid, hei = 225 * screenscale, 72 * screenscale

	if LocalPlayer():IsSurvivor() then
		self:HumanHUD(screenscale)
	elseif LocalPlayer():IsZM() then
		self:ZombieMasterHUD(screenscale)
	end
	
	if not self:GetRoundActive() then
		if not self:GetZMSelection() then
			draw.SimpleText(translate.Get("waiting_on_players"), "ZMHUDFontSmall", w * 0.5, h * 0.25, Color(150, 0, 0), TEXT_ALIGN_CENTER)
		else
			draw.SimpleText(translate.Get("players_ready"), "ZMHUDFontSmall", w * 0.5, h * 0.25, Color(0, 150, 0), TEXT_ALIGN_CENTER)
		end
	end
	
	hook.Run( "HUDDrawTargetID" )
	hook.Run( "HUDDrawPickupHistory" )
	hook.Run( "DrawDeathNotice", 0.85, 0.04 )
end

function GM:HUDShouldDraw(name)
	return name ~= "CHudHealth" and name ~= "CHudBattery" and name ~= "CHudAmmo" and name ~= "CHudSecondaryAmmo"
end

function GM:HumanHUD(screenscale)	
	local wid, hei = 225 * screenscale, 72 * screenscale
	local x, y = ScrW() - wid - screenscale * (ScrW() - (ScrW() * 0.18)), ScrH() - hei - screenscale * 32
	
	draw.RoundedBox(16, x + 2, y + 2, wid, hei, Color(60, 0, 0, 200))
	
	local health = LocalPlayer():Health()
	local healthCol = health <= 10 and Color(185, 0, 0, 255) or health <= 30 and Color(150, 50, 0) or health <= 60 and Color(255, 200, 0) or color_white
	draw.SimpleTextBlurry(LocalPlayer():Health(), "ZMHUDFontBig", x + wid * 0.75, y + hei * 0.5, healthCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleTextBlurry("#Valve_Hud_HEALTH", "ZMHUDFontSmall", x + wid * 0.27, y + hei * 0.7, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function GM:ZombieMasterHUD(scale)
	if LocalPlayer():IsZM() then
		-- Resources + Income.
		draw.DrawSimpleRect(5, h - 43, 150, 38, Color(60, 0, 0, 200))
		draw.DrawSimpleOutlined(5, h - 43, 150, 38, color_black)
		
		surface.SetDrawColor(color_white)
		surface.SetTexture(skullMaterial)
		surface.DrawTexturedRect(7, h - 41, 32, 32)
		
		draw.DrawText(tostring(LocalPlayer():GetZMPoints()), "zm_hud_font", 60, h - 42, color_white, 1)
		
		if LocalPlayer():GetZMPointIncome() then
			draw.DrawText("+ " .. LocalPlayer():GetZMPointIncome(), "zm_hud_font2", 90, h - 24, color_white, 1)
		end
		
		-- Population.
		draw.DrawSimpleRect(5, h - 62, 100, 18, Color(60, 0, 0, 200))
		draw.DrawSimpleOutlined(5, h - 62, 100, 18, color_black)
		
		surface.SetDrawColor(color_white)
		surface.SetTexture(popMaterial)
		surface.DrawTexturedRect(6, h - 61, 16, 16)
		
		draw.DrawText(self:GetCurZombiePop() .. "/" .. self:GetMaxZombiePop(), "zm_hud_font2", 60, h - 62, color_white, 1)

		if isDragging then
			local x, y = gui.MousePos()
			
			traceX, traceY = x, y

			if mouseX < x then
				if mouseY < y then
					surface.SetDrawColor(selection_color_outline)
					surface.DrawOutlinedRect(mouseX, mouseY, x -mouseX, y -mouseY)
				
					surface.SetDrawColor(selection_color_box)
					surface.DrawRect(mouseX, mouseY, x -mouseX, y -mouseY)
				else
					surface.SetDrawColor(selection_color_outline)
					surface.DrawOutlinedRect(mouseX, y, x -mouseX, mouseY -y)
				
					surface.SetDrawColor(selection_color_box)
					surface.DrawRect(mouseX, y, x -mouseX, mouseY -y)
				end
			else
				if mouseY > y then
					surface.SetDrawColor(selection_color_outline)
					surface.DrawOutlinedRect(x, y, mouseX -x, mouseY -y)
				
					surface.SetDrawColor(selection_color_box)
					surface.DrawRect(x, y, mouseX -x, mouseY -y)
				else
					surface.SetDrawColor(selection_color_outline)
					surface.DrawOutlinedRect(x, mouseY, mouseX -x, y -mouseY)
				
					surface.SetDrawColor(selection_color_box)
					surface.DrawRect(x, mouseY, mouseX -x, y -mouseY)
				end
			end
		end
	end
end

function MakepHelp()
	local frame = vgui.Create( "DFrame" )
	frame:SetSize(ScrW() * 0.6, ScrH() * 0.6)
	frame:SetTitle("Help")
	frame:SetVisible(true)
	frame:SetDraggable(true)
	frame.btnMaxim:SetVisible(false)
	frame.btnMinim:SetVisible(false)
	frame:Center()
	frame.Paint = function(self, w, h)
		draw.RoundedBox(8, 0, 0, w, h, Color(130, 0, 0))
		draw.RoundedBox(4, 2, 2, w - 4, h - 4, Color(60, 0, 0))
	end
	
	local html = vgui.Create("DHTML" , frame)
	html:Dock(FILL)
	html:SetHTML([[
		<html>
		<head>
		<title>ZM MOTD</title>
		<style type="text/css">
		body	{
			background:#1B0503;
			margin-left:10px;
			margin-top:10px;
			text-align: center;
		}
		h	{
			font-family: Arial Black, Arial, Impact, serif;
		}
		#centering {
			font-family: Tahoma, Verdana, Arial, Helvetica, sans-serif;
			color: #FFFFFF;
			width: 80%;
			background-color: #550000;
			margin-left: auto;
			margin-right: auto;
			padding: 20px;
		}
		</style>
		</head>
		<body scroll='no'>
		<div id='centering'>
		<!-- motd goes here -->
		<h2>Zombie Master</h2>
		<h3>Beta 1.X.X</h3>
		<h4>Make sure you bind all new keys in the keyboard config!</h4>
		<p><b>ZM for noobs</b></p>
		<p><i>As Zombie Master</i>: Click on the orbs, spawn zombies, kill humans.</p>
		<p><i>As Human</i>: Get guns, check map objectives (F1), survive and complete objectives.</p>
		<p>www.zombiemaster.org</p>

		</div>
		</body>
		</html>]])

	frame:MakePopup()
end

function MakepCredits()
	local wid = math.min(ScrW(), 750)

	local y = 8

	local frame = vgui.Create("DFrame")
	frame:SetWide(wid)
	frame:SetTitle(" ")
	frame:SetKeyboardInputEnabled(false)
	frame.lblTitle:SetFont("dexfont_med")
	frame.Paint = function(self, w, h)
		draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 180))
	end

	local label = EasyLabel(frame, GAMEMODE.Name.." Credits", "ZMHUDFontNS", color_white)
	label:AlignTop(y)
	label:CenterHorizontal()
	y = y + label:GetTall() + 8

	for authorindex, authortab in ipairs(GAMEMODE.Credits) do
		local lineleft = EasyLabel(frame, string.Replace(authortab[1], "@", "(at)"), "ZMHUDFontSmallestNS", color_white)
		local linemid = EasyLabel(frame, "-", "ZMHUDFontSmallestNS", color_white)
		local lineright = EasyLabel(frame, authortab[3], "ZMHUDFontSmallestNS", color_white)
		local linesub
		if authortab[2] then
			linesub = EasyURL(frame, authortab[2], "DefaultFont", color_white)
		end

		lineleft:AlignLeft(8)
		lineleft:AlignTop(y)
		lineright:AlignRight(8)
		lineright:AlignTop(y)
		linemid:CenterHorizontal()
		linemid:AlignTop(y)

		y = y + lineleft:GetTall()
		if linesub then
			linesub:AlignTop(y)
			linesub:AlignLeft(8)
			y = y + linesub:GetTall()
		end
		y = y + 10
	end

	frame:SetTall(y + 8)
	frame:Center()
	frame:SetAlpha(0)
	frame:AlphaTo(255, 0.5, 0)
	frame:MakePopup()
end

local pPlayerModel
local function SwitchPlayerModel(self)
	surface.PlaySound("buttons/button14.wav")
	RunConsoleCommand("cl_playermodel", self.m_ModelName)
	chat.AddText(COLOR_LIMEGREEN, translate.Format("changed_player_model", tostring(self.m_ModelName)))

	pPlayerModel:Close()
end
function MakepPlayerModel()
	if pPlayerModel and pPlayerModel:Valid() then pPlayerModel:Remove() end
	
	local numcols = 8
	local wid = numcols * 68 + 24
	local hei = 400

	pPlayerModel = vgui.Create("DFrame")
	pPlayerModel:SetSkin("Default")
	pPlayerModel:SetTitle(translate.Get("title_playermodels"))
	pPlayerModel:SetSize(wid, hei)
	pPlayerModel:Center()
	pPlayerModel:SetDeleteOnClose(true)
	pPlayerModel.btnMaxim:SetVisible(false)
	pPlayerModel.btnMinim:SetVisible(false)
	pPlayerModel.Paint = function(self, w, h)
		draw.RoundedBox(8, 0, 0, w, h, Color(130, 0, 0))
		draw.RoundedBox(4, 2, 2, w - 4, h - 4, Color(60, 0, 0))
	end

	local list = vgui.Create("DPanelList", pPlayerModel)
	list:StretchToParent(8, 24, 8, 8)
	list:EnableVerticalScrollbar()

	local grid = vgui.Create("DGrid", pPlayerModel)
	grid:SetCols(numcols)
	grid:SetColWide(68)
	grid:SetRowHeight(68)
	
	local playermodels = player_manager.AllValidModels()
	for _, name in pairs(GAMEMODE.RestrictedPMs) do
		if playermodels[name] then
			playermodels[name] = nil
		end
	end
	for name, mdl in pairs(playermodels) do
		if mdl ~= nil then
			local button = vgui.Create("SpawnIcon", grid)
			button:SetPos(0, 0)
			button:SetModel(mdl)
			button.m_ModelName = name
			button.OnMousePressed = SwitchPlayerModel
			grid:AddItem(button)
		end
	end
	grid:SetSize(wid - 16, math.ceil(table.Count(playermodels) / numcols) * grid:GetRowHeight())

	list:AddItem(grid)

	pPlayerModel:SetSkin("Default")
	pPlayerModel:MakePopup()
end

function MakepPlayerColor()
	if pPlayerColor and pPlayerColor:Valid() then pPlayerColor:Remove() end

	pPlayerColor = vgui.Create("DFrame")
	pPlayerColor:SetWide(math.min(ScrW(), 500))
	pPlayerColor:SetTitle(" ")
	pPlayerColor:SetDeleteOnClose(true)
	pPlayerColor.btnMaxim:SetVisible(false)
	pPlayerColor.btnMinim:SetVisible(false)
	pPlayerColor.Paint = function(self, w, h)
		draw.RoundedBox(8, 0, 0, w, h, Color(130, 0, 0))
		draw.RoundedBox(4, 2, 2, w - 4, h - 4, Color(60, 0, 0))
	end

	local y = 8

	local label = EasyLabel(pPlayerColor, "Colors", "ZMHUDFont", color_white)
	label:SetPos((pPlayerColor:GetWide() - label:GetWide()) / 2, y)
	y = y + label:GetTall() + 8

	local lab = EasyLabel(pPlayerColor, translate.Get("title_playercolor"))
	lab:SetPos(8, y)
	y = y + lab:GetTall()

	local colpicker = vgui.Create("DColorMixer", pPlayerColor)
	colpicker:SetAlphaBar(false)
	colpicker:SetPalette(false)
	colpicker.UpdateConVars = function(me, color)
		me.NextConVarCheck = SysTime() + 0.2
		RunConsoleCommand("cl_playercolor", color.r / 100 .." ".. color.g / 100 .." ".. color.b / 100)
	end
	local r, g, b = string.match(GetConVarString("cl_playercolor"), "(%g+) (%g+) (%g+)")
	if r then
		colpicker:SetColor(Color(r * 100, g * 100, b * 100))
	end
	colpicker:SetSize(pPlayerColor:GetWide() - 16, 72)
	colpicker:SetPos(8, y)
	y = y + colpicker:GetTall()

	local lab = EasyLabel(pPlayerColor, translate.Get("title_weaponcolor"))
	lab:SetPos(8, y)
	y = y + lab:GetTall()

	local colpicker = vgui.Create("DColorMixer", pPlayerColor)
	colpicker:SetAlphaBar(false)
	colpicker:SetPalette(false)
	colpicker.UpdateConVars = function(me, color)
		me.NextConVarCheck = SysTime() + 0.2
		RunConsoleCommand("cl_weaponcolor", color.r / 100 .." ".. color.g / 100 .." ".. color.b / 100)
	end
	local r, g, b = string.match(GetConVarString("cl_weaponcolor"), "(%g+) (%g+) (%g+)")
	if r then
		colpicker:SetColor(Color(r * 100, g * 100, b * 100))
	end
	colpicker:SetSize(pPlayerColor:GetWide() - 16, 72)
	colpicker:SetPos(8, y)
	y = y + colpicker:GetTall()

	pPlayerColor:SetTall(y + 8)
	pPlayerColor:Center()
	pPlayerColor:MakePopup()
end

function MakepOptions()
	if pOptions then
		pOptions:SetAlpha(0)
		pOptions:AlphaTo(255, 0.5, 0)
		pOptions:SetVisible(true)
		pOptions:MakePopup()
		return
	end

	local Window = vgui.Create("DFrame")
	local wide = math.min(ScrW(), 500)
	local tall = math.min(ScrH(), 580)
	Window:SetSize(wide, tall)
	Window:Center()
	Window:SetTitle(" ")
	Window:SetDeleteOnClose(false)
	Window.btnMinim:SetVisible(false)
	Window.btnMaxim:SetVisible(false)
	Window.Paint = function(self, w, h)
		draw.RoundedBox(8, 0, 0, w, h, Color(150, 0, 0))
		draw.RoundedBox(4, 4, 4, w - 7, h - 7, Color(60, 0, 0))
	end
	pOptions = Window

	local y = 8
	local label = EasyLabel(Window, "Options", "ZMHUDFont", color_white)
	label:SetPos(wide * 0.5 - label:GetWide() * 0.5, y)
	y = y + label:GetTall() + 8

	local list = vgui.Create("DPanelList", pOptions)
	list:EnableVerticalScrollbar()
	list:EnableHorizontal(false)
	list:SetSize(wide - 24, tall - y - 12)
	list:SetPos(12, y)
	list:SetPadding(8)
	list:SetSpacing(4)

	hook.Call("AddExtraOptions", GAMEMODE, list, Window)

	local check = vgui.Create("DCheckBoxLabel", Window)
	check:SetText("Show Volunteer Menu")
	check:SetConVar("zm_nopreferredmenu")
	check:SizeToContents()
	list:AddItem(check)
	
	--[[
	local slider = vgui.Create("DNumSlider", Window)
	slider:SetDecimals(0)
	slider:SetMinMax(0, 50)
	slider:SetConVar("zm_scrollwheelsensativity")
	slider:SetText("Scroll Sensitivity")
	slider:SizeToContents()
	list:AddItem(slider)
	--]]

	Window:SetAlpha(0)
	Window:AlphaTo(255, 0.5, 0)
	Window:MakePopup()
end

local surfacecolor = Color(72, 0, 0)
local outlinecolor = Color(110, 0, 0)
local function DrawZMButton(self, w, h)
	if self:IsHovered() then
		surfacecolor = Color(92, 0, 0)
		outlinecolor = Color(140, 0, 0)
	else
		surfacecolor = Color(72, 0, 0)
		outlinecolor = Color(110, 0, 0)
	end
	draw.RoundedBox(8, 0, 0, w, h, outlinecolor)
	draw.RoundedBox(4, 2, 2, w - 4, h - 4, surfacecolor)
end
function GM:ShowOptions()
	if self.OptionsMenu and self.OptionsMenu:Valid() then
		self.OptionsMenu:Remove()
	end
	
	local menu = vgui.Create("Panel")
	menu:SetSize(BetterScreenScale() * 420, ScrH() * 0.35)
	menu:Center()
	menu.Paint = function(self, w, h)
		draw.RoundedBox(8, 0, 0, w, h, Color(150, 0, 0))
		draw.RoundedBox(4, 4, 4, w - 7, h - 7, Color(60, 0, 0))
	end

	local header = EasyLabel(menu, self.Name, "ZMHUDFont")
	header:SetContentAlignment(8)
	header:DockMargin(0, 12, 0, 24)
	header:Dock(TOP)
	
	local but = vgui.Create("DButton", menu)
	but:SetFont("ZMHUDFontSmaller")
	but:SetText(translate.Get("button_help"))
	but:SetTall(32)
	but:DockMargin(12, 0, 12, 12)
	but:DockPadding(0, 12, 0, 12)
	but:Dock(TOP)
	but.DoClick = function() MakepHelp() end
	but:SetTextColor(color_white)
	but.Paint = DrawZMButton
	
	local but = vgui.Create("DButton", menu)
	but:SetFont("ZMHUDFontSmaller")
	but:SetText(translate.Get("button_playermodel"))
	but:SetTall(32)
	but:DockMargin(12, 0, 12, 12)
	but:DockPadding(0, 12, 0, 12)
	but:Dock(TOP)
	but.DoClick = function() MakepPlayerModel() end
	but:SetTextColor(color_white)
	but.Paint = DrawZMButton

	local but = vgui.Create("DButton", menu)
	but:SetFont("ZMHUDFontSmaller")
	but:SetText(translate.Get("button_playercolor"))
	but:SetTall(32)
	but:DockMargin(12, 0, 12, 12)
	but:DockPadding(0, 12, 0, 12)
	but:Dock(TOP)
	but.DoClick = function() MakepPlayerColor() end
	but:SetTextColor(color_white)
	but.Paint = DrawZMButton
	
	local but = vgui.Create("DButton", menu)
	but:SetFont("ZMHUDFontSmaller")
	but:SetText(translate.Get("button_options"))
	but:SetTall(32)
	but:DockMargin(12, 0, 12, 12)
	but:DockPadding(0, 12, 0, 12)
	but:Dock(TOP)
	but.DoClick = function() MakepOptions() end
	but:SetTextColor(color_white)
	but.Paint = DrawZMButton

	local but = vgui.Create("DButton", menu)
	but:SetFont("ZMHUDFontSmaller")
	but:SetText(translate.Get("button_credits"))
	but:SetTall(32)
	but:DockMargin(12, 0, 12, 12)
	but:DockPadding(0, 12, 0, 12)
	but:Dock(TOP)
	but.DoClick = function() MakepCredits() end
	but:SetTextColor(color_white)
	but.Paint = DrawZMButton

	local but = vgui.Create("DButton", menu)
	but:SetFont("ZMHUDFontSmaller")
	but:SetText(translate.Get("button_close"))
	but:SetTall(32)
	but:DockMargin(12, 24, 12, 0)
	but:DockPadding(0, 12, 0, 12)
	but:Dock(TOP)
	but.DoClick = function() menu:Remove() end
	but:SetTextColor(color_white)
	but.Paint = DrawZMButton

	menu:InvalidateLayout(true)
	menu:SizeToChildren(false, true)
	menu:SetSize(menu:GetWide(), menu:GetTall() + 12)
	menu:MakePopup()
	
	self.OptionsMenu = menu
end

function GM:ShowHelp()
	if IsValid(self.objmenu) then
		self.objmenu:SetVisible(not self.objmenu:IsVisible())
		self.objmenuimage:SetVisible(not self.objmenuimage:IsVisible())
		return
	end
	
	gui.EnableScreenClicker(true)
	
	local frame = vgui.Create("DEXRoundedFrame")
	frame:SetWide(ScrW() * 0.75)
	frame:SetTall(math.min(ScrH() - (ScrH() * 0.1), 900))
	frame:SetTitle(" ")
	frame:SetKeyboardInputEnabled(false)
	frame:SetMouseInputEnabled(true)
	frame:Center()
	frame.Paint = function(self, w, h)
		draw.RoundedBoxEx(8, 0, 64, w, h - 64, Color(5, 5, 5, 180), false, false, true, true)
		draw.RoundedBoxEx(8, 0, 0, w, 64, Color(5, 5, 5, 220), true, true, false, false)
	end
	
	local sprite = vgui.Create("DImage", frame)
	sprite:AlignTop(-5)
	sprite:AlignLeft(5)
	sprite:SetSize(ScrW() * 0.07, ScrH() * 0.07)
	sprite:SetImage("vgui/gfx/vgui/hl2mp_logo")
	
	local pan = vgui.Create("DPanel", frame)
	pan:SetPos(frame:GetWide() * 0.08, frame:GetTall() * 0.08)
	pan:SetSize(frame:GetWide() * 0.85, frame:GetTall() * 0.85)
	pan.Paint = function(self, w, h) 
		draw.RoundedBox(8, 0, 0, w, h, Color(24, 24, 24))
	end
	
	local label = EasyLabel(frame, translate.Get("title_objectives"), "ZMHUDFont", color_white)
	label:AlignLeft(frame:GetWide() * 0.1)
	label:AlignTop(frame:GetTall() * 0.01)
	
	local scroll = vgui.Create("DScrollPanel", pan)
	scroll:SetSize(pan:GetWide() - 5, pan:GetTall() - 5)
	
	local lab = vgui.Create("DLabel", scroll)
	lab:SetFont("ZMHUDFontSmaller")
	lab:AlignTop(8)
	lab:AlignLeft(8)
	lab:SetText(self.MapInfo)
	lab:SizeToContents()
	
	local hoverColor = Color(0, 0, 0)
	local but = vgui.Create("DButton", frame)
	but:SetFont("ZMHUDFontSmaller")
	but:SetText(translate.Get("button_okay"))
	but:SetTall(frame:GetTall() * 0.05)
	but:SetWide(frame:GetWide() * 0.13)
	but:AlignBottom(frame:GetTall() * 0.012)
	but:AlignRight(frame:GetWide() * 0.062)
	but:SetTextColor(color_white)
	but.DoClick = function()
		if not LocalPlayer():IsZM() then
			gui.EnableScreenClicker(false)
		end
		frame:SetVisible(false)
		sprite:SetVisible(false)
	end
	but.Paint = function(self, w, h) 
		draw.OutlinedBox(0, 0, w, h, 2, Color(46, 46, 46))
		if self:IsHovered() then
			hoverColor = Color(40, 0, 0, 200)
		else
			hoverColor = Color(30, 30, 30, 80)
		end
		surface.SetDrawColor(hoverColor)
		surface.DrawRect(2, 2, w - 3, h - 3)
	end
	
	self.objmenu = frame
	self.objmenuimage = sprite
end

function GM:MakePreferredMenu()
	if GetConVar("zm_nopreferredmenu"):GetBool() then return end
	
	gui.EnableScreenClicker(true)
	
	local frame = vgui.Create("DFrame")
	frame:SetWide(326.4)
	frame:SetTall(345)
	frame:SetTitle(" ")
	frame:SetKeyboardInputEnabled(false)
	frame:SetMouseInputEnabled(true)
	frame:AlignTop(20)
	frame:AlignLeft(20)
	frame.Close = function(self)
		if not LocalPlayer():IsZM() then
			gui.EnableScreenClicker(false)
		end
		self:Remove()
	end
	frame.Paint = function(self)
		draw.RoundedBox(8, 0, 0, self:GetWide(), self:GetTall(), Color(60, 0, 0, 200))
	end
	
	local label = vgui.Create("DLabel", frame)
	label:AlignTop(45)
	label:SetFont("ZMHUDFontSmaller")
	label:SetText(translate.Get("preferred_playstyle"))
	label:SetTextColor(color_white)
	label:SizeToContents()
	label:CenterHorizontal()
	
	local but = vgui.Create("DButton", frame)
	but:AlignTop(95)
	but:SetWide(250)
	but:SetTall(30)
	but:SetText(translate.Get("preferred_willing_zm"))
	but:CenterHorizontal()
	but:SetTextColor(color_white)
	but.DoClick = function(self)
		RunConsoleCommand("zm_preference", 1)
		surface.PlaySound("buttons/combine_button1.wav")
		frame:Close()
	end
	but.Paint = function(self)
		if self:IsHovered() then
			col = Color(145, 0, 0)
			col2 = Color(95, 0, 0)
		else
			col = Color(89, 0, 0)
			col2 = Color(52, 0, 0)
		end
		draw.RoundedBox(0, 0, 0, w, h, col)
		draw.RoundedBox(0, 2, 2, w - 4, h - 4, col2)
	end
	
	local but = vgui.Create("DButton", frame)
	but:AlignTop(165)
	but:SetWide(250)
	but:SetTall(30)
	but:SetText(translate.Get("preferred_prefer_survivor"))
	but:CenterHorizontal()
	but:SetTextColor(color_white)
	but.DoClick = function(self)
		RunConsoleCommand("zm_preference", 0)
		surface.PlaySound("buttons/combine_button1.wav")
		frame:Close()
	end
	but.Paint = function(self)
		if self:IsHovered() then
			col = Color(145, 0, 0)
			col2 = Color(95, 0, 0)
		else
			col = Color(89, 0, 0)
			col2 = Color(52, 0, 0)
		end
		draw.RoundedBox(0, 0, 0, w, h, col)
		draw.RoundedBox(0, 2, 2, w - 4, h - 4, col2)
	end
	
	local check = vgui.Create("DCheckBoxLabel", frame)
	check:AlignTop(270)
	check:CenterHorizontal()
	check:SetText(translate.Get("preferred_dont_ask"))
	check:SetConVar("zm_nopreferredmenu")
	check:SetTextColor(color_white)
	check:SizeToContents()
end

local boxColor = Color(115, 0, 0)
local surfaceColor = Color(52, 0, 0, 250)
local function trapMenuPaint(self, w, h)
	if not self.bActive then
		boxColor = Color(58, 0, 0)
		surfaceColor = Color(26, 0, 0, 250)
	elseif self:IsHovered() then
		boxColor = Color(173, 0, 0)
		surfaceColor = Color(78, 0, 0, 250)
	else
		boxColor = Color(115, 0, 0)
		surfaceColor = Color(52, 0, 0, 250)
	end
	
	draw.OutlinedBox(0, 0, w, h, 2, boxColor)
	surface.SetDrawColor(surfaceColor)
	surface.DrawRect(2, 2, w - 3, h - 3)
end
function GM:SpawnTrapMenu(class, ent)
	if class == "info_manipulate" and ent:GetActive() then
		if IsValid(self.trapMenu) then
			self.trapMenu:Remove()
		end
		
		if trapEntity then
			trapEntity:Remove()
			trapEntity = nil
		end
		
		local description = ent:GetDescription()
		local trapPanel = vgui.Create("DEXRoundedFrame")
		trapPanel:SetWide(326.4)
		trapPanel:SetTall(345)
		trapPanel:SetTitle("Manipulate")
		trapPanel:SetKeyboardInputEnabled(false)
		trapPanel:SetMouseInputEnabled(true)
		trapPanel:AlignTop(10)
		trapPanel:AlignLeft(20)
		trapPanel:SetColor(Color(60, 0, 0, 200))
		trapPanel.PerformLayout = function(self)
			self.lblTitle:SetWide(self:GetWide() - 25)
			self.lblTitle:SetPos(12, 8)
		end
		
		trapPanel.lblTitle:SetFont("ZMHUDFontSmallest")
			
		trapPanel.Close = function(self)
			self:SetVisible(false)
			trapPanel = nil
				
			isDragging = false
			holdTime = CurTime()
		end
		
		local description = vgui.Create("DLabel", trapPanel)
		description:AlignLeft(trapPanel:GetWide() * 0.12)
		description:AlignTop(trapPanel:GetTall() * 0.2)
		description:SetText(ent:GetDescription())
		description:SizeToContents()
		
		local cost = ent:GetCost()
		local activate = vgui.Create("DButton", trapPanel)
		activate:AlignLeft(trapPanel:GetWide() * 0.12)
		activate:AlignTop(trapPanel:GetTall() * 0.3)
		activate:SetTall(32)
		activate:SetWide(250)
		activate:SetTextColor(color_white)
		activate:SetText(translate.Format("trap_activate_for_x", cost))
		activate:SetEnabled(true)
		activate.bActive = true
		activate.Paint = trapMenuPaint
		activate.Think = function(self)
			self.BaseClass.Think(self)
			
			if not LocalPlayer():CanAfford(cost) then
				self:SetEnabled(false)
			else
				self:SetEnabled(true)
			end
			
			if self.bActive ~= not self.m_bDisabled then
				self.bActive = not self.m_bDisabled
				if not self.bActive then
					self:AlphaTo(185, 0.75, 0)
					self:SetTextColor(Color(60, 60, 60))
				else
					self:AlphaTo(255, 0.75, 0)
					self:SetTextColor(color_white)
				end
			end
		end
		activate.DoClick = function(self)
			isDragging = false
			holdTime = CurTime()
			
			if LocalPlayer():CanAfford(cost) then
				RunConsoleCommand("zm_clicktrap", ent:EntIndex())
				trapPanel:Close()
			end
		end
		
		local trapCost = ent:GetTrapCost()
		local setTrigger = vgui.Create("DButton", trapPanel)
		setTrigger:AlignLeft(trapPanel:GetWide() * 0.12)
		setTrigger:AlignTop(trapPanel:GetTall() * 0.45)
		setTrigger:SetTall(32)
		setTrigger:SetWide(250)
		setTrigger:SetTextColor(color_white)
		setTrigger:SetText(translate.Format("trap_create_for_x", trapCost))
		setTrigger:SetEnabled(true)
		setTrigger.bActive = true
		setTrigger.Paint = trapMenuPaint
		setTrigger.Think = function(self)
			self.BaseClass.Think(self)
			
			if not LocalPlayer():CanAfford(trapCost) then
				self:SetEnabled(false)
			else
				self:SetEnabled(true)
			end
			
			if self.bActive ~= not self.m_bDisabled then
				self.bActive = not self.m_bDisabled
				if not self.bActive then
					self:AlphaTo(185, 0.75, 0)
					self:SetTextColor(Color(60, 60, 60))
				else
					self:AlphaTo(255, 0.75, 0)
					self:SetTextColor(color_white)
				end
			end
		end
		setTrigger.DoClick = function(self)
			isDragging = false
			holdTime = CurTime()
			
			if LocalPlayer():CanAfford(trapCost) then
				hook.Call("CreateGhostEntity", GAMEMODE, true, ent:EntIndex())
				
				trapTrigger = ent:EntIndex()
				
				trapPanel:Close()
			end
		end
		
		local cancel = vgui.Create("DButton", trapPanel)
		cancel:AlignLeft(trapPanel:GetWide() * 0.12)
		cancel:AlignTop(trapPanel:GetTall() * 0.85)
		cancel:SetTall(32)
		cancel:SetWide(250)
		cancel:SetTextColor(color_white)
		cancel:SetText(translate.Get("button_cancel"))
		cancel.bActive = true
		cancel.Paint = trapMenuPaint
		cancel.DoClick = function(self)
			isDragging = false
			holdTime = CurTime()
			
			trapPanel:Close()
		end
		
		self.trapMenu = trapPanel
	elseif class == "info_zombiespawn" and ent:GetActive() then
		local data = hook.Call("GetZombieMenus", self)
		local menu = data[ent]
		
		if not IsValid(menu) then
			local zombieFlags = ent:GetZombieFlags() or 0
			
			local newMenu = vgui.Create("zm_zombiemenu")
			newMenu:SetZombieflags(zombieFlags)
			newMenu:SetTitle(translate.Get("title_spawn_menu"))
			newMenu:SetCurrent(ent:EntIndex())
			newMenu:Populate()
			newMenu:AlignTop(10)
			newMenu:AlignLeft(10)
			newMenu:SetVisible(true)
			newMenu:ShowCloseButton(false)
			
			trapTrigger = ent:EntIndex()
			
			data[ent] = newMenu
		else
			menu:SetVisible(true)
		end
	end
end

function GM:HUDDrawPickupHistory()
	if self.PickupHistory == nil then return end
	
	local x, y = ScrW() - self.PickupHistoryWide - 20, self.PickupHistoryTop
	local tall = 0
	local wide = 0

	for k, v in pairs(self.PickupHistory) do
		if not istable(v) then
			Msg(tostring(v) .."\n")
			PrintTable(self.PickupHistory)
			self.PickupHistory[ k ] = nil
			return
		end
	
		if v.time < CurTime() then
			if v.y == nil then v.y = y end
			
			v.y = (v.y * 5 + y) / 6
			
			local delta = (v.time + v.holdtime) - CurTime()
			delta = delta / v.holdtime
			
			local alpha = 255
			local colordelta = math.Clamp(delta, 0.6, 0.7)
			
			-- Fade in/out
			if (delta > 1 - v.fadein) then
				alpha = math.Clamp((1.0 - delta) * (255 / v.fadein) , 0, 255)
			elseif delta < v.fadeout then
				alpha = math.Clamp(delta * ( 255 / v.fadeout ), 0, 255)
			end
			
			v.x = x + self.PickupHistoryWide - (self.PickupHistoryWide * (alpha / 255))

			local rx, ry, rw, rh = math.Round(v.x - 4), math.Round(v.y - (v.height / 2) - 4), math.Round(self.PickupHistoryWide + 9), math.Round(v.height + 8)
			local bordersize = 8
			
			surface.SetTexture(self.PickupHistoryCorner)
			
			surface.SetDrawColor(255, 0, 0, alpha)
			surface.DrawTexturedRectRotated(rx + bordersize/2, ry + bordersize / 2, bordersize, bordersize, 0)
			surface.DrawTexturedRectRotated(rx + bordersize/2, ry + rh -bordersize / 2, bordersize, bordersize, 90)
			surface.DrawRect(rx, ry + bordersize, bordersize, rh - bordersize * 2)
			surface.DrawRect(rx + bordersize, ry, v.height - 4, rh)
			
			surface.SetDrawColor(150 * colordelta, 0, 0, alpha)
			surface.DrawRect(rx + bordersize + v.height - 4, ry, rw - (v.height - 4) - bordersize * 2, rh)
			surface.DrawTexturedRectRotated(rx + rw - bordersize / 2 , ry + rh - bordersize / 2, bordersize, bordersize, 180)
			surface.DrawTexturedRectRotated(rx + rw - bordersize / 2 , ry + bordersize / 2, bordersize, bordersize, 270)
			surface.DrawRect(rx + rw-bordersize, ry + bordersize, bordersize, rh-bordersize * 2)
			
			draw.SimpleText(v.name, v.font, v.x + v.height + 9, v.y - (v.height / 2) + 1, Color(0, 0, 0, alpha * 0.5))
	
			draw.SimpleText(v.name, v.font, v.x + v.height + 8, v.y - (v.height / 2), Color(255, 255, 255, alpha))
			
			if v.amount then
				draw.SimpleText(v.amount, v.font, v.x + self.PickupHistoryWide + 1, v.y - (v.height / 2) + 1, Color(0, 0, 0, alpha * 0.5), TEXT_ALIGN_RIGHT)
				draw.SimpleText(v.amount, v.font, v.x + self.PickupHistoryWide, v.y - (v.height / 2), Color(255, 255, 255, alpha), TEXT_ALIGN_RIGHT)
			end
			
			y = y + (v.height + 16)
			tall = tall + v.height + 18
			wide = math.Max(wide, v.width + v.height + 24)
			
			if alpha == 0 then self.PickupHistory[ k ] = nil end
		end
	end
	
	self.PickupHistoryTop = (self.PickupHistoryTop * 5 + (ScrH() * 0.75 - tall ) / 2) / 6
	self.PickupHistoryWide = (self.PickupHistoryWide * 5 + wide) / 6
end