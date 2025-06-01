function List(values)
    return
    {
        list = values or {},
        remove = function (me, index)
            report = {}
            for i = 1, index - 1 do
                report[i] = me.list[i]
            end
            for i = index + 1, #me.list do
                report[i-1] = me.list[i]
            end
            me.list = report
        end,
        add = function (me, item, index)
            if index then
                report = {}
                for i = 1, index - 1 do
                    report[i] = me.list[i]
                end
                report[index] = item
                for i = index, #me.list do
                    report[i+1] = me.list[i]
                end
                me.list = report
            else
                me.list[#me.list+1] = item
            end
        end
    }
end