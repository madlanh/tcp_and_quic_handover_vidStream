-- File: logger.lua (FINAL VERSION - VALIDATED)
local total_buffer_time = 0
local buffer_start_time = 0
local is_buffering = false
-- utils tidak wajib, tapi boleh dibiarkan
local utils = require 'mp.utils' 

function on_buffer_change(name, value)
    if value == true then
        -- KASUS: Buffering Mulai (Jaringan Putus/Handover)
        is_buffering = true
        -- REVISI: Gunakan mp.get_time() agar akurat menghitung waktu tunggu (Wall time)
        -- os.clock() hanya menghitung waktu CPU yang aktif
        buffer_start_time = mp.get_time()
        print("[LOGGER] Buffering started...")
        
    elseif value == false and is_buffering then
        -- KASUS: Buffering Selesai (Jaringan Nyambung Lagi)
        is_buffering = false
        local now = mp.get_time() -- REVISI: mp.get_time()
        
        if buffer_start_time and now then
            local duration = now - buffer_start_time
            
            -- Filter durasi sangat kecil (glitch) agar data bersih
            if duration > 0.1 then
                total_buffer_time = total_buffer_time + duration
                print(string.format("[LOGGER] Buffering ended. Duration: %.4fs", duration))
            end
        end
    end
end

-- Memantau properti buffering (indikator loading berputar)
mp.observe_property("paused-for-cache", "bool", on_buffer_change)

-- Menulis ke file saat MPV ditutup
mp.register_event("shutdown", function()
    -- Ambil nama file dari ENV, atau default jika lupa set
    local output_filename = os.getenv("LOG_NAME") or "default_buffering.log"
    local file = io.open(output_filename, "w")
    
    if file then
        -- Tulis hanya angka total detik (misal: 10.2156)
        file:write(string.format("%.4f\n", total_buffer_time))
        file:close()
        print("[LOGGER] Sukses! Total buffering: " .. total_buffer_time .. "s disimpan ke: " .. output_filename)
    else
        print("[LOGGER] Gagal menyimpan file!")
    end
end)
