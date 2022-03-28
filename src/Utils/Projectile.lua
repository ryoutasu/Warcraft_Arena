---@class projectile:table
local Projectiles = {}
local TIMER_PERIOD = 0.03125 -- 1/32
local GROUP = CreateGroup()

gg_lastCreatedProjectile = nil

---@param model string
---@param x number
---@param y number
---@param z number
---@param speed number
---@param arc number
---@param tx number target x
---@param ty number target y
---@param tz number target z
---@param func function
---@return projectile
function createProjectileToXY(model, x, y, z, speed, arc, tx, ty, tz, func)
    local projectile    = {}
    projectile.missile  = AddSpecialEffect(model, x, y)
    projectile.x        = x or 0
    projectile.y        = y or 0
    projectile.z        = GetTerrainZ(x, y) + z -- current z
    projectile.sx        = x or 0 -- starting x
    projectile.sy        = y or 0 -- starting y
    projectile.sz       = GetTerrainZ(x, y) + z -- starting z
    BlzSetSpecialEffectZ(projectile.missile, projectile.z)
    projectile.speed    = speed or 500
    projectile.homing   = false
    projectile.tx       = tx or 0
    projectile.ty       = ty or 0
    projectile.tz       = GetTerrainZ(tx, ty) + tz
    local dx            = tx - x
    local dy            = ty - y
    local dz            = (projectile.z + projectile.tz) / 2
    projectile.distance = math.sqrt((dx * dx) + (dy * dy))
    projectile.arc      = arc or dz / projectile.distance -- if no arc, move it linear
    projectile.angle    = math.atan(dy, dx)
    projectile.way      = 0
    projectile.func     = func -- funcion exetued when way >= distance

    table.insert(Projectiles, projectile)
    projectile.index = #Projectiles
    gg_lastCreatedProjectile = projectile
    return projectile
end

---@param model string
---@param x number
---@param y number
---@param z number
---@param speed number
---@param arc number
---@param target widget
---@param tz number target z
---@param homing boolean
---@param func function
---@return projectile
function createProjectileToTarget(model, x, y, z, speed, arc, target, tz, homing, func)
    local projectile    = {}
    projectile.missile  = AddSpecialEffect(model, x, y)
    projectile.x        = x or 0
    projectile.y        = y or 0
    projectile.z        = GetTerrainZ(x, y) + z -- current z
    projectile.sx        = x or 0 -- starting x
    projectile.sy        = y or 0 -- starting y
    projectile.sz       = GetTerrainZ(x, y) + z -- starting z
    BlzSetSpecialEffectZ(projectile.missile, projectile.z)
    projectile.speed    = speed or 1000
    projectile.homing   = homing or false
    projectile.target   = target
    local tx, ty        = GetWidgetX(target), GetWidgetY(target)
    projectile.tz       = homing and GetTerrainZ(tx, ty) + tz or tz
    local dx            = tx - x
    local dy            = ty - y
    local dz            = (projectile.z + projectile.tz) / 2
    projectile.distance = math.sqrt((dx * dx) + (dy * dy))
    projectile.arc      = arc or dz / projectile.distance -- if no arc, move it linear
    projectile.angle    = math.atan(dy, dx)
    projectile.way      = 0
    projectile.func     = func -- funcion exetued when way >= distance

    table.insert(Projectiles, projectile)
    projectile.index = #Projectiles
    gg_lastCreatedProjectile = projectile
    return projectile
end

---@param projectile projectile
---@param radius number
---@param func function
function addProjectileUnitImpact(projectile, radius, func)
    projectile.radius = radius
    projectile.collideFunc = func
end

function destroyProjectile(projectile)
    BlzSetSpecialEffectOrientation(projectile.missile, projectile.angle, 0, 0) -- устанавливаем финальное положение эффекта
    DestroyEffect(projectile.missile) -- уничтожаем эффект

    table.remove(Projectiles, projectile.index)
    projectile = nil
end

-- NazarPunk
function initProjectiles()
    TimerStart(CreateTimer(), TIMER_PERIOD, true, function()
        for k, p in ipairs(Projectiles) do
            p.index = k
            local missile   = p.missile
            local tx        = GetWidgetX(p.target) or p.tx
            local ty        = GetWidgetY(p.target) or p.ty
            local sx        = p.x -- current x
            local sy        = p.y -- current y
            local dx        = tx - p.sx
            local dy        = ty - p.sy
            local distance  = p.homing and math.sqrt((dx * dx) + (dy * dy)) or p.distance -- if homing enabled, calculate new distance
            local angle     = p.homing and math.atan(ty - sy, tx - sx) or p.angle -- same as for distance
            local cos, sin  = math.cos(angle), math.sin(angle)
            local speed_inc = p.speed * TIMER_PERIOD
            local tz        = p.homing and GetTerrainZ(tx, ty) + p.tz or p.tz
            local radius    = p.radius or 0
            
            p.way = p.way + speed_inc
            p.x = sx + cos * speed_inc -- считаем новое положение снаряда
            p.y = sy + sin * speed_inc -- считаем новое положение снаряда

            if p.way >= distance -- если расстояние равно 0, значит снаряд уже долетел
            or not InMapXY(p.x, p.y) --снаряд вышел за пределы карты
            then
                local func = p.func
                destroyProjectile(p)
                if func and type(func) == "function" then func() end
                return
            end

            BlzSetSpecialEffectX(missile, p.x) -- устанавливаем положение эффекта
            BlzSetSpecialEffectY(missile, p.y) -- устанавливаем положение эффекта
            local zNew  = GetParabolaZ(p.sz, tz, distance * p.arc, distance, p.way) -- считаем новую высоту эффекта
            BlzSetSpecialEffectZ(missile, zNew) -- устанавливаем новую высоту эффекта
            local zDiff = zNew - p.z -- считаем разницу высот
            local zAngle = zDiff > 0 and math.atan(speed_inc / zDiff) - math.pi / 2 or math.atan(zDiff / speed_inc) - math.pi * 2 -- считаем угол наклона снаряда
            BlzSetSpecialEffectOrientation(missile, angle, zAngle, 0) -- устанавливаем направление эффекта
            p.z = zNew -- запоминаем новую высоту эффекта

            GroupEnumUnitsInRange(GROUP, p.x, p.y, radius)
            for index = BlzGroupGetSize(GROUP) - 1, 0, -1 do
                local target = BlzGroupUnitAt(GROUP, index)
                if p.collideFunc and type(p.collideFunc) == "function" then p.collideFunc(target) end
            end
            GroupClear(GROUP)
        end
    end)
end