#this file is to install any api's not built into julia
#this will keep them from updating every time the program is run

using Pkg
Pkg.add("Blink")
Pkg.add("CSV")
Pkg.add("DataFrames")