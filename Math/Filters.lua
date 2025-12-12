---@section ABFilter
---Creates A-B Kalman filter instance
---@param k_max number
---@return table
function ABFilter(k_max)
    return {
        k_max=k_max,
        k=0,
        zFiltered = 0,
        speedFiltered = 0,
        zPredicted = 0,
        speedPredicted = 0,
        ---Steps A-B filter and returns result
        ---@param me table
        ---@param z number
        ---@param dt any
        ---@return number
        step=function (me, z, dt)
            dt = dt or 16.6
            if me.k == 0 then
                me.zFiltered = z
                me.k = me.k + 1
            elseif me.k == 1 then
                me.speedFiltered = (z-me.zFiltered)/dt
                me.zFiltered = z
                me.zPredicted = me.zFiltered + dt*me.speedFiltered
                me.speedPredicted = me.speedFiltered
                me.k = me.k + 1
            else
                alpha = (2*(2*me.k - 1))/(me.k*(me.k+1))
                beta = 6/(me.k*(me.k+1))
                me.zFiltered = me.zPredicted + alpha*(z - me.zPredicted)
                me.speedFiltered = me.speedPredicted + (beta/dt)*(z - me.zPredicted)
                me.zPredicted = me.zFiltered + me.speedFiltered*dt
                me.k = me.k < k_max and me.k + 1 or k_max
            end
            return me.zFiltered
        end
    }
end
---@endsection

---@section ABVectorFilter
function ABVectorFilter(k_max)
    return {
        k_max=k_max,
        k=0,
        posFiltered = vector(0,0,0),
        speedFiltered = vector(0,0,0),
        posPredicted = vector(0,0,0),
        speedPredicted = vector(0,0,0),
        ---Steps A-B filter and returns result
        ---@param me table
        ---@param pos table
        ---@param dt any
        ---@return table
        step=function (me, pos, dt)

            dt = dt or 16.6
            if me.k == 0 then
                me.posFiltered = pos
                me.k = me.k + 1
            elseif me.k == 1 then
                me.speedFiltered = pos:applyIndex(function (a, index) return (pos[index] - me.posFiltered[index]) / dt end)
                me.posFiltered = pos
                me.posPredicted = pos:applyIndex(function (a, index) return me.posFiltered[index] + dt*me.speedFiltered[index] end)
                me.speedPredicted = me.speedFiltered
                me.k = me.k + 1
            else
                alpha = (2*(2*me.k - 1))/(me.k*(me.k+1))
                beta = 6/(me.k*(me.k+1))
                me.posFiltered = pos:applyIndex(function (a, index) return me.posPredicted[index] + alpha*(pos[index] - me.posPredicted[index]) end)
                me.speedFiltered = pos:applyIndex(function (a, index) return me.speedPredicted[index] + (beta/dt)*(pos[index] - me.posPredicted[index]) end)
                me.posPredicted = pos:applyIndex(function (a, index) return me.posFiltered[index] + me.speedFiltered[index]*dt end)
                me.k = me.k < k_max and me.k + 1 or k_max
            end
            return me.posFiltered
        end
    }
end
---@endsection