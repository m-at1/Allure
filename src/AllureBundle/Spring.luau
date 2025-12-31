--!strict

local UTIL = script.Parent.Parent.Util
local Config = require "../Config"
local Types = require(UTIL.Types)
local Log = require(UTIL.Log)

local RunService = game:GetService "RunService"

local k = 0.01

function multUDim2(a: UDim2, b: number)
	return UDim2.new(a.X.Scale * b, a.X.Offset * b, a.Y.Scale * b, a.Y.Offset * b)
end

function UDim2ToVect2(a: UDim2)
	return Vector2.new(a.X.Scale, a.Y.Scale), Vector2.new(a.X.Offset, a.Y.Offset)
end

function Color3ToVect3(a: Color3)
	return Vector3.new(a.R, a.B, a.G)
end

function Vect3ToColor3(a: Vector3)
	return Color3.new(a.X, a.Y, a.Z)
end

return (
	function<T>(trash: any, start: T & Types.Animatable, speed: number, damping: number): any
		local frameratefn = function(dt) end
		local _key = tostring {}

		local criticaldamping = 2 * math.sqrt(1 * k * speed)
		damping = criticaldamping * damping

        -- stylua: ignore
		local spring = trash
			:State(start)
			:custom"_velocity"(0)
			:setter(function(self: Types.State<T & Types.Animatable> & {_velocity: any}, goal: T & Types.Animatable)
				if typeof(goal) ~= typeof(start) then
					Log.logError("AllureBundle", "springBadType", typeof(start), typeof(goal))
					return start
				end

                if typeof(goal) == "number" then
                    frameratefn = function(dt)
                        if self.__value==goal then return end
        
                        local force = k*(goal - self.__value)
                        if math.abs(goal - self.__value) < Config.SPRING_LASTFRAME_ABS_FORCE and math.abs(force*speed) < k*Config.SPRING_LASTFRAME_ABS_FORCE then
                            self.__value = goal
                            goal = self.__value
      
                            force = 0
                            self._velocity = 0
                            return
                        end

                        self._velocity += force*speed/1
                        self.__value += self._velocity
                        self._velocity *= (1-damping)

                        self:updater()
                    end
                elseif typeof(goal) == "Vector2" or typeof(goal) == "Vector3" then

                    frameratefn = function(dt)
                        if self.__value==goal then return end
        
                        local force = k*(goal - self.__value) :: Vector2
                        if (goal :: Vector2 - self.__value :: Vector2).Magnitude < Config.SPRING_LASTFRAME_ABS_FORCE and (force*speed).Magnitude < k*Config.SPRING_LASTFRAME_ABS_FORCE then
                            self.__value = goal
                            goal = self.__value
      
                            force = Vector2.zero
                            self._velocity = Vector2.zero
                            return
                        end

                        self._velocity += force*speed
                        self.__value += self._velocity
                        self._velocity *= (1-damping)

                        self:updater()
                    end
                elseif typeof(goal) == "Color3" then
                    local val = Color3ToVect3(self.__value)
                    goal = Color3ToVect3(goal)

                    frameratefn = function(dt)
                        if val==goal then return end
        
                        local force = k*(goal - val)
                        if (goal :: Vector3 - val :: Vector3).Magnitude < Config.SPRING_LASTFRAME_ABS_FORCE and (force*speed).Magnitude < k*Config.SPRING_LASTFRAME_ABS_FORCE then
                            val = goal
                            goal = val
      
                            force = Vector3.zero
                            self._velocity = Vector3.zero
                            return
                        end

                        self._velocity += force*speed
                        val += self._velocity

                        self.__value = Vect3ToColor3(val)

                        self._velocity *= (1-damping)

                        self:updater()
                    end
                elseif typeof(goal) == "UDim2" and typeof(self.__value) == "UDim2" then
                    goal = goal :: any
                    frameratefn = function(dt)
                        if self.__value==goal then return end
        
                        local SCALE, OFFSET = UDim2ToVect2(self.__value)

                        local GOAL_SCALE, GOAL_OFFSET = UDim2ToVect2(goal)

                        local FORCE_SCALE = (GOAL_SCALE - SCALE)*k*speed
                        local FORCE_OFFSET = (GOAL_OFFSET - OFFSET)*k*speed

                        if (GOAL_SCALE - SCALE).Magnitude < Config.SPRING_LASTFRAME_ABS_FORCE
                            and (GOAL_OFFSET - OFFSET).Magnitude < 4
                            and FORCE_SCALE.Magnitude < k*Config.SPRING_LASTFRAME_ABS_FORCE
                            and FORCE_OFFSET.Magnitude < 16 then
                            self.__value = goal
                            goal = self.__value
      
                            FORCE_SCALE = 0
                            FORCE_OFFSET = 0
                            self._velocity = UDim2.new(0, 0)
                            return
                        end

                        local VEL_SCALE, VEL_OFFSET = UDim2ToVect2(self._velocity)

                        self._velocity = UDim2.new(VEL_SCALE.X + FORCE_SCALE.X, 
                            VEL_OFFSET.X + math.sign(FORCE_OFFSET.X) * math.ceil(math.abs(FORCE_OFFSET.X)), 
                            VEL_SCALE.Y + FORCE_SCALE.Y, 
                            VEL_OFFSET.Y + math.sign(FORCE_OFFSET.Y) * math.ceil(math.abs(FORCE_OFFSET.Y))
                        )
                        self.__value += self._velocity

                        self._velocity = multUDim2(self._velocity, 1-damping)

                        self:updater()
                    end
                end

				return start
			end)
            :deleter(function(self)
                RunService:UnbindFromRenderStep(_key)
            end)

		spring._velocity = typeof(start) == "number" and 0
			or typeof(start) == "Vector2" and Vector2.new(0, 0)
			or typeof(start) == "Vector3" and Vector3.new(0, 0, 0)
			or typeof(start) == "Color3" and Vector3.new(0, 0, 0)
			or typeof(start) == "UDim2" and UDim2.new(0, 0)

		RunService:BindToRenderStep(_key, Config.SPRING_RENDERSTEP_PRIORITY, function(dt)
			frameratefn(dt)
		end)

		return spring
	end :: any
) :: <T>(
	trash: Types.garbage<Types.Allure & {} & any>,
	start: T & Types.Animatable,
	speed: number,
	damping: number
) -> Types.StateObject<any>
