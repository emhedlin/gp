using Turing, CSV, DataFrames, Dates, Statistics, AbstractGPs, KernelFunctions, Distributions
using LinearAlgebra, StatsPlots, Distances, Random
# import PyPlot; plt=PyPlot
include("utils.jl")



# Setting up defult Plotting
begin
    using Plots
    default(grid = false, markerstrokewidth = 0, legend = false, showaxis = false, tickfontcolor = grey1)
end

# plot arguments
defs = (markercolor = grey1, legend = false)

# Load data
data_path = joinpath(pwd(), "Birthdays","data", "births_usa_1969.csv")
df = CSV.read(data_path, DataFrame; delim=',')


# Plot all births
df.date = Date.(df.year, df.month, df.day)
df.births_relative100 = df.births ./ mean(df.births) .* 100
scatter(df.id, df.births_relative100; defs...)


# Plot mean per day of year
daily_mean = combine(groupby(df, :day_of_year2), 
    :births_relative100 => mean => :mean)
scatter(daily_mean.day_of_year2, daily_mean.mean, marker)


# Plot mean per day of week
daily_mean = combine(groupby(df, :day_of_week), 
    :births_relative100 => mean => :mean)
scatter(daily_mean.day_of_week, daily_mean.mean; defs..., markersize = 8)



#= 
Model 2: Slow Trend + yearly seasonal trend
f = intercept + f₁ + f₂
intercept ~ N(0,1)
f₁ ~ GP(0,K₁)     
f₂ ~ GP(0,K₂) 

where K₁ = exponentiated quadratic (squared exponential) covariance function
where K₂ = periodic covariance
=#






@model GPRegression(y, X) = begin
    # Priors.
    intercept ~ Normal(80, 10)
    alpha ~ LogNormal(0.0, 0.1)
    rho ~ LogNormal(0.0, 1.0)
    sigma ~ LogNormal(0.0, 1.0)
    
    # Covariance function.
    K₁ = sqexpkernel(alpha, rho)
    K₂ = 
    
    # GP for mean function.
    f₁ = GP(K₁)
    f₂ = GP(K₂)
    
    # Sampling Distribution.
    # NOTE: if X is (N x D), where N=locations, D=input-dimensions, do
    # y ~ f(RowVecs(X), sigma^2 + 1e-6)
    #
    # Similarly, if X is (D x N),
    # y ~ f(ColVecs(X), sigma^2 + 1e-6)
    y ~ f(X, sigma^2 + 1e-6)  # add 1e-6 for numerical stability.
end;

L = 1.5*maximum(xn)
# helper functions
ϕ_eq(N::Int64, M::Int64, L::Float64, x::Vector{Float64}) = 

sin( repeat(π ./ (2 .* L) .* (x .+ L), 1, M) * diagm(LinRange(M, 1, M))) / sqrt(L)




x .+ L
sin(mat)

N, M, L = length(xn), 10, 2.597542768074684
ϕ_eq(N, M, L, xn)











@model model2(x::Int64, y::Float64, c_f₁::Float64, M_f₁::Int64, J_f₂::Int64) = begin
    
    # Transform data
        # center and scale
    xmean = mean(x)
    ymean = mean(y)
    xsd   = std(x)
    ysd   = std(y)
    xn    = (x .- xmean) ./ xsd
    yn    = (y .- ymean) ./ ysd

        # Basis functions for f₁
    L_f₁ = c_f₁ * max(xn)
    ϕ_f₁ = ϕ_


end




scatter(xn, yn; defs..., markercolor = grey1, markersize = 2)






#= 

Eva

=#


function sim_data(x, tau=0)
    y = (12 .- x) .* sin.(10 .- x)
    y = y ./ (maximum(y) - minimum(y)) + rand(Normal(0, tau^2), length(y)) 
end

# plot the true function
X_full = collect(range(0, stop = 20, length = 1000))
y_full = sim_data(X_full, 0)
Plots.plot(X_full, y_full)


# simulate N input data points
N = 44
X = collect(range(0, stop = 20, length = N))
y = sim_data(X, 0.2)
scatter!(X, y, label="input data")

# predictive grid of M locations
M = 57
X_pred= collect(range(minimum(X_full), maximum(X_full), length = M))
scatter!(X_pred, sim_data(X_pred,0), markershape = :hexagon, markersize = 2, label="prediction points")

# defining the kernel
sqexpkernel(alpha::Real, rho::Real) = alpha^2 * transform(SqExponentialKernel(), 1/(rho*sqrt(2)))