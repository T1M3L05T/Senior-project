#grid setup for a molcules and functions needed to update grid with Diffusion

struct moleGrid
    name
    dCo
    total
    arr
    structure
    factor

end

function changeFactor(grid::moleGrid)
    for num in eachindex(grid.arr)
        num= num/2
    end
    grid.factor=grid.factor*2
end

function updateMolecule(grid::moleGrid,deltaT)
    change = floor(dCo*deltaT)
    for num in eachindex(grid.arr)
        if num > 20000
            changeFactor(grid)
        end
        distrubution = floor(grid.arr[floor(num/10000)+1,floor(num%10000)+1]/(1+2(change))^2)
        if distrubution == 0
            continue
        end
        for i in range(1,floor(sqrt(change)))
            if floor(num/10000)+i <= 10000
                for j in range(1,floor(sqrt(change)))
                    if floor(num%10000)+j <= 10000
                        grid.arr[num/10000+i,num%10000+j]=grid.arr[indx/10000+i,indx%10000+j]+distrubution
                    else
                        grid.total=grid.total-distrubution
                    end
                    if floor(num%10000)-j > 0
                        grid.arr[num/10000+i,num%10000-j]=grid.arr[indx/10000+i,indx%10000-j]+distrubution
                    else
                        grid.total=grid.total-distrubution
                    end
                end
            else
                grid.total=grid.total-(distrubution*floor(sqrt(change)))
            end
            if floor(num/10000) -i > 0
                for j in range(1,floor(sqrt(change)))
                    if floor(num%10000)+j <= 10000
                        grid.arr[num/10000+i,num%10000+j]=grid.arr[indx/10000+i,indx%10000+j]+distrubution
                    else
                        grid.total=grid.total-distrubution
                    end
                    if floor(num%10000)-j > 0
                        grid.arr[num/10000+i,num%10000-j]=grid.arr[indx/10000+i,indx%10000-j]+distrubution
                    else
                        grid.total=grid.total-distrubution
                    end
                end
            else
                grid.total=grid.total-(distrubution*floor(sqrt(change)))
            end 
        end
    end
end
 

            