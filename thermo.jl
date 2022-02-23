import Pkg;

using Unitful
using DataFrames
using CSV

airTable = CSV.read("/Users/brian/Developer/Julia/Heat Transfer/properties_air.csv", DataFrame)
waterTable = CSV.read("/Users/brian/Developer/Julia/Heat Transfer/water_data.csv", DataFrame)
 

struct WaterProperties
	P	
	ν_f	
	ν_g	
	h_fg	
	cp_f	
	cp_g	
	mu_f	
	mu_g	
	k_f	
	k_g	
	Pr_f	
	Pr_g	
	σ_f	
	β_f
end

WaterProperties(V::Vector) = WaterProperties(V[1]u"bar",	V[2]u"m^3/kg",	V[3]u"m^3/kg",	V[4]u"kJ/kg",	V[5]u"kJ/kg",	V[6]u"kJ/kg",	V[7]u"N*s/m^2",	V[8]u"N*s/m^2",	V[9]u"W/m/K", V[10]u"W/m/K",	V[11],	V[12],	V[13]u"N/m",	V[14]u"K^-1")

struct AirProperties
	ρ
	cp
	μ
	ν
	k
	α
	Pr
end
AirProperties(V::Vector) = AirProperties(V[1]u"kg/m^3", V[2]u"kJ/kg/K", V[3]u"N*s/m^2", V[4]u"m^2/s", V[5]u"W/m/K", V[6]u"W/m/K", V[7])

linearInterp(x1, x2, y1, y2, x) = y1 + (y2-y1)./(x2-x1).*(x-x1)

function getAirProp(table, T)
	row_min = table[table.T .<= T, :][end, :]
	row_max = table[table.T .>= T, :][1, :]

	T_min = row_min.T
	T_max = row_max.T

	props_min = collect(row_min)[2:end]
	props_max = collect(row_max)[2:end]

	if T_min == T_max
		props = props_min
	else
		props = linearInterp(T_min, T_max, props_min, props_max, T)
	end


	properties = AirProperties(props)
end

function getWaterProp(table, T)
	row_min = table[table.T .<= T, :][end, :]
	row_max = table[table.T .>= T, :][1, :]

	T_min = row_min.T
	T_max = row_max.T

	props_min = collect(row_min)[2:end]
	props_max = collect(row_max)[2:end]

	if T_min == T_max
		props = props_min
	else
		props = linearInterp(T_min, T_max, props_min, props_max, T)
	end


	properties = WaterProperties(props)
end

airProp(T) = getAirProp(airTable, T)
waterProp(T) = getWaterProp(waterTable, T)

