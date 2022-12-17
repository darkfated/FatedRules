surface.CreateFont('FatedRules.Big', {
	font = 'Roboto Regular',
	size = 22,
	weight = 300,
	extended = true,
})

surface.CreateFont('FatedRules.Main', {
	font = 'Roboto Regular',
	size = 18,
	weight = 300,
	extended = true,
})

local color_white = Color(255,255,255)
local color_panel = Color(45,45,45)
local color_button = Color(20,20,20)
local color_button_2 = Color(160,160,160)
local color_button_text = Color(0,0,0)
local color_button_text_2 = Color(219,219,219)
local color_vbar = Color(63,66,102)

local function PlaySound()
	surface.PlaySound('garrysmod/ui_click.wav')
end

local function DrawPanel(pnl)
	pnl.Paint = function(_, w, h)
		draw.RoundedBox(6, 0, 0, w, h, color_panel)
	end
end

local function DrawButton(btn, custom_color)
	btn:SetFont('FatedRules.Main')
	btn.Paint = function(slf, w, h)
		if slf:IsHovered() then
			slf:SetTextColor(color_button_text)
		else
			slf:SetTextColor(color_button_text_2)
		end

		draw.RoundedBox(6, 0, 0, w, h, slf:IsHovered() and color_button_2 or (custom_color and custom_color or color_button))
	end
end

local function DrawSP(sp)
	local vbar = sp:GetVBar()
	vbar:SetWide(18)
	vbar.Paint = nil
	vbar.btnDown.Paint = nil
	vbar.btnUp.Paint = nil
	vbar.btnGrip.Paint = function(_, w, h)
		draw.RoundedBox(6, 6, 0, w - 6, h, color_vbar)
	end
end

local function SelectIconMenu(func, active_icon)
	local menu = vgui.Create('DFrame')
	menu:SetSize(260, 290)
	menu:Center()
	menu:MakePopup()
	menu:SetTitle('Выбор иконки')

	local pan = vgui.Create('DPanel', menu)
	pan:Dock(FILL)
	pan:DockPadding(6, 6, 6, 6)

	local IconBrowser = vgui.Create('DIconBrowser', pan)
	IconBrowser:Dock(FILL)
	IconBrowser.OnChange = function(self)
		func(self:GetSelectedIcon())

		menu:Remove()
	end
	IconBrowser:Fill()
	IconBrowser.Paint = nil
	IconBrowser:GetVBar():SetWide(0)
	IconBrowser:SelectIcon(active_icon)

	local BtnNoIcon = vgui.Create('DButton', pan)
	BtnNoIcon:Dock(BOTTOM)
	BtnNoIcon:DockMargin(0, 6, 0, 0)
	BtnNoIcon:SetText('Без иконки')
	BtnNoIcon.DoClick = function()
		func('')

		menu:Remove()
	end

	DrawButton(BtnNoIcon)
end

