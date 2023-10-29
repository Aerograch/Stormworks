Button = {}
function Button:new(x1, y1, x2, y2)
    
    local private = {}
        private.callbackTable = {}
        
        function private:getCallbackId(callback)
            for i = 1, #private.callbackTable do
                if private.callbackTable[i] == callback then
                    return i
                end
            end
            return nil
        end

    local public = {}
        public.xMin = x1
        public.yMin = y1
        public.xMax = x2
        public.yMax = y2

        function public:check(x, y)
            if x > public.xMin and x < public.xMax and y > public.yMin and y < public.yMax then
                for i = 1, #private.callbackTable do
                    private.callbackTable[i]()
                end
            end
        end

        function public:addCallback(callback)
            if private:getCallbackId(callback) == nil then
                private.callbackTable[#private.callbackTable+1] = callback
            end
        end

        function public:removeCallback(callback)
            local id = private:getCallbackId(callback)
            for i = id+1, #private.callbackTable do
                private.callbackTable[i-1] = private.callbackTable[i]
            end
        end

        setmetatable(public, self)
        self.__index = self; return public
end