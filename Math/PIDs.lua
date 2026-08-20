---@section PID_Deprecated
---Initializes simple pid
---@param Kp number
---@param Kd number
---@param Ki number
---@return table PID
function PID_Deprecated(Kp, Kd, Ki)
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

---@section IntegralBoundPID_Deprecated
---Initializes pid with bound integral
---@param Kp number
---@param Kd number
---@param Ki number
---@param limit number
---@return table PID
function IntegralBoundPID_Deprecated(Kp, Kd, Ki, limit)
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


---@section PID
---Initializes simple pid
---oMin - lower limit for control signal
---oMax - upper limit for control signal
---intLimit - limit for integral component of a PID
---@param kp number
---@param kd number
---@param ki number
---@param oMin number
---@param oMax number
---@param intLimit number
---@return table PID
function PID(kp,ki,kd,oMin,oMax,intLimit)
    return {
        kp=kp,
        ki=ki,
        kd=kd,
        intrl=0,
        pErr=0,
        oMin=oMin or -1,
        oMax=oMax or 1,
        intLimit=intLimit or 10,
        control = 0,
        ---Updates PID
        ---sp - setpoint
        ---pv - process variable
        ---enable - if pid is enabled
        ---@param self table
        ---@param sp number
        ---@param pv number
        ---@param enable boolean
        ---@return integer
        update=function(self,sp,pv,enable)
            enable = enable == nil and true or enable
            if not enable then
                self.intrl=0
                self.pErr=0
                return 0
            end
            local error=sp-pv
            self.intrl=self.intrl+error
            if self.intrl>self.intLimit then
                self.intrl=self.intLimit
            elseif self.intrl<-self.intLimit then
                self.intrl=-self.intLimit
            end
            local der=error-self.pErr
            self.pErr=error
            self.control =
                self.kp*error+
                self.ki*self.intrl+
                self.kd*der
            if self.control>self.oMax then
                self.control=self.oMax
            elseif self.control<self.oMin then
                self.control=self.oMin
            end
            return self.control
        end
    }
end
---@endsection