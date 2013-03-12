-- http://perforce.freebsd.org/fileLogView.cgi?FSPC=//depot/projects/soc2005/bsdinstaller/src/contrib/bsdinstaller/backend/lua/lib/bitwise.lua
-- lib/bitwise.lua
-- $Id: bitwise.lua,v 1.3 2005/04/11 02:21:37 cpressey Exp $
-- Package for (pure-Lua portable but extremely slow) bitwise arithmetic.

-- BEGIN lib/bitwise.lua --

--[[---------]]--
--[[ Bitwise ]]--
--[[---------]]--

Bitwise = {}

Bitwise.odd = function(x)
        return x ~= math.floor(x / 2) * 2
end

Bitwise.bw_and = function(a, b)
        local c, pow = 0, 1
        while a > 0 or b > 0 do
                if Bitwise.odd(a) and Bitwise.odd(b) then
                        c = c + pow
                end
                a = math.floor(a / 2)
                b = math.floor(b / 2)
                pow = pow * 2
        end
        return c
end

Bitwise.bw_or = function(a, b)
        local c, pow = 0, 1
        while a > 0 or b > 0 do
                if Bitwise.odd(a) or Bitwise.odd(b) then
                        c = c + pow
                end
                a = math.floor(a / 2)
                b = math.floor(b / 2)
                pow = pow * 2
        end
        return c
end
