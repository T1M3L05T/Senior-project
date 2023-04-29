#this file will take all the varibles inputed into app.jl and push them where needed
#this will also start and keep track of loops done in the simulation
include(joinpath(@__DIR__, "Molcules/molecule.jl"))
include(joinpath(@__DIR__, "Molcules/Data.jl"))
include(joinpath(@__DIR__, "Microbes/Data.jl"))
include(joinpath(@__DIR__, "results.jl"))
using Random
using .Threads


function Simulation(settings, microbes, startmoles)
    deltaT = parse(Int, settings[1])
    capT = parse(Int, settings[2])
    size = parse(Int, settings[3])
    evar = parse(Int, settings[4])
    initmicrob = []
    moles = Dict()
    micro_grid = []
    # micro_grid = arr = Array{microbe,2}(undef,size,size)
    # @threads for i in range(1,size)
    #     @threads for j in range(1,size)
    #         micro_grid[i,j]= micro_load("None")
    #     end
    # end

    function born(in, x, y)

        for (i,m) in enumerate(initmicrob)
            if in == m.name
                push!(micro_grid, deepcopy(initmicrob[i]))
            end
        end
        last(micro_grid).x = rand(1:size)
        last(micro_grid).y = rand(1:size)

        # for i in range(1:1000)
        #     j = 0
        #     while j <= i
        #         if micro_grid[x+i, y+j] == 0
        #             micro_grid[x+i, y+j] = micro_load(in)
        #             return
        #         elseif micro_grid[x+i, y-j] == 0
        #             micro_grid[x+i, y-j] = micro_load(in)
        #             return
        #         elseif micro_grin[x-j, y+i] == 0
        #             micro_grid[x-j, y+i] = micro_load(in)
        #             return
        #         elseif micro_grin[x-j, y-i] == 0
        #             micro_grid[x+j, y+i] = micro_load(in)
        #             return
        #         end
        #         j+=1
        #     end
        # end
    end

    #loading microbes from memory
    for value in microbes
        if value != "None"
            push!(initmicrob, micro_load(value))
        end
    end
    if isempty(initmicrob)
        return
    end
    #loading molcules from hdd into main memory
    #using microbes loaded to get food and excrement  
    for value in initmicrob

        if value.name == "None" || value.name == 0
            continue
        end
        for i in value.food
            if i == "None" || i == 0
                continue
            end
            if !haskey(moles, i)
                push!(moles, i => mole_load(i,size))
            end
        end
        for i in value.excrement
            if i == "None" || i == 0
                continue
            end
            if !haskey(moles, i)
                push!(moles, i => mole_load(i,size))
            end
        end
    end

    #this is to fill in a mole grid for input molecules
    for v in startmoles
        if v == "None"
            continue
        end
        if !haskey(moles, v)
            push!(moles, v => mole_load(v,size))
        end
        moles[v].arr = fill(1500000,(size,size))
        moles[v].factor = 100
        moles[v].total = 1500000 * 100^2
    end

    #random micro_grid assignments
    for m in initmicrob
        count=0
        for i in range(1, rand(10:(size/10)))
            count +=1
            push!(micro_grid, deepcopy(m))
            micro_grid[count].x = rand(1:size)
            micro_grid[count].y = rand(1:size)
        end
    end
    capture = 0
    #actual simulation calulations
    for time in 0:deltaT:10000
        println(time)
        capture = 0
        count=0
        for m in micro_grid
            count+=1
            l = m.x
            q = m.y
            env = 0
            if m.name != "0"
                env = update_cell(m, deltaT, moles, evar)
            end
            if env == "Die"
                deleteat!(micro_grid, count)
                count-=1
            elseif env == "Birth"
                born(m.name, l, q)
            end
        end
        if isempty(micro_grid)
            return
        end
        println("cell complete")
        @threads for m in collect(values(moles))
            updateMolecule(m, deltaT, size)
        end
        balance(moles,size)
        println("Chemistry")
        #this is to save imgs of the micro_grid
        if capture == floor(time / capT)
            continue
        else
            capture = floor(time / capT)
            resultSave(capture, micro_grid, moles)

        end
    end
    return capture
end
