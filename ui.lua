local screen = UI.ScreenSize()
local center = {x = screen.width / 2, y = screen.height / 2}


local CircleRadius = 100
local CircleStartAngle = 135
local CircleEndAngle = 405
local CircleTotalAngle = CircleEndAngle - CircleStartAngle

local SpeedOmeter_X = center.x
local SpeedOmeter_Y = screen.height - CircleRadius - 50
local SpeedOmeter_Maximun = 500

Boxs = {}

BoxSize = 3
BoxCount = 200
BoxWidth = 4

for i = 0, BoxWidth-1 do
	Boxs[i] = {}
	for j = 0, BoxCount-1 do
		local currAngle = j / BoxCount * CircleTotalAngle
		local x_cos = math.cos(math.rad(currAngle + CircleStartAngle))
		local y_sin = math.sin(math.rad(currAngle + CircleStartAngle))
		local radius = CircleRadius - (i - 1)
		
		local color = {r = 50, g = 200, b = 60}
		if currAngle >= 225 then
			color = {r = 220, g = 50, b = 50}
		elseif currAngle >= 180 then
			color = {r = 250, g = 160, b = 20}
		end
		
		Boxs[i][j] = UI.Box.Create()
		Boxs[i][j]:Set(color)
		Boxs[i][j]:Set({
			  x = SpeedOmeter_X + radius * x_cos - BoxSize / 2
			, y = SpeedOmeter_Y + radius * y_sin - BoxSize / 2
			, width = BoxSize
			, height = BoxSize
		})
	end
end

Texts = {}

TextSize = 30
TextCount = 8

for i = 0, TextCount do
	local currAngle = i / TextCount * CircleTotalAngle
	local x_cos = math.cos(math.rad(currAngle + CircleStartAngle))
	local y_sin = math.sin(math.rad(currAngle + CircleStartAngle))
	local radius = CircleRadius - 20
	
	local speed_num = i / TextCount * SpeedOmeter_Maximun
	
	Texts[i] = UI.Text.Create()
	Texts[i]:Set({
		text = string.format("%.0f", speed_num)
		, font = "small"
		, align = "center"
		, x = SpeedOmeter_X + radius * x_cos - TextSize / 2
		, y = SpeedOmeter_Y + radius * y_sin - TextSize / 2 + 12
		, width = TextSize
		, height = TextSize
		, r = 255, g = 255, b = 255
	})
end


Lines = {}

LineSize = 3


-- https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm
function Line(x0, y0, x1, y1)
	local dx = math.abs(x1 - x0)
    local sx = x0 < x1 and 1 or -1
    local dy = -math.abs(y1 - y0)
    local sy = y0 < y1 and 1 or -1
    local _error = dx + dy
	
	local LineCount = 0
	
	while true do
		if not Lines[LineCount] then Lines[LineCount] = UI.Box.Create() end
		
		Lines[LineCount]:Show()
		Lines[LineCount]:Set({
			  x = x0
			, y = y0
			, width = LineSize
			, height = LineSize
			, r = 255, g = 50, b = 50
		})
		LineCount = LineCount + 1
		
		if x0 == x1 and y0 == y1 then break end
		local e2 = 2 * _error
		if e2 >= dy then
			if x0 == x1 then break end
			_error = _error + dy
			x0 = x0 + sx
		end
		if e2 <= dx then
			if y0 == y1 then break end
			_error = _error + dx
			y0 = y0 + sy
		end
    end
	
	if LineCount < #Lines then
		for i = LineCount, #Lines do
			Lines[i]:Hide()
		end
	end
	
	LineCount = 0
end

-- code from AnggaraNothing
function math.clamp(min, max, value)
    return math.min(max, math.max(min , value))
end


--------------------------------
--------------------------------
--------------------------------

hud_speed_bg = UI.Text.Create()
hud_speed_bg:Set({
	font = "medium"
	, align = "center"
	, x = SpeedOmeter_X - CircleRadius + 2
	, y = SpeedOmeter_Y + CircleRadius / 2 + 2
	, width = CircleRadius * 2
	, height = 30
	, r = 30, g = 30, b = 30
})
hud_speed = UI.Text.Create()
hud_speed:Set({
	font = "medium"
	, align = "center"
	, x = SpeedOmeter_X - CircleRadius
	, y = SpeedOmeter_Y + CircleRadius / 2
	, width = CircleRadius * 2
	, height = 30
	, r = 255, g = 255, b = 255
})
label_speed = UI.Text.Create()
label_speed:Set({
	text = "unit/sec"
	, font = "small"
	, align = "center"
	, x = SpeedOmeter_X - CircleRadius
	, y = SpeedOmeter_Y + CircleRadius / 2 + 28
	, width = CircleRadius * 2
	, height = 30
	, r = 255, g = 255, b = 255
}) 


sync_speed = UI.SyncValue.Create("speed" .. UI.PlayerIndex())
function sync_speed:OnSync()
	local value = self.value
	
	local percent = math.clamp(0, 1, value / SpeedOmeter_Maximun)
	local angle = percent * CircleTotalAngle
	
	local x = SpeedOmeter_X + (CircleRadius-30) * math.cos(math.rad(angle + CircleStartAngle))
	local y = SpeedOmeter_Y + (CircleRadius-30) * math.sin(math.rad(angle + CircleStartAngle)) 
	Line(math.floor(x), math.floor(y), SpeedOmeter_X, SpeedOmeter_Y)
	
	hud_speed_bg:Set({text = string.format("%.0f", value)})
	hud_speed:Set({text = string.format("%.0f", value)})
end


function UI.Event:OnUpdate(time)
	UI.Signal(1)
end