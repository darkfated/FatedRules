local color_white = Color(255,255,255)

local function SelectIconMenu(func, active_icon)
	local menu = vgui.Create('fu-frame')
	menu:SetSize(FatedUI.func.w(260), FatedUI.func.w(300))
	menu:Center()
	menu:MakePopup()
	menu:SetTitle('Выбор иконки')
	menu:SetSettings(false)

	local pan = vgui.Create('fu-panel', menu)
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

	local BtnNoIcon = vgui.Create('fu-button', pan)
	BtnNoIcon:Dock(BOTTOM)
	BtnNoIcon:DockMargin(0, 6, 0, 0)
	BtnNoIcon:SetText('Без иконки')
	BtnNoIcon:Rounded(false, false, true, true)
	BtnNoIcon.DoClick = function()
		func('')

		menu:Remove()
	end
end

function FatedRules.Open()
	FatedRules.menu = vgui.Create('fu-frame')
	FatedRules.menu:SetSize(FatedUI.func.w(700), FatedUI.func.h(600))
	FatedRules.menu:Center()
	FatedRules.menu:MakePopup()
	FatedRules.menu:SetTitle('Правила сервера')

	local CategoryPanel = vgui.Create('fu-panel', FatedRules.menu)
	CategoryPanel:Dock(LEFT)
	CategoryPanel:SetWide(FatedUI.func.w(200))
	CategoryPanel:DockPadding(6, 6, 6, 6)

	local MainPanel = vgui.Create('fu-panel', FatedRules.menu)
	MainPanel:Dock(FILL)
	MainPanel:DockMargin(6, 0, 0, 0)
	MainPanel:DockPadding(6, 6, 6, 6)

	CategoryPanel.sp = vgui.Create('fu-sp', CategoryPanel)
	CategoryPanel.sp:Dock(FILL)
	CategoryPanel.sp:DockMargin(0, 0, 0, 6)

	local data = table.Copy(FatedRules.data)

	local function CreateCategoryList()
		CategoryPanel.sp:Clear()

		local data_counts = #data

		for catID = 1, data_counts do
			local cat_object = data[catID]

			local cat = vgui.Create('fu-button', CategoryPanel.sp)
			cat:Dock(TOP)
			cat:DockMargin(0, 0, 0, 6)
			cat:SetTall(FatedUI.func.h(30))
			cat:SetText('')
			cat.Paint = function(_, w, h)
				draw.SimpleText(cat_object.category, 'fu.22', w * 0.5, h * 0.5, c, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

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
				end):SetIcon('icon16/delete.png')
				DM:Open()
			end

			local cat_counts = #cat_object.content

			for ruleID = 1, #cat_object.content do
				local rule_object = cat_object.content[ruleID]

				local rule = vgui.Create('fu-button', CategoryPanel.sp)
				rule:Dock(TOP)
				rule:DockMargin(0, 0, 0, 6)
				rule:SetTall(FatedUI.func.h(30))
				rule:SetText((cat_object.numbering and '#' .. ruleID .. ' ' or '') .. rule_object.rule)
				rule:SetHoverColor(rule_object.color)

				if ruleID == 1 and ruleID == cat_counts then
					rule:Rounded(true, true, true, true)
				elseif ruleID == 1 then
					rule:Rounded(true, true, false, false)
				elseif ruleID == cat_counts then
					rule:Rounded(false, false, true, true)
				end

				local function RuleClick()
					MainPanel:Clear()

					local content_panel = vgui.Create('fu-panel', MainPanel)
					content_panel:Dock(FILL)
					content_panel:DockPadding(6, 6, 6, 6)
					content_panel:Color(2)

					local content_sp = vgui.Create('fu-sp', content_panel)
					content_sp:Dock(FILL)

					local function CreateHeader(txt)
						local header = vgui.Create('fu-panel', content_sp)
						header:Dock(TOP)
						header:DockMargin(0, 0, 0, 6)
						header:SetTall(FatedUI.func.h(30))
						header.Paint = function(_, w, h)
							draw.RoundedBox(6, 0, 0, w, h, rule_object.color)
	
							draw.SimpleText(txt, 'fu.26', 5, h * 0.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
						end
					end

					local function CreateText(txt, id)
						local text = vgui.Create('DLabel', content_sp)
						text:Dock(TOP)
						text:DockMargin(0, 0, 0, 6)
						text:SetText(txt)
						text:SetFont('fu.24')
						text:SetTextColor(color_white)
						text:SetAutoStretchVertical(true)
						text:SetWrap(true)
						text:SetMouseInputEnabled(true)
						text.DoRightClick = function()
							local DM = DermaMenu()
							DM:AddOption('Изменить содержание...', function()
								Derma_StringRequest('Сменить содержание', 'Какое планируете поставить?', txt, function(s)
									rule_object[id] = s

									RuleClick()
								end)
							end):SetIcon('icon16/text_align_left.png')
							DM:Open()
						end
					end

					CreateHeader(rule_object.rule)
					CreateText(rule_object.desc, 'desc')

					CreateHeader('Наказание:')
					CreateText(rule_object.punishment, 'punishment')
				end

				rule.DoClick = function()
					RuleClick()
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
					end):SetIcon('icon16/delete.png')
					DM:Open()
				end
			end
		end
	end

	CreateCategoryList()

	local BtnSave = vgui.Create('fu-button', CategoryPanel)
	BtnSave:Dock(BOTTOM)
	BtnSave:SetTall(FatedUI.func.h(20))
	BtnSave:SetColor(Color(79,158,79))
	BtnSave:SetHoverColor(Color(108,201,108))
	BtnSave:Rounded(true, true, true, true)
	BtnSave:SetText('Сохранить')
	BtnSave.DoClick = function()
		net.Start('FatedRules-ToServer')
			net.WriteTable(data)
		net.SendToServer()

		CreateCategoryList()

		FatedUI.func.Sound()
	end

	local BtnAddCat = vgui.Create('fu-button', CategoryPanel)
	BtnAddCat:Dock(BOTTOM)
	BtnAddCat:DockMargin(0, 0, 0, 6)
	BtnAddCat:SetTall(FatedUI.func.h(20))
	BtnAddCat:SetColor(Color(79,94,158))
	BtnAddCat:SetHoverColor(Color(135,152,231))
	BtnAddCat:Rounded(true, true, true, true)
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
	end
end

concommand.Add('fated_rules_menu', function()
	FatedRules.Open()
end)

net.Receive('FatedRules-ToClient', function()
	FatedRules.data = net.ReadTable()
end)
