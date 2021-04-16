using AbstractGPs, KernelFunctions, Distributions, Random, Plots
using LinearAlgebra
using Colors

include("utils.jl")

begin
    #include("utils.jl")
    using Plots
    default(grid = false, legend = false, showaxis = false, tickfontcolor = grey1,  markerstrokewidth = 0)
end


function sim_data(x, tau=0)
    y = (12 .- x) .* sin.(10 .- x)
    y = y ./ (maximum(y) - minimum(y)) + rand(Normal(0, tau^2), length(y)) 
end

# plot the true function
X_full = collect(range(0, stop = 20, length = 1000))
y_full = sim_data(X_full, 0)
p = plot(X_full, y_full, label="true function")

# simulate N input data points
N = 44
X = collect(range(0, stop = 20, length = N))
y = sim_data(X, 0.2)
scatter!(X, y, label="input data")

# predictive grid of M locations
M = 57
X_pred= collect(range(minimum(X_full), maximum(X_full), length = M))
scatter!(X_pred, sim_data(X_pred,0), markershape = :hexagon, markersize = 2, label="prediction points")


# Squared Exponential

sqexpkernel(α::Real, ρ::Real) = α^2 * transform(SqExponentialKernel(), 1/(ρ*sqrt(2)))


N = 44
X = collect(range(0, stop = 20, length = N))

α = rand(LogNormal(0.0, 0.1))
ρ = rand(LogNormal(1.0, 1.0))
kernel = sqexpkernel(α, ρ)
K = kernelmatrix(kernel,X)


for i in 1:20
    
    α = rand(LogNormal(1.0, 0.1))
    ρ = rand(InverseGamma(2, 5))
    
    kernel = sqexpkernel(α, ρ)

    K = kernelmatrix(kernel, X_full) + 1e-6 * I(1000)
   
    μ = 5
    y_draw = rand(MvNormal(μ * ones(1000), K))

    if (i == 1)
        p = plot(X_full, y_draw, seriescolor = primary)
    else 
        plot!(X_full, y_draw, seriescolor = primary, lw = rand(Truncated(Normal(0,2), 0, 3), 1))
    end
end
display(p)


histogram(rand(Truncated(Normal(0,2), 0, 5), 100))