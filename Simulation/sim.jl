#this file will take all the varibles inputed into app.jl and push them where needed
#this will also start and keep track of loops done in the simulation
include(joinpath(@__DIR__, "Molcules/molecule.jl"))
include(joinpath(@__DIR__, "Molcules/Data.jl"))
include(joinpath(@__DIR__, "Microbes/Data.jl"))
include(joinpath(@__DIR__, "results.jl"))
using Random


function Simulation(settings, microbes, startmoles)
    deltaT = parse(Int, settings[1])
    capT = parse(Int, settings[2])
    size = parse(Int, settings[3])
    evar = parse(Int, settings[4])
    microb = []
    moles = Dict()

    micro_grid = arr = Array{microbe,2}(undef,size,size)
    for i in range(1,size)
        for j in range(1,size)
            micro_grid[i,j]= micro_load()
        end
    end

    function born(in, x, y)
        for i in range(1:10000)
            j = 0
            while j <= i
                if micro_grid[x+i, y+j] == 0
                    micro_grid[x+i, y+j] = micro_load(in)
                    return
                elseif micro_grid[x+i, y-j] == 0
                    micro_grid[x+i, y-j] = micro_load(in)
                    return
                elseif micro_grin[x-j, y+i] == 0
                    micro_grid[x-j, y+i] = micro_load(in)
                    return
                elseif micro_grin[x-j, y-i] == 0
                    micro_grid[x+j, y+i] = micro_load(in)
                    return
                end
            end
        end
    end

    #loading microbes from memory
    for value in microbes
        if value != "None"
            push!(microb, micro_load(value))
        end
    end
    #loading molcules from hdd into main memory
    #using microbes loaded to get food and excrement  
    for value in microb
        if value == "None" || value == -1
            continue
        end
        for i in value.food
            if i == "None" || i==0
                continue
            end
            if !haskey(moles, value)
                push!(moles, value => mole_load(i))
            end
        end
        for i in value.excrement
            if i == "None" || i ==0
                continue
            end
            if !haskey(moles, value)
                push!(moles, mole_load(i))
            end
        end
    end

    #this is to fill in a mole grid for input molecules
    for v in startmoles

        if !haskey(moles, v)
            push!(moles, v => mole_load(v))
        end
        moles[v].arr = fill(20000)
        moles[v].factor = 64
    end

    #random micro_grid assignments
    for mics in microbes
        for i in range(1,rand(50:500))
            micro_grid[rand(1:10000), rand(1:10000)] = micro_load(mics)
        end
    end

    #actual simulation calulations
    for time in range(1, deltaT, 1000000)
        capture = 0
        for (l, m) in enumerate(micro_grid)

            env = 0
            if m.name != 0
                env = update_cell(m, deltaT, moles, l // size, l % size, evar)
            end
            if env == "Die"
                m = micro_load()
            elseif env == "Birth"
                born(m.name, l // size, l % size)
            end
        end
        for m in values(moles)
            updateMolecule(m, deltaT)
        end
        balance(moles)
        #this is to save imgs of the micro_grid
        capture=0
        if capture == floor(time / capT)
            continue
        else
            capture = floor(time / capT)
            resultSave(capure, micro_grid, moles)

        end
    end
    return capture
end
