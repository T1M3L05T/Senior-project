using Blink
include(joinpath(@__DIR__, "Simulation/Molcules/Data.jl"))
include(joinpath(@__DIR__, "Simulation/Microbes/Data.jl"))
include(joinpath(@__DIR__, "Simulation/Sim.jl"))


#ui varibles needed to pass to js
pcount = 0 #keeps track of how many output DataFrames
cp = -1 #keeps track of the current output being viewed

w = Window()
f = open(joinpath(@__DIR__,"ui/start.html")) do file
    read(file, String)
end
load!(w, joinpath(@__DIR__, "ui/app.css"))
body!(w, f)


# this is to handle page switching on button presses
handle(w, "link") do args
    if args == "Sim"
        f = open(joinpath(@__DIR__, "ui/app.html")) do file
            read(file, String)
        end
        list = micro_list()

        for val in list
            f = f * "<script> populate_micro('$val'); </script>"
        end
        list = mole_list()

        for val in list
            f = f * "<script> populate_mole('$val'); </script>"
        end
        body!(w, f)

    elseif args == "Microbe"
        f = open(joinpath(@__DIR__, "ui/newMicrobe.html")) do file
            read(file, String)
        end
        list = mole_list()

        for val in list
            f = f * "<script> populate_mole('$val'); </script>"
        end
        body!(w, f)

    elseif args == "Molecule"
        f = open(joinpath(@__DIR__, "ui/newMolecule.html")) do file
            read(file, String)
        end
        body!(w, f)

    end
    
end

#save functions
handle(w, "save_mole") do args
    params = split(args, ",")
    mole_save(params)
    #return home page
    f = open(joinpath(@__DIR__, "ui/app.html")) do file
        read(file, String)
    end
    list = micro_list()

    for val in list
        f = f * "<script> populate_micro('$val'); </script>"
    end
    list = mole_list()

    for val in list
        f = f * "<script> populate_mole('$val'); </script>"
    end
    f = f * "<script> alert('Save Successful'); </script>"
    body!(w, f)
end

handle(w, "save_micro") do args
    params = split(args, ",")
    micro_save(params)
    #return home page
    f = open(joinpath(@__DIR__, "ui/app.html")) do file
        read(file, String)
    end
    list = micro_list()

    for val in list
        f = f * "<script> populate_micro('$val'); </script>"
    end
    list = mole_list()

    for val in list
        f = f * "<script> populate_mole('$val'); </script>"
    end
    f = f * "<script> alert('Save Successful'); </script>"
    body!(w, f)
end

handle(w, "simulate") do args
    params = split(args, "::")
    settings = split(params[1], ",")
    micros = split(params[2], ",")
    startmoles = split(params[3],",")
    pcount::float = Simulation(settings, micros, startmoles)
    
    f = open(joinpath(@__DIR__, "ui/out-1.html")) do file
        read(file, String)
    end

    d = open(joinpath(@__DIR__, "ui/output/$pcount.txt")) do file
        read(file, String)
    end
    array = split(d,"::")
    molecules = split(array[1],":")
    organisms = split(array[2],":")

    for m in molecules
        f = f * "$molecules"

    body!(w, f)
    end
end