using Blink
include(joinpath(@__DIR__, "Simulation/Molcules/Data.jl"))
include(joinpath(@__DIR__, "Simulation/Microbes/Data.jl"))
include(joinpath(@__DIR__, "Simulation/Sim.jl"))


#ui varibles needed to pass to js
pcount = 0 #keeps track of how many output DataFrames
cp = -1 #keeps track of the current output being viewed

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
        list = micro_list()

        for val in list
            f = f * "<script> populate_micro('$val'); </script>"
        end
        list = mole_list()

        for val in list
            f = f * "<script> populate_mole('$val'); </script>"
        end

    elseif args == "Microbe"
        f = open("ui/newMicrobe.html") do file
            read(file, String)
        end
        list = mole_list()

        for val in list
            f = f * "<script> populate_mole('$val'); </script>"
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
    params = split(args, ",")
    mole_save(params)
    #return home page
    f = open("ui/app.html") do file
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
    f = open("ui/app.html") do file
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
    startmoles = ["Glucose","Nitrate"]
    pcount = Simulation(settings, micros, startmoles)
    
    f = open("ui/output/out-1.html") do file
        read(file, String)
    end
    body!(w, f)
end