#grid setup for a molcules and functions needed to update grid with Diffusion
using .Threads
mutable struct moleGrid
    name
    dCo::Float16
    total::Int
    arr::Matrix{UInt64}
    structure
    factor::Int128

end

function changeFactor(grid::moleGrid)
    for num in eachindex(grid.arr)
        num = num / 10
    end
    grid.factor *= 10
end

function updateMolecule(grid::moleGrid, deltaT, size)
    change::Int32 = floor(grid.dCo * deltaT)
    if grid.total <= 0
        return
    end

    equal = grid.total / (size^2)
    for num in grid.arr
        num = equal

        # while num > 5000000000000000
        #     changeFactor(grid)
        # end
        # distrubution = floor(num / (1+(change))^2)
        # if distrubution == 0
        #     continue
        # end
        # for i in 1:floor(sqrt(change))
        #     if floor(idx // size) + i <= size
        #         for j in 1:floor(sqrt(change))
        #             if floor(idx % size) + j <= size
        #                 grid.arr[floor(idx / size + i), idx%size+j] += distrubution
        #             else
        #                 grid.arr[floor(idx / size + i), idx%size-j] += distribution
        #             end
        #             if floor(num % size) - j > 0
        #                 grid.arr[floor(idx / size + i), idx%size-j] += distrubution
        #             else
        #                 grid.arr[floor(idx / size + i), idx%size+j] += distrubution
        #             end
        #         end
        #     else
        #         for j in 1:floor(sqrt(change))
        #             if floor(num % size) + j <= size
        #                 grid.arr[floor(idx / size - i), idx%size+j] += distrubution
        #             else
        #                 grid.arr[floor(idx / size - i), idx%size-j] += distrubution
        #             end
        #             if floor(num % size) - j > 0
        #                 grid.arr[floor(idx / size - i), idx%size-j] += distrubution
        #             else
        #                 grid.arr[floor(idx / size - i), idx%size+j] += distrubution
        #             end
        #         end
        #     end
        #     if floor(num / size) - i > 0
        #         for j in 1:floor(sqrt(change))
        #             if floor(num % size) + j <= size
        #                 grid.arr[floor(idx / size - i), idx%size+j] += distrubution
        #             else
        #                 grid.arr[floor(idx / size - i), idx%size-j] += distrubution
        #             end
        #             if floor(num % size) - j > 0
        #                 grid.arr[floor(idx / size - i), idx%size-j] += distrubution
        #             else
        #                 grid.arr[floor(idx / size - i), idx%size+j] += distrubution
        #             end
        #         end
        #     else
        #         for j in 1:floor(sqrt(change))
        #             if floor(idx % size) + j <= size
        #                 grid.arr[floor(idx / size + i), idx%size+j] += distrubution
        #             else
        #                 grid.arr[floor(idx / size + i), idx%size-j] += distribution
        #             end
        #             if floor(num % size) - j > 0
        #                 grid.arr[floor(idx / size + i), idx%size-j] += distrubution
        #             else
        #                 grid.arr[floor(idx / size + i), idx%size+j] += distrubution
        #             end
        #         end
        #     end
        # end
    end
end

#this function is for molecules that have an equlibrium equation
function balance(moles, size)


    if haskey(moles, "Ammonium Ion") || haskey(moles, "Ammonium")

        #verify and create if needed all chemicals in this equation
        if !haskey(moles, "Hydrogen")
            push!(moles, "Hydrogen" => mole_load("Hydrogen", size))
        end
        if !haskey(moles, "Ammonium")
            push!(moles, "Ammonium" => mole_load("Ammonium", size))
        end
        if !haskey(moles, "Ammonium Ion")
            push!(moles, "Ammonium Ion" => mole_load("Ammonium Ion", size))
        end

        for (i, v) in enumerate(moles["Ammonium"].arr)
            equal = (v * moles["Ammonium"].factor + moles["Ammonium Ion"].arr[i] * moles["Ammonium Ion"].factor) / 2
            v = equal / moles["Ammonium"].factor
            moles["Ammonium Ion"].arr[i] = floor(equal / moles["Ammonium Ion"].factor)
            moles["Hydrogen"].arr[i] = floor(equal / moles["Hydrogen"].factor)
        end
    end
    tot::BigInt = floor(moles["Ammonium"].total)
    tot += floor(moles["Ammonium Ion"].total)
    tot = floor(tot / 2)
    moles["Ammonium"].total = tot
    moles["Ammonium Ion"].total = tot
    moles["Hydrogen"].total = tot
    return
end


function ph_check_(moles)

    for m in keys(moles)
        if m == "Hydrogen"
            Hcount += moles["Hydrogen"].total * moles["Hydrogen"].factor
        end
        hbase = 0
        obase = 0

        #checking for basic chemicals in solution for H atoms to react with
        for (x, stut) in enumerate(moles[m].structure)

            if stut == "H"
                if isdigit(moles[m].structure[x+1])
                    if isdigit(moles[m].structure[x+2])
                        hbase = parse(Int, moles[m].structure[x+1] * moles[m].structure[x+2])
                    else
                        hbase = parse(Int, moles[m].structure[x+1])
                    end
                else
                    hbase = 1
                end
            end
            if stut == "O"
                if isdigit(moles[m].structure[x+1])
                    if isdigit(moles[m].structure[x+2])
                        obase = parse(Int, moles[m].structure[x+1] * moles[m].structure[x+2])
                    else
                        obase = parse(Int, moles[m].structure[x+1])
                    end
                else
                    obase = 1
                end
            else
                continue
            end
            if hbase / obase < 2 && obase != 0
                OHcount = moles[m].total * moles[m].factor
            end
        end
    end
    #calulating ph after H atoms react out
    Hcount = Hcount - OHcount
    ml = Hcount * 3 / 10^(-15)
    return (-log(ml) + 7)

end


function ph_check(moles, x, y)

    Hcount::BigInt = 0
    OHcount::BigInt = 0


    for m in values(moles)
        if m.name == "Hydrogen"
            Hcount = floor(m.arr[x, y])
            Hcount *= m.factor
        end
        if m.name == "Ammonium"
            OHcount = floor(m.arr[x, y])
            OHcount *= m.factor

            #checking for basic chemicals in solution for H atoms to react with
            Hcount -= OHcount

            if Hcount <= 0

                return 7
            else
                return (-log(ml)) + 7
            end
        end
    end
end



