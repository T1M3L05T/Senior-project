#grid setup for a molcules and functions needed to update grid with Diffusion
using .Threads
mutable struct moleGrid
    name
    dCo::Float16
    total::Int128
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
    #change = floor(grid.dCo * deltaT)
    if grid.total <= 0
        return
    end
    tot = 0
    for num in grid.arr
        tot+=num
    end
    grid.total = tot
    tot = tot/size^2
    for num in grid.arr
        num = tot
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
        pka = 9.26

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
            
            equal = (v * 10^(-pka))
            v -= equal
            moles["Ammonium"].total -= floor(equal)
            moles["Ammonium Ion"].arr[i] += floor(equal)
            moles["Hydrogen"].arr[i] += floor(equal)
            moles["Ammonium Ion"].total += floor(equal)
            moles["Hydrogen"].total += floor(equal)
        end
    end



    return
end


function ph_check_(moles)

    Hcount::BigInt = 0

    Hcount = moles["Hydrogen"].total
    Hcount *= moles["Hydrogen"].factor

    if Hcount <= 0

        return 7
    else
        ml = Hcount * 3 / 10^(15)
        return (-log(ml)) +7
    end

end


function ph_check(moles, x, y)

    Hcount::BigInt = 0

    Hcount = moles["Hydrogen"].arr[x, y]
    Hcount *= moles["Hydrogen"].factor

    if Hcount <= 0

        return 7
    else
        ml = Hcount * 3 / 10^(15)
        return (-log(ml)) + 7
    end
end



