local total_buffer_time = 0
local buffer_start_time = 0
local is_buffering = false
local utils = require 'mp.utils' 

function on_buffer_change(name, value)
    if value == true then
        is_buffering = true
        buffer_start_time = mp.get_time()
        print("[LOGGER] Buffering started...")
        
    elseif value == false and is_buffering then
        is_buffering = false
        local now = mp.get_time()
        
        if buffer_start_time and now then
            local duration = now - buffer_start_time
            
            if duration > 0.1 then
                total_buffer_time = total_buffer_time + duration
                print(string.format("[LOGGER] Buffering ended. Duration: %.4fs", duration))
            end
        end
    end
end

mp.observe_property("paused-for-cache", "bool", on_buffer_change)

mp.register_event("shutdown", function()
    local output_filename = os.getenv("LOG_NAME") or "default_buffering.log"
    local file = io.open(output_filename, "w")
    
    if file then
        file:write(string.format("%.4f\n", total_buffer_time))
        file:close()
        print("[LOGGER] Sukses! Total buffering: " .. total_buffer_time .. "s disimpan ke: " .. output_filename)
    else
        print("[LOGGER] Gagal menyimpan file!")
    end
end)
