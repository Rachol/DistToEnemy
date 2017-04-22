local DistToEnemy = {}

DistToEnemy.optionEnable = Menu.AddOption( {"Awareness", "Show distance to enemy"}, "Enable", "")
DistToEnemy.range = Menu.AddOption( {"Awareness", "Show distance to enemy"}, "Search distance", "Search distance used to detect enamies, even if not visible", 100,2000,100)

local calculateOnce = 0
local circlePoints = {}
 

function DistToEnemy.OnDraw()
	if Menu.IsEnabled(DistToEnemy.optionEnable) then
		Renderer.SetDrawColor(240, 230, 140, 255)
		-- Draw rabges
		DistToEnemy.DrawEnemyRanges(Menu.GetValue(DistToEnemy.range))
	end
end

function DistToEnemy.DrawEnemyRanges(maxRange)
	local currentCount = 0
	for range=100,maxRange,10 do
		local enemiesInRange = DistToEnemy.CountEnemyInRange(range)
		if enemiesInRange > currentCount then
			currentCount = enemiesInRange
			DistToEnemy.DrawRange(Heroes.GetLocal(), range)
		end
	end
end

function DistToEnemy.DrawRange(hero, range)
	local heroPos = Entity.GetAbsOrigin(hero)
	if calculateOnce == 0 then
		local degree = math.pi/180
		for i=0,360 do
			local x = math.cos(degree*i)
			local y = math.sin(degree*i)
			circlePoints[i] = {[0] = x, [1] = y}
		end
		calculateOnce = 1
	end
	for i=0,359 do
		local x1 = math.floor(heroPos:GetX() + range*circlePoints[i][0])
		local y1 = math.floor(heroPos:GetY() + range*circlePoints[i][1])
		local x2 = math.floor(heroPos:GetX() + range*circlePoints[i+1][0])
		local y2 = math.floor(heroPos:GetY() + range*circlePoints[i+1][1])
		
		local p1 = Vector(x1, y1, heroPos:GetZ())
		local p2 = Vector(x2, y2, heroPos:GetZ())
		
		local tx1, ty1, vis = Renderer.WorldToScreen(p1)
		local tx2, ty2, vis = Renderer.WorldToScreen(p2)

		Renderer.DrawLine(tx1, ty1, tx2, ty2)
		
	end
end

function DistToEnemy.CountEnemyInRange(range)
	local entities = Heroes.GetAll()
	local me = Heroes.GetLocal()
	local inRangeCount = 0
	for index, ent in pairs(entities) do
		local enemyhero = Heroes.Get(index)
		if not Entity.IsSameTeam(me, enemyhero)  and not NPC.IsIllusion(enemyhero) and NPC.IsEntityInRange(me, enemyhero, range) then
			inRangeCount = inRangeCount + 1
		end
	end
	return inRangeCount
end



return DistToEnemy
