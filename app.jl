using Blink
include(joinpath(@__DIR__, "Simulation/Molcules/Data.jl"))
include(joinpath(@__DIR__, "Simulation/Microbes/Data.jl"))
include(joinpath(@__DIR__, "Simulation/Sim.jl"))


w = Window()
f = open("ui/start.html") do file
    read(file, String)
end
load!(w, "ui/app.css")
body!(w, f)


# this is to handle page switching on button presses
handle(w, "link") do args
    if args == "Sim"
        f = open("ui/app.html") do file
            read(file, String)
        end
    elseif args == "Microbe"
        f = open("ui/newMicrobe.html") do file
            read(file, String)
        end
    elseif args == "Molecule"
        f = open("ui/newMolecule.html") do file
            read(file, String)
        end
    end
    body!(w, f)
end

#save functions
handle(w, "save_mole") do args
    params = split(args,",")
    mole_save(params)
    #return home page
    f = open("ui/app.html") do file
        read(file, String)
    end
    body!(w, f)
end

handle(w, "save_mole") do args
    params = split(args,",")
    mole_save(params)
    #return home page
    f = open("ui/app.html") do file
        read(file, String)
    end
    body!(w, f)
end

handle(w, "save_micro") do args
    params = split(args,",")
    micro_save(params)
    #return home page
    f = open("ui/app.html") do file
        read(file, String)
    end
    body!(w, f)
end
handle(w,"run") do args
    params = split(args,"::")
    setting = split(params[1],",")
    micros = split(params[2],",")
    Simulation(settings,micros)
    f = open("out/app.html") do file
        read(file, String)
    end
    body!(w, f)