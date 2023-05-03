local module = {}
module.__index = module

-- local current, default, max = 16, 16, 150 local per = current / max warn("percentage:", per, "value:", per * max)
-- services --
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")


-- client stuff --
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local PlayerGui = Player:WaitForChild("PlayerGui")


-- Library --
local Resources = require(game:GetObjects("rbxassetid://13333096034")[1])()
local Objects = {
	Tab = Resources.Tab,
	Element = Resources.Elements
}


-- window --
function module.new(properties)

	local self = setmetatable({}, module)
	local Title, Description = properties.Title, properties.Description


	-- cleanup old interfaces --
	for _, v in next, PlayerGui:GetChildren() do
		if v.Name == "Interface" then
			v:Destroy()
		end
	end


	-- class structor --
	self.Interface = {}
	self.Interface.UI = Instance.new("ScreenGui", PlayerGui)
	self.Interface.WIN = Instance.new("Frame", self.Interface.UI)
	self.Interface.TABS = Instance.new("Frame", self.Interface.WIN)
	self.Interface.INFO = {
		Tabs = {},	-- Tabs {1, 2, 3 etc...}
		Settings = {
			Draggable = true,	-- Movability
			UseShadow = true,	-- Shadow
			UseDarkTE = true	-- Theme
		},
		Index = 0, -- Current tab
		MaxIndex = 6 -- Max tabs (allowed tabs to be created)
	}


	-- assigns structors --
	local UIShadowWIN = Instance.new("ImageLabel", self.Interface.WIN)
	UIShadowWIN.Name = "shadow"
	UIShadowWIN.Image = "rbxassetid://297694300"
	UIShadowWIN.ZIndex = 0
	local UICornerWIN = Instance.new("UICorner", self.Interface.WIN)
	UICornerWIN.CornerRadius = UDim.new(0, 8)

	local TitleWIN, DescWIN = Instance.new("TextLabel", self.Interface.WIN), Instance.new("TextLabel", self.Interface.WIN)
	TitleWIN.Text = Title or "Window"
	DescWIN.Text = Description and (Description):lower() or "description"

	local TabSection = self.Interface.TABS
	local UIListlayout = Instance.new("UIListLayout", TabSection)

	for i, v in next,
		{
			Padding = UDim.new(0, 6),
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center
		} do
		UIListlayout[i] = v
	end

	for i, v in next,
		{
			Name = "Tabs",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromScale(),
			Position = UDim2.fromScale(),
			BackgroundTransparency = 1
		} do
		TabSection[i] = v
	end

	for i, v in next,
		{
			Name = "title",
			TextSize = 22,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromScale(0.35, 0.05),
			Position = UDim2.fromScale(0.22, 0.1),
			BackgroundTransparency = 1
		} do
		TitleWIN[i] = v
	end

	for i, v in next,
		{
			Name = "description",
			TextSize = 18,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromScale(0.35, 0.05),
			Position = UDim2.fromScale(0.22, 0.14),
			BackgroundTransparency = 1
		} do
		TitleWIN[i] = v
	end

	for i, v in next,
		{
			Name = "Interface"
		} do
		self.Interface.UI[i] = v
	end
	for i, v in next,
		{
			Name = "window",
			BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		} do
		self.Interface.WIN[i] = v
	end

	local Settings = self.Interface.INFO.Settings
	if Settings.Draggable then
		local function AddDraggingFunctionality(DragPoint, Main)
			pcall(function()
				local Dragging, DragInput, MousePos, FramePos = false, nil, nil, nil
				DragPoint.InputBegan:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Dragging = true
						MousePos = Input.Position
						FramePos = Main.Position

						Input.Changed:Connect(function()
							if Input.UserInputState == Enum.UserInputState.End then
								Dragging = false
							end
						end)
					end
				end)
				DragPoint.InputChanged:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseMovement then
						DragInput = Input
					end
				end)
				UserInputService.InputChanged:Connect(function(Input)
					if Input == DragInput and Dragging then
						local Delta = Input.Position - MousePos
						TweenService:Create(Main, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position  = UDim2.new(FramePos.X.Scale,FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)}):Play()
					end
				end)
			end)
		end 
		AddDraggingFunctionality(UserInputService, self.ENV.Window)
		if Settings.UseShadow == false then
			UIShadowWIN.Visible = false
		end
		if Settings.UseDarkTE == false then
			--> Apply white theme
		end
	end


	-- class functions --
	local add_element = function(...)
		local t = {...}
		local Tabs = self.Interface.INFO.Tabs
		local Index = self.Interface.INFO.Index
		local Elements = Tabs[Index]
		local ElementsIndex = #Elements + 1
		if t[1] == "string" and type(t[2]) == "function" then
			Elements[ElementsIndex] = {
				Object = nil -- <button>
			}
		elseif type(t[1]) == "string" and type(t[2]) == "table" and type(t[3]) == "function" then
			Elements[ElementsIndex] = {
				Object = Objects.Elements.Slider:Clone(),
				Ranges = {
					Min = t[2][1],
					Def = t[2][2],
					Max = t[2][3]
				},
				Callback = t[3]
			}
			Elements[ElementsIndex].Object.label.Text = t[1]
			Elements[ElementsIndex].Object.value.Text = tostring(Elements[ElementsIndex].Ranges.Def)
			local current, min, max = Elements[ElementsIndex].Ranges.Def, Elements[ElementsIndex].Ranges.Min, Elements[ElementsIndex].Ranges.Max
			Elements[ElementsIndex].Connection = Elements[ElementsIndex].Object.bar.MouseMoved:Connect(function(x, y)
				local x = (x / 100 / Elements[ElementsIndex].Object.bar.Size.X.Scale) / 10
				current = x
				Elements[ElementsIndex].Object.value.Text = tostring(x * max ~= 0 and x * max or min)
				TweenService:Create(
					Elements[ElementsIndex].Object.bar.percentage,
					TweenInfo.new(0.1, Enum.EasingStyle.Linear),
					{
						Size = UDim2.fromScale(x, 1)
					}
				):Play()
				Elements[ElementsIndex].Callback(x * max)
			end)
		elseif type(t[1]) == "string" and type(t[2]) == "boolean" and type(t[3]) == "function" then
			Elements[ElementsIndex] = {
				Object = Objects.Elements.Toggle:Clone(),
				Value = t[2],
				Callback = t[3]	
			}
			Elements[ElementsIndex].Object.label.Text = t[1]
			local toggle = {
				[true] = {
					bar = {BackgroundColor3 = Color3.fromRGB(0, 132, 255)},
					pointer = {Position = UDim2.fromScale(0.7, 0.5)}
				},
				[false] = {
					bar = {BackgroundColor3 = Color3.fromRGB(26, 26, 26)},
					pointer = {Position = UDim2.fromScale(0.3, 0.5)}
				}
			}
			local isEnabled = Elements[ElementsIndex].Value
			if isEnabled then Elements[ElementsIndex].Callback(isEnabled) end
			Elements[ElementsIndex].Object.trigger.MouseButton1Click:Connect(function()
				isEnabled = not isEnabled
				TweenService:Create(Elements[ElementsIndex].Object.bar.pointer, TweenInfo.new(0.3, Enum.EasingStyle.Sine), toggle[isEnabled].pointer):Play()
				TweenService:Create(Elements[ElementsIndex].Object.bar, TweenInfo.new(0.3, Enum.EasingStyle.Sine), toggle[isEnabled].bar):Play()
				Elements[ElementsIndex].Callback(isEnabled)
			end)
		end
	end

	self.add_tab = function(Name, Elements)
		local classElements = Elements or {}
		local className = Name or "Tab"..tostring(#self.Interface.INFO.Tabs + 1)
		local index = #self.Interface.INFO.Tabs + 1
		if not (index > self.Interface.INFO.MaxIndex) then
			self.Interface.INFO.Index = index
		else
			return
		end
		self.Interface.INFO.Tabs[index] = {
			Type = "Tab",
			Tab = Objects.Tab.tab:Clone(),
			Content = Objects.Tab.Content:Clone(),
			Elements = classElements
		}
		self.Interface.INFO.Tabs[index].Tab.Parent = self.Interface.TABS
		self.Interface.INFO.Tabs[index].Content.Parent = self.Interface.WIN
		self.Interface.INFO.Tabs[index].Tab.TextColor3 = (self.Interface.INFO.Tabs ~= (self.Interface.INFO.Tabs>1) and Color3.fromRGB(255, 255, 255))or Color3.fromRGB(112, 112, 112)
		self.Interface.INFO.Tabs[index].Tab.BackgroundColor3 = (self.Interface.INFO.Tabs ~= (self.Interface.INFO.Tabs>1) and Color3.fromRGB(0, 132, 255))or Color3.fromRGB(30, 30, 30)
		self.Interface.INFO.Tabs[index].Content.Visible = (self.Interface.INFO.Tabs ~= (self.Interface.INFO.Tabs>1) and true)or false
		return index
	end

	self.on_tab_event = function(index)
		for _, v in next, self.Interface.INFO.Tabs do
			if _ == index then
				v.Tab.TextColor3 = Color3.fromRGB(255, 255, 255)
				v.Tab.BackgroundColor3 = Color3.fromRGB(0, 132, 255)
				v.Content.Visible = true
			else
				v.Tab.TextColor3 = Color3.fromRGB(112, 112, 112)
				v.Tab.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
				v.Content.Visible = false
			end
		end
	end

	return self
end


function module:Tab(Text)
	self.on_tab_event(self.add_tab(Text, nil))
	return module
end


function module:Label(Text)
	self.add_element("Label", Text)
end


function module:Toggle(Text, State, Callback)
	self.add_element("Toggle", Text, State, Callback)
end

function module:Slider(Text, Min, Def, Max, Callback)
	self.add_element("Slider", Text, Min, Def, Max, Callback)
end


-- removal --
function module:Remove()
	pcall(function()
		local ui_object = game:GetService("CoreGui"):FindFirstChild("Interface") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Interface")
		if ui_object then ui_object:Destroy() end
	end)
end

return module
