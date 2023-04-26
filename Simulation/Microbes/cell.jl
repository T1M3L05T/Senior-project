#contain the microbe object and
using Random


mutable struct microbe
    name
    size::Int8
    ph::Float16
    vph::Float16
    food
    excrement
    condition::Float16
    life::Int16
    mass::Float16
    x::Int16
    y::Int16

end

function update_cell(cell::microbe, deltaT, moles, x, y, var)

    proxyph = ph_check(moles, x, y)
    growthfactor = abs((proxyph - cell.ph) / sqrt(cell.vph / 2))
    growthfactor = exp(-growthfactor)
    rintake = 0
    for i in cell.food
        if i=="None" || i==0
            continue
        end
        #cellular respiration
        if i == "Glucose" || i == "Carbon Dioxide"
            if cell.condition < 100
                rintake = growthfactor * moles[i].dCo * moles[i].arr[x, y] * deltaT * ((1 - (var / 200)) + rand() * var / 100)
                moles[i].arr[x, y] -= rintake
                moles[i].total-=rintake
                rintake *= moles[i].factor
                atp = rintake * 38
                atp = atp / (10000 * deltaT)
                cell.condition += atp
            end

        else
            #nutrients for growth/reproduction
            if cell.condition > 50 && cell.mass < 100
                intake = growthfactor * moles[i].dCo * moles[i].arr[x, y] * deltaT * ((1 - (var / 200)) + rand() * var / 100)
                moles[i].arr[x, y] -= intake
                moles[i].total-=intake
                cell.mass += intake*moles[i].factor / 1000000
                cell.condition -= intake*moles[i].factor / 4000000
            end
        end
    end

    for i in cell.excrement
        if i=="None" || i==0
            continue
        end
        if i == "Carbon Dioxide"
            out = rintake * 6
            moles[i].arr[x, y] += out / moles[i].factor
            moles[i].total+=out/moles[i].factor
        else
            out = rintake * ((.5 - (var / 200)) + rand() * var / 100)
            moles[i].arr[x, y] += out / moles[i].factor
            moles[i].total+=out/moles[i].factor
            cell.mass -=out/2
        end
    end

    #updating energy consuption and checking for death
    cell.condition -= (1 * deltaT)
    cell.life += deltaT
    if cell.condition <= 0
        return "Die"
    end

    if cell.condition > 100
        cell.condition = 100
    elseif cell.condition < 0
        return "Die"
    else
        death = ((1 - (var / 200)) + rand() * var / 100) * (100 / cell.condition) - 1 * (cell.life / 20000)
        if death >= 1
            return "Die"
        end
    end

    #birth conditions
    birth = ((1 - (var / 200)) + rand() * var / 100) * (cell.condition / 100) * (mass / 100)
    if birth >= 1
        cell.mass=0
        return "Birth"
    end

    return 0


end