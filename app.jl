using Blink
include(joinpath(@__DIR__, "Simulation/Molcules/Data.jl"))
include(joinpath(@__DIR__, "Simulation/Microbes/Data.jl"))
include(joinpath(@__DIR__, "Simulation/Sim.jl"))

    

#ui varibles needed to pass to js
pcount = 0 #keeps track of how many output DataFrames
cp = 0 #keeps track of the current output being viewed

w = Window()
f = open(joinpath(@__DIR__, "ui/start.html")) do file
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
    startmoles = split(params[3], ",")
    pcount = Simulation(settings, micros, startmoles)
    cp = pcount
    println(cp)

    if pcount == 0
        f = open(joinpath(@__DIR__, "ui/out-1.html")) do file
            read(file, String)
        end
    else


        f = open(joinpath(@__DIR__, "ui/out-1.html")) do file
            read(file, String)
        end

        d = open(joinpath(@__DIR__, "ui/output/$(pcount).txt")) do file
            inlines = readlines(file)
            molec = true
            for m in inlines
                if m == "::"
                    molec = false
                    continue
                end
                if molec
                    pop = split(m, "=")
                    f *= "<script> addMole('$(pop[1])', $(pop[2])) </script>"
                else
                    f *= "<script> addMicro($m) </script>"
                end
            end

        end

    end
    f*= "<script> page = '$cp/$pcount';"
    body!(w, f)
end

handle(w, "page change") do args
    args = split(args," ")
    page = split(args[2],"/")
    cp = parse(Int,page[1])
    pcount = parse(Int,page[2])
    args = args[1]
    if args == "back"
        if cp - 1 < 0
            f = open(joinpath(@__DIR__, "ui/out-1.html")) do file
                read(file, String)
            end

            d = open(joinpath(@__DIR__, "ui/output/$(cp).txt")) do file
                inlines = readlines(file)
                molec = true
                for m in inlines
                    if m == "::"
                        molec = false
                        continue
                    end
                    if molec
                        pop = split(m, "=")
                        f *= "<script> addMole('$(pop[1])', $(pop[2])) </script>"
                    else
                        f *= "<script> addMicro($m) </script>"
                    end
                end
    
            end
            f *= "<script> alert('No more pages');</script>"
        else
            cp -= 1
            f = open(joinpath(@__DIR__, "ui/out-1.html")) do file
                read(file, String)
            end

            d = open(joinpath(@__DIR__, "ui/output/$(cp).txt")) do file
                inlines = readlines(file)
                molec = true
                for m in inlines
                    if m == "::"
                        molec = false
                        continue
                    end
                    if molec
                        pop = split(m, "=")
                        f *= "<script> addMole('$(pop[1])', $(pop[2])) </script>"
                    else
                        f *= "<script> addMicro($m) </script>"
                    end
                end
    
            end
        end
    elseif args == "forward"
        if cp + 1 > pcount
            f = open(joinpath(@__DIR__, "ui/out-1.html")) do file
                read(file, String)
            end

            d = open(joinpath(@__DIR__, "ui/output/$(cp).txt")) do file
                inlines = readlines(file)
                molec = true
                for m in inlines
                    if m == "::"
                        molec = false
                        continue
                    end
                    if molec
                        pop = split(m, "=")
                        f *= "<script> addMole('$(pop[1])', $(pop[2])) </script>"
                    else
                        f *= "<script> addMicro($m) </script>"
                    end
                end
    
            end
            f *= "<script> alert('No more pages')</script>"
        else
            cp += 1
            f = open(joinpath(@__DIR__, "ui/out-1.html")) do file
                read(file, String)
            end

            d = open(joinpath(@__DIR__, "ui/output/$(cp).txt")) do file
                inlines = readlines(file)
                molec = true
                for m in inlines
                    if m == "::"
                        molec = false
                        continue
                    end
                    if molec
                        pop = split(m, "=")
                        f *= "<script> addMole('$(pop[1])', $(pop[2])) </script>"
                    else
                        f *= "<script> addMicro($m) </script>"
                    end
                end
    
            end
        end
    end
    f*= "<script> page = '$cp/$pcount';"
    body!(w, f)
end