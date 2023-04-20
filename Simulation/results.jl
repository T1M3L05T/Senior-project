#this file is to take output saves and loads it from app.jl

function resultSave(capture,micro_grid,moles)
    mole_count=0


    #creates/overwrites previous files
    touch("../output/out"*string(capture)*".html")

    #open file and prepare to write
    open("../output/out"*string(capture)*".txt", "w") do f
        
        for m in moles
            write(f, string(m.name*"="*m.total*m.factor))
        end
        write(f, micro_grid)
    end
end

