#grid setup for a molcules and functions needed to update grid with Diffusion

mutable struct moleGrid
    name
    dCo::Float16
    total::Int
    arr
    structure
    factor::Int16

end

function changeFactor(grid::moleGrid)
    for num in eachindex(grid.arr)
        num= num/2
    end
    grid.factor=grid.factor*2
end

function updateMolecule(grid::moleGrid,deltaT)
    change = floor(grid.dCo*deltaT)
    for (idx,num) in enumerate(grid.arr)
        if num > 20000
            changeFactor(grid)
        end
        distrubution = floor(num/(1+2(change))^2)
        if distrubution == 0
            continue
        end
        for i in range(1,floor(sqrt(change)))
            if floor(idx//10000)+i <= 10000
                for j in range(1,floor(sqrt(change)))
                    if floor(idx%10000)+j <= 10000
                        grid.arr[floor(idx/10000+i),idx%10000+j]+=distrubution
                    else
                        grid.arr[floor(idx/10000+i),idx%10000-j]+=distribution
                    end
                    if floor(num%10000)-j > 0
                        grid.arr[floor(idx/10000+i),idx%10000-j]+=distrubution
                    else
                        grid.arr[floor(idx/10000+i),idx%10000+j]+=distrubution
                    end
                end
            else
                for j in range(1,floor(sqrt(change)))
                    if floor(num%10000)+j <= 10000
                        grid.arr[floor(idx/10000-i),idx%10000+j]+=distrubution
                    else
                        grid.arr[floor(idx/10000-i),idx%10000-j]+=distrubution
                    end
                    if floor(num%10000)-j > 0
                        grid.arr[floor(idx/10000-i),idx%10000-j]+=distrubution
                    else
                        grid.arr[floor(idx/10000-i),idx%10000+j]+=distrubution
                    end
                end
            end
            if floor(num/10000) -i > 0
                for j in range(1,floor(sqrt(change)))
                    if floor(num%10000)+j <= 10000
                        grid.arr[floor(idx/10000-i),idx%10000+j]+=distrubution
                    else
                        grid.arr[floor(idx/10000-i),idx%10000-j]+=distrubution
                    end
                    if floor(num%10000)-j > 0
                        grid.arr[floor(idx/10000-i),idx%10000-j]+=distrubution
                    else
                        grid.arr[floor(idx/10000-i),idx%10000+j]+=distrubution
                    end
                end
            else
                for j in range(1,floor(sqrt(change)))
                    if floor(idx%10000)+j <= 10000
                        grid.arr[floor(idx/10000+i),idx%10000+j]+=distrubution
                    else
                        grid.arr[floor(idx/10000+i),idx%10000-j]+=distribution
                    end
                    if floor(num%10000)-j > 0
                        grid.arr[floor(idx/10000+i),idx%10000-j]+=distrubution
                    else
                        grid.arr[floor(idx/10000+i),idx%10000+j]+=distrubution
                    end
                end
            end 
        end
    end
end

#this function is for molecules that have an equlibrium equation
function balance(moles)
    for val in keys(moles)
        if val == "Ammonium" || val == "Ammonium Ion" 
            
            #verify and create if needed all chemicals in this equation
            if !haskey(moles, "Hydrogen")
                push!(moles, "Hydrogen" => mole_load("Hydrogen"))
            end
            if !haskey(moles, "Ammonium")
                push!(moles, "Ammonium" => mole_load("Ammonium"))
            end
            if !haskey(moles, "Ammonium Ion")
                push!(moles, "Ammonium Ion" => mole_load("Ammonium Ion"))
            end

            for (i,v) in enumerate(moles("Ammonium").arr)
                equal = (v*v.factor+moles("Ammonium Ion").arr[i]*moles("Ammonium Ion").factor)/2
                v=equal / v.factor
                moles("Ammonium Ion").arr[i] = equal / moles("Ammonium Ion").factor
                moles("Hydrogen").arr[i] = equal / moles("Hydrogen").factor
            end
        end
    end
end

function ph_check(moles,x,y)

    Hcount=0
    OHcount=0
    for m in keys(moles)
        if m == "Hydrogen"
            Hcount += moles("Hydrogen").arr[x,y]*moles("Hydrogen").factor
        end
        hbase=0
        obase=0

        #checking for basic chemicals in solution for H atoms to react with
        for (x,stut) in enumerate(moles[m].structure)
            
            if stut =="H"
                if isdigit(moles(m).structure[x+1])
                    if isdigit(moles(m).structure[x+2])
                        hbase = parse(Int, moles(m).structure[x+1] * moles(m).structure[x+2])
                    else
                        hbase = parse(Int, moles(m).structure[x+1])
                    end
                else
                    hbase=1
                end
            end
            if stut == "O"
                if isdigit(moles(m).structure[x+1])
                    if isdigit(moles(m).structure[x+2])
                        obase = parse(Int, moles(m).structure[x+1] * moles(m).structure[x+2])
                    else
                        obase = parse(Int, moles(m).structure[x+1])
                    end
                else
                    obase=1
                end
            else
                continue
            end
            if hbase/obase < 2 && obase!=0
                OHcount = moles(m).arr[x,y] * moles(m).factor
            end
        end
    end
    #calulating ph after H atoms react out
    Hcount = Hcount - OHcount
    ml = Hcount*3/10^(-15)
    return (-log(ml))

end



            