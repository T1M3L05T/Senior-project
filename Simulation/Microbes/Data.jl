#this is to save and load microbesfrom HDD
#save function is called from app.jl and load called from sim.jl
include(joinpath(@__DIR__, "cell.jl"))


function micro_save(params)
    #Blink.msg("save_micro", name + "," + size + "," + ph + "," + vph + "," + f1 + "," + f2 +  "," + f3 +  "," + e1 + "," + e2 + "," + e3);

    name = params[1]
    size = parse(Int16, params[2])
    ph = parse(Float16, params[3])
    vph = parse(Float16, params[4])
    food = [params[5], params[6], params[7]]
    excrement = [params[8], params[9], params[10]]

    exists = false

    open(joinpath(@__DIR__, "Memory/index.txt")) do f
        while !eof(f)
            if "$name" == readline(f)
                exists = true
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
        write(f, "$name\n$size\n$ph\n $vph\n")
        for val in food
            write(f, "$val\n")
        end
        for val in excrement
            write(f, "$val\n")
        end
    end
end




function micro_list()

    list = []
    open(joinpath(@__DIR__, "Memory/index.txt")) do f
        while !eof(f)
            push!(list, readline(f))
        end
    end
    sort!(list)
    return list
end

function micro_load(name)
    if name =="None"
        return microbe(0,0,0,0,0,0,0,0,0)
    end
    list = micro_list()
    params =[]
    if name in list
        open(joinpath(@__DIR__, "Memory/$name.txt")) do f
            while !eof(f)
                push!(params,readline(f))
            end
        end
    
        food = [params[5],params[6],params[7]]
        filter!(e->e!="None",food)
        excret = [params[8],params[9],params[10]]
        filter!(e->e!="None",excret)
        return microbe(params[1],parse(Int8,params[2]),parse(Float16,params[3]),parse(Float16,params[4]),food,excret,100,0,0,1,1)
    else
        return microbe(0,0,0,0,0,0,0,0,0)
    end

    
end
