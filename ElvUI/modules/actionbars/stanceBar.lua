local E, L, V, P, G, _ = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB, Localize Underscore
local AB = E:GetModule('ActionBars');

local ceil = math.ceil;

local bar = CreateFrame('Frame', 'ElvUI_BarShapeShift', E.UIParent, 'SecureHandlerStateTemplate');

local states = {
	["DRUID"] = "show",
	["WARRIOR"] = "show",
	["PALADIN"] = "show",
	["DEATHKNIGHT"] = "show",
	["ROGUE"] = "show",
	["PRIEST"] = "show",
	["HUNTER"] = "show",
	["WARLOCK"] = "show",
	["MONK"] = "show",
};

function AB:StyleShapeShift()
	local numForms = GetNumShapeshiftForms();
	local texture, name, isActive, isCastable;
	local buttonName, button, icon, cooldown;
	local start, duration, enable;
	
	for i = 1, NUM_STANCE_SLOTS do
		buttonName = "ElvUI_BarShapeShiftButton"..i;
		button = _G[buttonName];
		icon = _G[buttonName.."Icon"];
		cooldown = _G[buttonName.."Cooldown"];
		
		if i <= numForms then
			texture, name, isActive, isCastable = GetShapeshiftFormInfo(i);
			icon:SetTexture(texture);
			
			if texture then
				cooldown:SetAlpha(1);
			else
				cooldown:SetAlpha(0);
			end
			
			start, duration, enable = GetShapeshiftFormCooldown(i);
			CooldownFrame_SetTimer(cooldown, start, duration, enable);
			
			if isActive then
				StanceBarFrame.lastSelected = button:GetID();
				button:SetChecked(1);
			else
				button:SetChecked(0);
			end

			if isCastable then
				icon:SetVertexColor(1.0, 1.0, 1.0);
			else
				icon:SetVertexColor(0.4, 0.4, 0.4);
			end
		end
	end
end

function AB:PositionAndSizeBarShapeShift()
	local spacing = E:Scale(self.db['barShapeShift'].buttonspacing);
	local buttonsPerRow = self.db['barShapeShift'].buttonsPerRow;
	local numButtons = self.db['barShapeShift'].buttons;
	local size = E:Scale(self.db['barShapeShift'].buttonsize);
	local point = self.db['barShapeShift'].point;
	local widthMult = self.db['barShapeShift'].widthMult;
	local heightMult = self.db['barShapeShift'].heightMult;
	bar.db = self.db['barShapeShift']
	bar.db.position = nil; --Depreciated
	if bar.LastButton and numButtons > bar.LastButton then	
		numButtons = bar.LastButton;
	end

	if bar.LastButton and buttonsPerRow > bar.LastButton then	
		buttonsPerRow = bar.LastButton;
	end
	
	if numButtons < buttonsPerRow then
		buttonsPerRow = numButtons;
	end
	
	local numColumns = ceil(numButtons / buttonsPerRow);
	if numColumns < 1 then
		numColumns = 1;
	end

	bar:SetWidth(spacing + ((size * (buttonsPerRow * widthMult)) + ((spacing * (buttonsPerRow - 1)) * widthMult) + (spacing * widthMult)));
	bar:SetHeight(spacing + ((size * (numColumns * heightMult)) + ((spacing * (numColumns - 1)) * heightMult) + (spacing * heightMult)));
	bar.mouseover = self.db['barShapeShift'].mouseover
	if self.db['barShapeShift'].enabled then
		bar:SetScale(1);
		bar:SetAlpha(1);
	else
		bar:SetScale(0.000001);
		bar:SetAlpha(0);
	end
	
	if self.db['barShapeShift'].backdrop == true then
		bar.backdrop:Show();
	else
		bar.backdrop:Hide();
	end
	
	bar.backdrop:SetParent(StanceButton1)
	bar.backdrop:SetFrameStrata('BACKGROUND')
	bar.backdrop:SetFrameLevel(StanceButton1:GetFrameLevel() - 1)
	
	local horizontalGrowth, verticalGrowth;
	if point == "TOPLEFT" or point == "TOPRIGHT" then
		verticalGrowth = "DOWN";
	else
		verticalGrowth = "UP";
	end
	
	if point == "BOTTOMLEFT" or point == "TOPLEFT" then
		horizontalGrowth = "RIGHT";
	else
		horizontalGrowth = "LEFT";
	end
	
	local button, lastButton, lastColumnButton;
	local possibleButtons = {};
	for i=1, NUM_STANCE_SLOTS do
		button = _G["ElvUI_BarShapeShiftButton"..i];
		lastButton = _G["ElvUI_BarShapeShiftButton"..i-1];
		lastColumnButton = _G["ElvUI_BarShapeShiftButton"..i-buttonsPerRow];
		button:SetParent(bar);
		button:ClearAllPoints();
		button:Size(size);
		
		possibleButtons[((i * buttonsPerRow) + 1)] = true;

		if self.db['barShapeShift'].mouseover == true then
			bar:SetAlpha(0);
			if not self.hooks[bar] then
				self:HookScript(bar, 'OnEnter', 'Bar_OnEnter');
				self:HookScript(bar, 'OnLeave', 'Bar_OnLeave');	
			end
			
			if not self.hooks[button] then
				self:HookScript(button, 'OnEnter', 'Button_OnEnter');
				self:HookScript(button, 'OnLeave', 'Button_OnLeave');					
			end
		else
			bar:SetAlpha(1);
			if self.hooks[bar] then
				self:Unhook(bar, 'OnEnter');
				self:Unhook(bar, 'OnLeave');
			end
			
			if self.hooks[button] then
				self:Unhook(button, 'OnEnter');	
				self:Unhook(button, 'OnLeave');		
			end
		end
		
		if i == 1 then
			local x, y;
			if point == "BOTTOMLEFT" then
				x, y = spacing, spacing;
			elseif point == "TOPRIGHT" then
				x, y = -spacing, -spacing;
			elseif point == "TOPLEFT" then
				x, y = spacing, -spacing;
			else
				x, y = -spacing, spacing;
			end
			
			button:Point(point, bar, point, x, y);
		elseif possibleButtons[i] then
			local x = 0;
			local y = -spacing;
			local buttonPoint, anchorPoint = "TOP", "BOTTOM";
			if verticalGrowth == 'UP' then
				y = spacing;
				buttonPoint = "BOTTOM";
				anchorPoint = "TOP";
			end
			button:Point(buttonPoint, lastColumnButton, anchorPoint, x, y);		
		else
			local x = spacing;
			local y = 0;
			local buttonPoint, anchorPoint = "LEFT", "RIGHT";
			if horizontalGrowth == 'LEFT' then
				x = -spacing;
				buttonPoint = "RIGHT";
				anchorPoint = "LEFT";
			end
			
			button:Point(buttonPoint, lastButton, anchorPoint, x, y);
		end
		
		if i > numButtons then
			button:SetScale(0.000001);
			button:SetAlpha(0);
		else
			button:SetScale(1);
			button:SetAlpha(1);
		end
		
		self:StyleButton(button);
		self:StyleShapeShift();
	end
	possibleButtons = nil;