function FatedRules.Open()
	FatedRules.menu = vgui.Create('DFrame')
	FatedRules.menu:SetSize(700, 600)
	FatedRules.menu:Center()
	FatedRules.menu:MakePopup()
	FatedRules.menu:SetTitle('Правила сервера')
	FatedRules.menu:SetSizable(true)

	local CategoryPanel = vgui.Create('DPanel', FatedRules.menu)
	CategoryPanel:Dock(LEFT)
	CategoryPanel:SetWide(200)
	CategoryPanel:DockPadding(6, 6, 6, 6)

	DrawPanel(CategoryPanel)

	local MainPanel = vgui.Create('DPanel', FatedRules.menu)
	MainPanel:Dock(FILL)
	MainPanel:DockMargin(6, 0, 0, 0)
	MainPanel:DockPadding(6, 6, 6, 6)

	DrawPanel(MainPanel)

	CategoryPanel.sp = vgui.Create('DScrollPanel', CategoryPanel)
	CategoryPanel.sp:Dock(FILL)
	CategoryPanel.sp:DockMargin(0, 0, 0, 6)

	DrawSP(CategoryPanel.sp)

	local data = table.Copy(FatedRules.data)

	local function RuleCreate(tabl)
		MainPanel:Clear()

		local content_sp = vgui.Create('DScrollPanel', MainPanel)
		content_sp:Dock(FILL)

		DrawSP(content_sp)

		local function CreateHeader(txt)
			local header = vgui.Create('DPanel', content_sp)
			header:Dock(TOP)
			header:DockMargin(0, 0, 0, 6)
			header:SetTall(30)
			header.Paint = function(_, w, h)
				draw.RoundedBox(6, 0, 0, w, h, tabl.color)

				draw.SimpleText(txt, 'FatedRules.Big', 5, h * 0.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end
		end

		local function CreateText(txt, id)
			local text = vgui.Create('DLabel', content_sp)
			text:Dock(TOP)
			text:DockMargin(0, 0, 0, 6)
			text:SetText(txt)
			text:SetFont('FatedRules.Main')
			text:SetTextColor(color_white)
			text:SetAutoStretchVertical(true)
			text:SetWrap(true)
			text:SetMouseInputEnabled(true)
			text.DoRightClick = function()
				local DM = DermaMenu()
				DM:AddOption('Изменить содержание...', function()
					Derma_StringRequest('Сменить содержание', 'Какое планируете поставить?', txt, function(s)
						tabl[id] = s

						RuleCreate(tabl)
					end)
				end):SetIcon('icon16/text_align_left.png')
				DM:Open()
			end
		end

		CreateHeader(tabl.rule)
		CreateText(tabl.desc, 'desc')

		CreateHeader('Наказание')
		CreateText(tabl.punishment, 'punishment')
	end

	local function CreateCategoryList()
		CategoryPanel.sp:Clear()

		local data_counts = #data

		for catID = 1, data_counts do
			local cat_object = data[catID]

			local cat = vgui.Create('DButton', CategoryPanel.sp)
			cat:Dock(TOP)
			cat:DockMargin(0, 0, 0, 6)
			cat:SetTall(30)
			cat:SetText('')
			cat.Paint = function(_, w, h)
				draw.SimpleText(cat_object.category, 'FatedRules.Big', w * 0.5, h * 0.5, c, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

				if cat_object.icon != '' then
					surface.SetDrawColor(color_white)
					surface.SetMaterial(Material(cat_object.icon))
					surface.DrawTexturedRect(6, h * 0.5 - 8, 16, 16)
				end
			end
			cat:SetTooltip('ПКМ, чтобы отредактировать категорию')
			cat.DoRightClick = function()
				local DM = DermaMenu()
				DM:AddOption('Создать правило', function()
					cat_object.content[#cat_object.content + 1] = {
						rule = 'New rule',
						desc = 'Придумайте описание',
						punishment = 'Придумайте наказание',
						color = Color(197,64,64),
					}

					CreateCategoryList()

					PlaySound()
				end):SetIcon('icon16/add.png')
				DM:AddOption('Переименовать категорию', function()
					Derma_StringRequest('Смена названия категории', 'На что планируете сменить?', cat_object.category, function(s)
						cat_object.category = s

						CreateCategoryList()
					end)
				end):SetIcon('icon16/table_refresh.png')
				DM:AddOption('Добавить иконку категории', function()
					SelectIconMenu(function(icon)
						cat_object.icon = icon

						CreateCategoryList()
					end, cat_object.icon)
				end):SetIcon('icon16/map.png')
				DM:AddOption('Нумерация правил категории', function()
					cat_object.numbering = not cat_object.numbering

					CreateCategoryList()
				end):SetIcon('icon16/text_list_numbers.png')
				DM:AddOption('Удалить категорию (с содержимым)', function()
					table.remove(data, catID)

					CreateCategoryList()

					PlaySound()
					surface.PlaySound('')
				end):SetIcon('icon16/delete.png')
				DM:Open()
			end

			local cat_counts = #cat_object.content

			for ruleID = 1, #cat_object.content do
				local rule_object = cat_object.content[ruleID]

				local rule = vgui.Create('DButton', CategoryPanel.sp)
				rule:Dock(TOP)
				rule:DockMargin(0, 0, 0, 6)
				rule:SetTall(30)
				rule:SetText((cat_object.numbering and '#' .. ruleID .. ' ' or '') .. rule_object.rule)

				DrawButton(rule)

				rule.DoClick = function()
					RuleCreate(rule_object)
				end
				rule:SetTooltip('ПКМ, чтобы отредактировать правило')
				rule.DoRightClick = function()
					local DM = DermaMenu()
					DM:AddOption('Переименовать правило', function()
						Derma_StringRequest('Смена названия правила', 'На что планируете сменить?', rule_object.rule, function(s)
							rule_object.rule = s
	
							CreateCategoryList()
						end)
					end):SetIcon('icon16/table_refresh.png')
					DM:AddOption('Изменить цвет правила', function()
						local currect_rule_color = tonumber(rule_object.color.r) .. ' ' .. tonumber(rule_object.color.g) .. ' ' .. tonumber(rule_object.color.b)

						Derma_StringRequest('Поставить цвет правилу', 'Пример: 255 255 0', currect_rule_color, function(s)
							rule_object.color = util.StringToType(s, 'Vector')
	
							CreateCategoryList()
						end)
					end):SetIcon('icon16/color_wheel.png')
					DM:AddOption('Удалить правило', function()
						table.remove(cat_object.content, ruleID)
	
						CreateCategoryList()

						PlaySound()
					end):SetIcon('icon16/delete.png')
					DM:Open()
				end
			end
		end
	end

	CreateCategoryList()

	if data[1] and data[1].content[1] then
		RuleCreate(data[1].content[1])
	end

	local BtnSave = vgui.Create('DButton', CategoryPanel)
	BtnSave:Dock(BOTTOM)
	BtnSave:SetTall(20)
	BtnSave:SetText('Сохранить')
	BtnSave.DoClick = function()
		net.Start('FatedRules-ToServer')
			net.WriteTable(data)
		net.SendToServer()

		CreateCategoryList()

		PlaySound()
	end

	DrawButton(BtnSave, Color(57,128,78))

	local BtnAddCat = vgui.Create('DButton', CategoryPanel)
	BtnAddCat:Dock(BOTTOM)
	BtnAddCat:DockMargin(0, 0, 0, 6)
	BtnAddCat:SetTall(20)
	BtnAddCat:SetText('Добавить категорию')
	BtnAddCat.DoClick = function()
		local new_id = #data + 1

		data[new_id] = {
			category = 'Category #' .. new_id,
			content = {},
			icon = '',
			numbering = false,
		}

		CreateCategoryList()

		PlaySound()
	end

	DrawButton(BtnAddCat, Color(189,104,35))
end

concommand.Add('fated_rules_menu', function()
	FatedRules.Open()
end)

net.Receive('FatedRules-ToClient', function()
	FatedRules.data = net.ReadTable()
end)
