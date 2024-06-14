using Plots

"""
Translate a continuous value to a discrete state.

Arguments:
- xx: Continuous value to be discretized.
- xmin: Minimum value of the continuous space.
- xmax: Maximum value of the continuous space.
- num: Number of discrete states.

Returns:
- ii: Discrete state corresponding to the continuous value.
"""
function discrete(xx::Float64, xmin::Float64, xmax::Float64, num::Int)
    # Scale and shift the continuous value to the range [1, num]
    index = round(Int, num * (xx - xmin) / (xmax - xmin) + 1)

    # Clamp the value between 1 and num
    return max(1, min(index, num))
end

"""
Return vector of changes in q_c, across actions.
"""
function make_q_c_actions(C::Int, D_C_min::Float64, D_C_max::Float64, D::Int, Q_const::Float64)
    # Construct the D_C array
    D_C = range(D_C_min, D_C_max, length=D)

    return Q_const * repeat([0; D_C/C], 1, C)
end

"""
Constructs a mapping between before-states and after-states based on given parameters.

Arguments:
- C: Number of discretized states of the clean energy share.
- D_C_min: Highest clean energy decrease.
- D_C_max: Highest clean energy increase.
- D: Number of possible changes in renewable energy.
- Q_const: Total amount of power that needs to be provided using clean or dirty plants.

Returns:
- state1: State before actions take effect.
- state2a: Possible resulting states (first option).
- state2b: Possible resulting states (second option).
- xprob2: Probability matrix of transitions to state2b.
- q_c: Power distribution for clean plants.
- q_f: Power distribution for dirty plants.
"""
function make_actions(C::Int, D_C_min::Float64, D_C_max::Float64, D::Int, Q_const::Float64)
    # Construct the D_C array
    D_C = range(D_C_min, D_C_max, length=D)

    # Initialize matrices to store states and probabilities
    state1 = repeat((1:C)', 1+D, 1) # as indices

    state2a = collect(1:C)' # as indices
    state2b = collect(1:C)' # as indices
    prob2 = [1.0] # probability of going to state2b

    # Loop over negative D_C values
    for ii in 1:sum(D_C .< 0)
        state2a = vcat(state2a, (1:C)' .+ ceil(Int, D_C[ii]))
        state2b = vcat(state2b, (1:C)' .+ floor(Int, D_C[ii]))
        push!(prob2, 1.0 - (-floor(D_C[ii]) + D_C[ii]))
    end

    # Loop over non-negative D_C values
    for ii in 1:sum(D_C .>= 0)
        state2a = vcat(state2a, (1:C)' .+ floor(Int, D_C[ii + sum(D_C .< 0)]))
        state2b = vcat(state2b, (1:C)' .+ ceil(Int, D_C[ii + sum(D_C .< 0)]))
        push!(prob2, 1.0 - (ceil(D_C[ii + sum(D_C .< 0)]) - D_C[ii + sum(D_C .< 0)]))
    end

    # Ensure states are within bounds
    state2a[state2a .< 1] .= 1
    state2a[state2a .> C] .= C
    state2b[state2b .< 1] .= 1
    state2b[state2b .> C] .= C

    xprob2 = repeat(prob2, 1, C)

    q_c = make_q_c_actions(C, D_C_min, D_C_max, D, Q_const)
    q_f = -q_c

    return state1, state2a, state2b, xprob2, q_c, q_f
end

"""
Calculate the total economic costs for all power generation.

Arguments:
- s_c: Clean energy share (vector or matrix).
- Q: Total amount of power provided in MW.
- q_c: Power distribution for clean plants (scalar or matrix).
- q_f: Power distribution for dirty plants (scalar or matrix).
- P_f: Cost per energy unit for fossil fuels (\$/MWs).
- alpha_wind: Exponent for wind technology cost calculation.
- alpha_solar: Exponent for solar technology cost calculation.
- declining: Flag indicating declining construction costs.
- e_of_scale: Flag indicating the use of cost scaling.

Returns:
- yy: Total economic costs for power generation.
"""

function ecost(s_c::Union{AbstractVector{Float64}, Float64}, Q::Float64, q_c::Float64,
               q_f::Float64, P_f::Float64, alpha_wind::Float64,
               alpha_solar::Float64, declining::Int, e_of_scale::Bool)
    Msecs = 365.25*24*60*60/1e6

    FC_f = P_f * Msecs * (1 .- s_c) * Q

    OC_f_q = 36e3
    OC_f = ((1 .- s_c) .* Q) * OC_f_q

    if q_f > 0
        CC_f = 2000 * 1000 * q_f
    else
        CC_f = 0
    end

    OC_wind = 22e3
    OC_solar = 28e3

    if e_of_scale
        cost_scale = s_c * Q
    else
        cost_scale = 0.1 * Q
    end

    OC_c = ((OC_wind + OC_solar) / 2) * s_c * Q

    if declining == 0
        CC_wind_q = ((4750 / 6400^-alpha_wind) .* (s_c .* Q) .^-alpha_wind) .* (s_c .> 0)
        CC_solar_q = ((2400 / 52e3^-alpha_solar) .* (s_c .* Q) .^-alpha_solar) .* (s_c .> 0)
        if q_c > 0
            CC_c = ((CC_wind_q + CC_solar_q) / 2) .* 1000 .* q_c .* exp.(34 .* q_c ./ cost_scale)
        elseif s_c isa AbstractVector
            CC_c = zeros(length(s_c))
        else
            CC_c = 0
        end
    else
        alpha_wind_adj = alpha_wind .* (s_c .* Q .< 600e3) .+ alpha_wind/2 .* (s_c .* Q .>= 600e3)
        alpha_solar_adj = alpha_solar .* (s_c .* Q .< 600e3) .+ alpha_solar/2 .* (s_c .* Q .>= 600e3)

        CC_wind0 = ((2400 / (60e3^-alpha_wind)) .* (s_c .* Q .< 600e3) .+ (2400 / (60e3^-alpha_wind) .* (600e3^-(alpha_wind/2)) .* (s_c .* Q .>= 600e3)))
        CC_wind_q = CC_wind0 .* (s_c .* Q) .^-alpha_wind_adj
        if q_c > 0
            CC_c = CC_wind_q .* 1000 .* q_c .* exp.(34 .* q_c ./ cost_scale)
        elseif s_c isa AbstractVector
            CC_c = zeros(length(s_c))
        else
            CC_c = 0
        end
    end

    if q_c > 0 && s_c isa AbstractVector
        CC_c[s_c .== 0] .= ((1.0206e5 + 2.1058e4) / 2) .* 1000 .* q_c .* exp(q_c / (0.1 * Q))
    end

    return FC_f .+ OC_f .+ OC_c .+ CC_f .+ CC_c
end

function ecost(s_c::AbstractMatrix{Float64}, Q::Float64,
               q_c::AbstractMatrix{Float64},
               q_f::AbstractMatrix{Float64}, P_f::Float64,
               alpha_wind::Float64, alpha_solar::Float64,
               declining::Int, e_of_scale::Bool)
    Msecs = 365.25*24*60*60/1e6

    FC_f = P_f * Msecs * (1 .- s_c) * Q

    OC_f_q = 36e3
    OC_f = ((1 .- s_c) .* Q) * OC_f_q

    CC_f = 2000 * 1000 * q_f
    CC_f[q_f .< 0] .= 0

    OC_wind = 22e3
    OC_solar = 28e3

    if e_of_scale
        cost_scale = s_c * Q
    else
        cost_scale = 0.1 * Q
    end

    OC_c = ((OC_wind + OC_solar) / 2) * s_c * Q

    if declining == 0
        CC_wind_q = ((4750 / 6400^-alpha_wind) .* (s_c * Q).^-alpha_wind) .* (s_c .> 0)
        CC_solar_q = ((2400 / 52e3^-alpha_solar) .* (s_c * Q).^-alpha_solar) .* (s_c .> 0)
        CC_c = ((CC_wind_q + CC_solar_q) / 2) .* 1000 .* q_c .* exp.(34 .* q_c ./ cost_scale)
    else
        alpha_wind_adj = alpha_wind .* (s_c .* Q .< 600e3) .+ alpha_wind/2 .* (s_c .* Q .>= 600e3)
        alpha_solar_adj = alpha_solar .* (s_c .* Q .< 600e3) .+ alpha_solar/2 .* (s_c .* Q .>= 600e3)

        CC_wind0 = ((2400 / (60e3^-alpha_wind)) .* (s_c .* Q .< 600e3) .+ (2400 / (60e3^-alpha_wind) .* (600e3^-(alpha_wind/2)) .* (s_c .* Q .>= 600e3)))
        CC_wind_q = CC_wind0 .* (s_c .* Q) .^-alpha_wind_adj
        CC_c = CC_wind_q .* 1000 .* q_c .* exp.(34 .* q_c ./ cost_scale)
    end

    CC_c[s_c .== 0] .= ((1.0206e5 + 2.1058e4) / 2) .* 1000 .* q_c[s_c .== 0] .* exp.(q_c[s_c .== 0] ./ (0.1 * Q))
    CC_c[q_c .< 0] .= 0

    return FC_f .+ OC_f .+ OC_c .+ CC_f .+ CC_c
end

"""
Simulate the stochastic fossil fuel price based on the specified process.

Arguments:
- P_f1: Previous price of fossil fuels.
- process: Integer indicating the stochastic process to use (1 for Fuss 2008 Process, 2 for AR(1) Process).
- sigma: Standard deviation for price drive (only used for process 2).

Returns:
- P_f2: Simulated price of fossil fuels after one time step.
"""
function simustep(P_f1::Float64, process::Int, sigma::Union{Nothing, Float64}=nothing)
    dt = 1  # Time step

    if process == 1
        # Fuss 2008 Process

        # Market uncertainty
        sigma_f = 0.0092376  # Electricity volatility parameter

        # Price drives
        mu_f = log(3860)  # Price of electricity reverts to mean exp(mu_f)
        alpha = 0.045564

        dW_f = randn() * dt
        dP_f = alpha * (mu_f - log(P_f1)) * P_f1 * dt + sigma_f * P_f1 * dW_f

        P_f2 = max(0, P_f1 + dP_f)

    elseif process == 2
        # AR(1) Process

        mu = 0.03  # Price of electricity reverts to mean exp(mu_f)
        dW_f = randn() * sigma
        log_P_f = log(P_f1) + mu + dW_f

        P_f2 = exp(log_P_f)
    else
        error("Unknown process number")
    end

    return P_f2
end

"""
Optimize the cost using Bellman optimization for a stochastic process.

Arguments:
- N: Number of Monte Carlo projections.
- S: Planning horizon (timesteps).
- C: Discretized version of the clean energy share.
- D_C_min: Highest clean energy decrease.
- D_C_max: Highest clean energy increase.
- D: Number of possible changes in renewable energy.
- P_f_min: Minimum fossil fuel price.
- P_f_max: Maximum fossil fuel price.
- F: Discretized versions of P_f.
- Q_const: Total amount of power that needs to be provided using clean or dirty plants.
- alpha_wind: Exponent for wind technology cost calculation.
- alpha_solar: Exponent for solar technology cost calculation.
- process: Stochastic process selection.
- declining: Flag indicating declining construction costs.
- fuel_sigma: Standard deviation for fuel price stochastic process.
- e_of_scale: Flag indicating the use of cost scaling.

Returns:
- strat: SxCxF matrix representing the optimal strategy.

"""
function optimize_cost(N::Int, S::Int, C::Int, D_C_min::Float64, D_C_max::Float64, D::Int,
                      P_f_min::Float64, P_f_max::Float64, F::Int, Q_const::Float64,
                      alpha_wind::Float64, alpha_solar::Float64, process::Int, declining::Int,
                      fuel_sigma::Float64, e_of_scale::Bool)
    strat = zeros(Int64, S-1, C, F)

    discount = 0.05  # Discount rate

    P_f = collect(range(P_f_min, P_f_max, length=F))
    S_C = collect(range(0, 1, length=C))

    # STEP 1: Calculate V[S] under every scenario
    VV2 = zeros(C, F)
    for Fi in 1:F
        VV2[:, Fi] = ecost(S_C, Q_const, 0., 0., P_f[Fi], alpha_wind, alpha_solar, declining, e_of_scale) * (1/(discount))
    end

    # STEP 2: Determine optimal action for t = S-1 and back
    state1, state2a, state2b, xprob2, q_c, q_f = make_actions(C, D_C_min, D_C_max, D, Q_const)

    for tt in (S-1):-1:1
        println(tt)
        VV1 = zeros(C, F)

        for Fi in 1:F
            sums1 = zeros(size(state2a))
            sums2 = zeros(size(state2b))

            for ii in 1:N
                P_f2 = simustep(P_f[Fi], process, fuel_sigma)
                Fi2 = discrete(P_f2, P_f_min, P_f_max, F)

                sums1 += VV2[(Fi2-1)*C .+ state2a]
                sums2 += VV2[(Fi2-1)*C .+ state2b]
            end

            ecost_later1 = reshape(sums1, size(state2a)) / N
            ecost_later2 = reshape(sums2, size(state2b)) / N
            later = (xprob2 .* ecost_later2 .+ (1 .- xprob2) .* ecost_later1)
            ecost_now = ecost(S_C[state1], Q_const, q_c, q_f, P_f[Fi], alpha_wind, alpha_solar, declining, e_of_scale)
            values = ecost_now + exp(-discount) * later

            indices = argmin(values, dims=1)
            strat[tt, :, Fi] .= [ind[1].I[1] for ind in eachcol(indices)]
            VV1[:, Fi] .= vec(values[indices])
        end

        VV2 = copy(VV1)
    end

    return strat
end

"""
Simulate without a strategy for T time steps.
"""
function simu(T::Int, P_f0::Float64, process::Int, sigma::Union{Nothing, Float64}=nothing)
    P_f = [P_f0]

    for t in 1:T-1
        P_f_t = simustep(P_f[t], process, sigma)
        push!(P_f, P_f_t)
    end

    return P_f
end

"""
Plot a strategy over time.
"""
function plot_strat(strat::AbstractArray{Int}, C::Int, D_C_min::Float64, D_C_max::Float64, D::Int, linespec::Symbol=:solid, Fi::Int=5, color::Union{Nothing, RGB}=nothing)
    # Generate a vector of evenly spaced values from D_C_min to D_C_max, adding 0 at the start
    D_C = [0; range(D_C_min, stop=D_C_max, length=D) / C]
    cc = 0.143
    ac = Int[]
    dc = discrete(cc, 0., 1., C)

    # Initialize the first element of the clean energy share array cc
    cc_array = [cc]

    for ii in 2:50
        before = discrete(cc_array[ii-1], 0., 1., C)
        push!(ac, strat[ii-1, before, Fi])
        push!(cc_array, cc_array[ii-1] + D_C[ac[end]])
    end

    # Plot clean energy share over the years 2013 to 2062
    years = 2013:2062
    if isnothing(color)
        plot!(years, cc_array, linestyle=linespec)
    else
        plot!(years, cc_array, linestyle=linespec, color=color)
    end

    title!("Clean Energy Share"; fontsize=20)
    xlabel!("Year")
    ylabel!("Clean Energy Share")
    xlims!(2013,2062)

    # Keeping the plot visible for next potential plots
    display(current())

    return cc_array
end
