#contain the microbe object and
using Random


struct cell
    name 
    size
    ph
    vph
    food
    excrement
    condition
    time
    mass

end

function update_cell(cell, deltaT, grids, x,y,var)
    
    #calculates a growth factor based on ph
    proxyPH=0
    for spot in grids
        Hcount
        atoms=split(spot.structure,"")
        for (idx,l) in enumerate(atoms)
            if l=="H"
                if atoms[idx+1] < 40
                    Hcount=+ atoms[idx+1]*spot.arr[x,y]
                else
                    Hcount += spot.arr[x,y]
                end
            end
        end
    end
    proxyPH = -log(Hcount*10/3)
    growthFactor = 1-abs(proxyPH-ph)/sqrt(vph)

    #this calculates food intake and updates grids with the intake
    for (i,f) in enumerate(cell.food)
        for spot in grids
            if f == spot.name
                intake = growthFactor*spot.dco*spot.arr[x,y]*(1+rand()/var)
                spot.arr[x,y]=spot.arr[x,y]-intake
                cell.mass=intake*spot.mass*spot.factor
            else
                continue
            end
        end
    end

    #excrements calulations
    for (i,e) in enumerate(cell.excrement)
        for spot in grids
            if e==spot.name
                output = growthFactor*spot.dco*spot.arr[x,y]*(rand()/var)
                spot.arr[x,y]=spot.arr[x,y]+(output/spot.factor)
                cell.mass=cell.mass-(output*spot.mass)
            end
        end
    end

end