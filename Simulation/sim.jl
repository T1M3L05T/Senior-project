#this file will take all the varibles inputed into app.jl and push them where needed
#this will also start and keep track of loops done in the simulation
include(joinpath(@__DIR__, "Molcules/molecule.jl"))
include(joinpath(@__DIR__, "Molcules/Data.jl"))
include(joinpath(@__DIR__, "Microbes/Data.jl"))


function Simulation(settings, microbe)
    deltaT = parse(Int, settings[1])
    capT = parse(Int, settings[2])
    size =  parse(Int, settings[3])
    evar = parse(Int, settings[4])
    startmoles = settings[5]
    microbes
    microbesSize=1
    moles
    molesSize=1


# -1 return is to catch a DNE error
    #loading microbes from hdd into main memory
    for value in microbe
        if value == "NULL"
            continue
        end
        microbes[microbesSize] = micro_load(value)
        if microbes[microbesSize] == -1
            return -1
        end
        microbesSize+=1
    end
    #loading molcules from hdd into main memory
    #using microbes loaded to get food and excrement  
    for value in microbes
        for i in range(1,1,3)
            if value.food[i] == "NULL"
                continue
            end
            moles[molesSize] = mole_load(value.food[i])
            if mole[index*i] == -1
                return -1
            end
            molesSize+=1
        end
        for i in range(1,1,3)
            if value.excrement[i] == "NULL"
                continue
            end
            moles[molesSize] = mole_load(value.excrement[i])
            if mole[index*i] == -1
                return -1
            end
            molesSize+=1
        end
    end
    for v in startmoles
        moles[molesSize] = v
        

end
