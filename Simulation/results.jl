#this file is to take output saves and loads it from app.jl

fp = joinpath(@__DIR__, "../ui/output/")

function resultSave(capture, micro_grid, moles)
    mole_count = 0


    #creates/overwrites previous files
    touch("$fp$capture.txt")

    #open file and prepare to write
    open("$fp$capture.txt", "w") do f

        for m in values(moles)
            write(f, string(":$(m.name)=$(m.total*m.factor)" ))
        end
        write(f,"::")

        for m in micro_grid
            write(f, string("$(m.name), $(m.condition), $(m.life), $(m.mass), $(m.x), $(m.y):"))
        end

        #write(f, micro_grid)
    end
end

