#this is to save and load microbesfrom HDD
#save function is called from app.jl and load called from sim.jl
include(joinpath(@__DIR__, "cell.jl"))


function micro_save(params)
    #Blink.msg("save_micro", name + "," + size + "," + ph + "," + vph + "," + f1 + "," + f2 +  "," + f3 +  "," + e1 + "," + e2 + "," + e3);
    
    name = params[1]
    size = parse(Int16, params[2])
    ph = parse(Float16, params[3])
    vph = parse(Float16, params[4])
    food = [params[5],params[6], params[7]]
    excrement = [params[8],params[9], params[10]]

    exists= false

   open(joinpath(@__DIR__, "Memory/index.txt")) do f
        while !eof(f)
            if "$name" == readline(f)
                exists=true
            end
        end
    end
    if !exists
        touch(joinpath(@__DIR__, "Memory/$name.txt"))
        f = open(joinpath(@__DIR__, "Memory/index.txt"), "a")
        write(f, "$name\n")
        close(f)
    end
        open(joinpath(@__DIR__, "Memory/$name.txt"), "w") do f
            write(f, "$name \n $size \n $ph \n $vph \n $food \n $excrement")
        end
end

function micro_load(name)

    open(joinpath(@__DIR__, "Memory/index.txt")) do f
        while !eof(f)
            if "$name" == readline(f)
                list = open(readdlm, joinpath(@__DIR__, "Memory/$name.txt"))
                
                food = split(list[5],"}")
                food = split(food[2], ", ")
                excrement = split(list[6],"}")
                excrement = split(excrement[2], ", ")

                out = cell(name=list[1],size=parse(Int, list[2]), ph=parse(Float16,list[3]), vph= parse(Float16, list[4]), food=food, excrement=excrement)
                return out
            end
        end
    end
        return -1
end