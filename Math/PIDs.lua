---@section PID
---Initializes simple pid
---@param Kp number
---@param Kd number
---@param Ki number
---@return table PID
function PID(Kp, Kd, Ki)
    return {
        Kp = Kp,
        Kd = Kd,
        Ki = Ki,
        previous_error = 0,
        I = 0,
        step = function (self, setpoint, variable, dt)
            local dt = dt or 1
            local error = setpoint - variable
            local P = error
            self.I = self.I + error*dt
            local D = (error - self.previous_error) / dt
            local output = self.Kp * P + self.Ki * self.I + self.Kd * D
            self.previous_error = error
            return output
        end
    }
end
---@endsection

---@section IntegralBoundPID
---Initializes pid with bound integral
---@param Kp number
---@param Kd number
---@param Ki number
---@param limit number
---@return table PID
function IntegralBoundPID(Kp, Kd, Ki, limit)
    return {
        Kp = Kp,
        Kd = Kd,
        Ki = Ki,
        previous_error = 0,
        I = 0,
        step = function (self, setpoint, variable, dt)
            local dt = dt or 1
            local error = setpoint - variable
            local P = error
            self.I = self.I + error*dt
            self.I = math.abs(self.I) <= limit and self.I or limit * (math.abs(self.I)/self.I)
            local D = (error - self.previous_error) / dt
            local output = self.Kp * P + self.Ki * self.I + self.Kd * D
            self.previous_error = error
            return output
        end
    }
end
---@endsection
