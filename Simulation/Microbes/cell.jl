#contain the microbe object and
using Random


mutable struct microbe
    name
    size::Int8
    ph::Float16
    vph::Float16
    food
    excrement
    condition::Float64
    life::Int16
    mass::Float32
    x::Int16
    y::Int16

end

function update_cell(cell::microbe, deltaT, moles, var)

    x=cell.x
    y=cell.y
    proxyph = ph_check(moles, x, y)
    growthfactor = abs((proxyph - cell.ph) / sqrt(cell.vph))
    growthfactor = exp(-growthfactor)
    rintake::BigFloat = 0
    for i in cell.food
        if i=="None" || i==0
            continue
        end
        #cellular respiration
        if i == "Glucose"
            if cell.condition <= 100
                rintake =  moles[i].arr[x, y] 
                rintake *= ((1 - (var / 200)) + rand() * var / 100)
                rintake *= growthfactor
                rintake /= moles[i].dCo
                rintake = floor(rintake)
                moles[i].arr[x, y] -= rintake
                moles[i].total-=rintake
                rintake *= moles[i].factor
                atp = rintake * 38
                atp = atp / (10000 * deltaT)
                cell.condition += atp
                cell.mass += rintake/1000000
            end
        elseif  i == "Carbon Dioxide"
            if cell.condition <= 100
                rintake =  moles[i].arr[x, y] 
                rintake *= ((1 - (var / 200)) + rand() * var / 100)
                rintake *= growthfactor
                rintake /= moles[i].dCo
                rintake = floor(rintake)
                moles[i].arr[x, y] -= rintake
                moles[i].total-=rintake
                rintake *= moles[i].factor
                atp = floor(rintake * 38 /6)
                atp = atp / (10000 * deltaT)
                cell.condition += atp
                cell.mass += rintake/1000000
            end

        else
            #nutrients for growth/reproduction
            if cell.condition > 50 && cell.mass < 100
                intake::BigFloat =  moles[i].arr[x, y]
                intake *= growthfactor / moles[i].dCo
                intake *=  ((1 - (var / 200)) + rand() * var / 100)
                intake = floor(intake)
                moles[i].arr[x, y] -= intake
                moles[i].total-=intake
                cell.mass += intake*moles[i].factor / 10000
            end
        end
    end

    for i in cell.excrement
        if i=="None" || i==0
            continue
        end
        if i == "Carbon Dioxide"
            out = rintake * 6
            moles[i].arr[x, y] += floor(out / moles[i].factor)
            moles[i].total+=floor(out)
        else
            out = floor(rintake * ((1 - (var / 200)) + rand() * var / 100)/moles[i].dCo)
            moles[i].arr[x, y] += floor(out / moles[i].factor)
            moles[i].total+= floor(out)
        end
    end

    #updating energy consuption and checking for death
    cell.condition -= (.1*deltaT)
    cell.life += deltaT

    if cell.condition < 0
        return "Die"
    else
        death = ((1 - (var / 200)) + rand() * var / 100) * exp(-(cell.condition/100)) * (cell.life / 50000)
        if death >= 1
            return "Die"
        end
    end

    #birth conditions
    birth = ((1 - (var / 200)) + rand() * var / 100) * (cell.condition / 100) * (cell.mass / 100)
    if birth >= 1
        cell.mass=0
        return "Birth"
    end

    return 0


end