end

function AB:AdjustMaxStanceButtons()
	if InCombatLockdown() then return; end
	
	for i=1, #bar.buttons do
		bar.buttons[i]:Hide()
	end
	
	for i = 1, NUM_STANCE_SLOTS do
		if not bar.buttons[i] then
			bar.buttons[i] = CreateFrame("CheckButton", format(bar:GetName().."Button%d", i), bar, "StanceButtonTemplate")
			bar.buttons[i]:SetID(i)
		end
		
		local _, name = GetShapeshiftFormInfo(i);
		if name then
			bar.buttons[i]:Show();
			bar.LastButton = i;
		else
			bar.buttons[i]:Hide();
		end
	end
	self:PositionAndSizeBarShapeShift();
end

function AB:CreateBarShapeShift()
	bar:CreateBackdrop('Default');
	bar.backdrop:SetAllPoints();
	bar:Point('TOPLEFT', LeftChatPanel, 'TOPRIGHT', 2, 4);
	bar.buttons = {};
	bar:SetAttribute("_onstate-show", [[		
		if newstate == "hide" then
			self:Hide();
		else
			self:Show();
		end	
	]]);

	self:RegisterEvent('UPDATE_SHAPESHIFT_FORMS', 'AdjustMaxStanceButtons');
	self:RegisterEvent('UPDATE_SHAPESHIFT_USABLE', 'StyleShapeShift');
	self:RegisterEvent('UPDATE_SHAPESHIFT_COOLDOWN', 'StyleShapeShift');
	self:RegisterEvent('UPDATE_SHAPESHIFT_FORM', 'StyleShapeShift');
	self:RegisterEvent('ACTIONBAR_PAGE_CHANGED', 'StyleShapeShift');
	
	E:CreateMover(bar, 'ShiftAB', 'Stance Bar', nil, -3, nil, 'ALL,ACTIONBARS');
	self:AdjustMaxStanceButtons();
	self:PositionAndSizeBarShapeShift();
	RegisterStateDriver(bar, "show", '[petbattle] hide;'..states[E.myclass] or "hide");
end