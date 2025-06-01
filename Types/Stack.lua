function Stack()
    return
    {
    values = {},
    add = function (me, value)
        me.values[#me.values+1] = value
    end,
    remove = function (me)
        temp = {}
        for i = 2, #me.values do
            temp[i-1] = me.values[i]
        end
        me.values = temp
    end,
    count = function (me)
        return #me.values
    end,
    }
end