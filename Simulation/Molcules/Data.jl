#this file is to interact with csv file to save and load molecules
#mostly called by the App.jl to save, sim.jl to load
using CSV
using DataFrames

include(joinpath(@__DIR__, "molecule.jl"))

#accepts an array input and splits it into varibles needed for csv table
# utiling dataframe for organization
function mole_save(params)
    name = params[1]
    mass = parse(Int16, params[2])
    diff = parse(Float16, params[3])
    structure = params[4]

    df = DataFrame(CSV.File(joinpath(@__DIR__, "molecules.csv")))


    mole_exists = false
    for row in eachrow(df)
        if name == row["Name"]
            mole_exists = true
            row["Mass"] = mass
            row["Diffusion"] = diff
            row["Structure"] = "$structure"
            break
        end
    end
    if !mole_exists
        push!(df, [name, mass, diff, structure])
    end
    CSV.write(joinpath(@__DIR__, "molecules.csv"), df)
end

function mole_load(name,size)
    if name=="None"
        return
    end
    df = DataFrame(CSV.File(joinpath(@__DIR__, "molecules.csv")))
    for row in eachrow(df)
        if name == row["Name"]
            return  moleGrid(row["Name"], row["Diffusion"] * 1000 / 3, 0, zeros(Int16, size, size), row["Structure"], 1)
        end
    end
    return

end

function mole_list()
    df = DataFrame(CSV.File(joinpath(@__DIR__, "molecules.csv")))
    list = []
    for row in eachrow(df)
        push!(list, row["Name"])
    end
    sort!(list)
    return list
end