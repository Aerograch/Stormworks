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
        ---@param a table
        ---@param z number
        ---@param dt any
        ---@return number
        step=function (a, z, dt)
            dt = dt or 16.6
            if a.k == 0 then
                a.zFiltered = z
                a.k = a.k + 1
            elseif a.k == 1 then
                a.speedFiltered = (z-a.zFiltered)/dt
                a.zFiltered = z
                a.zPredicted = a.zFiltered + dt*a.speedFiltered
                a.speedPredicted = a.speedFiltered
                a.k = a.k + 1
            else
                alpha = (2*(2*a.k - 1))/(a.k*(a.k+1))
                beta = 6/(a.k*(a.k+1))
                a.zFiltered = a.zPredicted + alpha*(z - a.zPredicted)
                a.speedFiltered = a.speedPredicted + (beta/dt)*(z - a.zPredicted)
                a.zPredicted = a.zFiltered + a.speedFiltered*dt
                a.k = a.k < k_max and a.k + 1 or k_max
            end
            return a.zFiltered
        end
    }
end