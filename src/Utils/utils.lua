---@param x real
---@param y real
---@return boolean
function InMapXY(x, y)
    return x > GetRectMinX(bj_mapInitialPlayableArea) and x < GetRectMaxX(bj_mapInitialPlayableArea) and y > GetRectMinY(bj_mapInitialPlayableArea) and y < GetRectMaxY(bj_mapInitialPlayableArea)
end

---@param xa real
---@param ya real
---@param xb real
---@param yb real
---@return real
function DistanceBetweenXY(xa, ya, xb, yb)
	local dx = xb - xa
	local dy = yb - ya
	return math.sqrt(dx * dx + dy * dy)
end

---@param xa real
---@param ya real
---@param xb real
---@param yb real
---@return real radian
function AngleBetweenXY(xa, ya, xb, yb)
	return math.atan(yb - ya, xb - xa)
end

---@param x real
---@param distance real
---@param angle real degrees
---@return real
function MoveX(x, distance, angle)
	return x + distance * math.cos(angle)
end

---@param y real
---@param distance real
---@param angle real degrees
---@return real
function MoveY(y, distance, angle)
	return y + distance * math.sin(angle)
end

-- функия принадлежности точки сектора
-- x1, x2 - координаты проверяемой точки
-- x2, y2 - координаты вершины сектора
-- orientation - ориентация сектора в мировых координатах
-- width - уголовой размер сектора в градусах
-- radius - окружности которой принадлежит сектор
function IsPointInSector(x1, y1, x2, y2, orientation, width, radius)
	local length = DistanceBetweenXY(x1, y1, x2, y2)
	local angle = Acos(Cos(orientation * bj_DEGTORAD) * (x1 - x2) / length + Sin(orientation * bj_DEGTORAD) * (y1 - y2) / length ) * bj_RADTODEG
	return angle <= width and length <= radius
end

GetTerrainZ_location = Location(0, 0)
---@param x real
---@param y real
---@return real
function GetTerrainZ(x, y)
    MoveLocation(GetTerrainZ_location, x, y)
    return GetLocationZ(GetTerrainZ_location)
end

---@param za real начальная высота высота одного края дуги
---@param zb real конечная высота высота другого края дуги
---@param h real максимальная высота на середине расстояния (x = d / 2)
---@param d real общее расстояние до цели
---@param x real расстояние от исходной цели до точки
---@return real
function GetParabolaZ(za, zb, h, d, x)
    return (2 * (za + zb - 2 * h) * (x / d - 1) + zb - za) * x / d + za
end

-- function math.clamp (inb, low, high)
-- 	return math.min( math.max(inb, low ), high )
-- end

-- function math.lerp(a, b, t)
-- 	return a * (1 - t) + b * t
-- end

function math.clamp (inb, low, high)
	return math.min( math.max(inb, low ), high )
end

function math.lerp(a, b, t)
	return a + (b - a) * t
end

function repeatN(t, m)
	return math.clamp(t - math.floor(t / m) * m, 0, m)
end

function lerpTheta(a, b, t)
	local dt = repeatN(b - a, 360)
	if dt>180 then	dt=dt-360 end
	return math.lerp(a, a + dt, t)
end