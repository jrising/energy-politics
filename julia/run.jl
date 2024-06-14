include("utils.jl")

using Plots

# Determine the optimal cost path
Q_const = 2281591.  # MW: 1e6 * (20000 TWh / year) / (8766 hr / year)
C = 20  # Number of clean energy shares for planning
D_C_min = -0.5  # Highest clean energy decrease
D_C_max = 1.  # Highest clean energy increase
D = 100
P_f_min = 1000.
P_f_max = 6000.
F = 10
alpha_wind = 0.35
alpha_solar = 0.2
fuel_sigma = 0.08


# Price of Fuel
fig1 = plot(title="Price of Fuel", xlabel="Year", ylabel="Price (\$/TJ)", xlims=(2013, 2062))

P_f0 = 3860.  # Fuel cost ($/TJ)

for ii in 1:6
    P_f = simu(50, P_f0, 2, fuel_sigma)

    plot!(fig1, 2013:2062, P_f, label="")
end

display(fig1)

# Optimize cost
estrat = optimize_cost(50, 50, C, D_C_min, D_C_max, D, P_f_min, P_f_max, F, Q_const, alpha_wind, alpha_solar, 2, 0, fuel_sigma, true)

colors = distinguishable_colors(F)
P_f = range(P_f_min, stop=P_f_max, length=F)

fig2 = plot(title="Economically optimal investment schedule vs. fuel price", xlabel="Year", ylabel="Renewable energy share (s)", xlims=(2013, 2062), ylims=(0, 0.6))

for Fi in 1:F
    cc = plot_strat(estrat, C, D_C_min, D_C_max, D, :solid, Fi, colors[Fi])
    if Fi in [1, 2, 3, 4, 5, 6, 10]
        annotate!(2062.5, cc[end], text("\$$(round(P_f[Fi]))/TJ"))
    end
end

D_C = vcat(0, range(D_C_min, D_C_max, length=D) / C)
colors = distinguishable_colors(F)
P_f = range(P_f_min, P_f_max, length=F)
q_c = make_q_c_actions(C, D_C_min, D_C_max, D, Q_const)

do_plot = 0

plot()
for Fi in 1:F
    cc = 0.143
    costs_estrat = Float64[]
    costs_zeroact = Float64[]
    costs_const = Float64[]
    for ii in 2:50
        before = discrete(cc, 0., 1., C)
        costs_estrat = [costs_estrat; ecost(cc, Q_const, q_c[estrat[ii-1, before, Fi]], -q_c[estrat[ii-1, before, Fi]], P_f[Fi], alpha_wind, alpha_solar, 0, true)]
        costs_zeroact = [costs_zeroact; ecost(cc, Q_const, 0., 0., P_f[Fi], alpha_wind, alpha_solar, 0, true)]
        costs_const = [costs_const; ecost(0.143, Q_const, 0., 0., P_f[Fi], alpha_wind, alpha_solar, 0, true)]

        ac = estrat[ii-1, before, Fi]
        cc += D_C[ac]
    end

    if do_plot == 0
        plot!(2013:2061, costs_estrat, label="", color=colors[Fi])
        plot!(2013:2061, costs_zeroact, label="", color=colors[Fi], linestyle=:dot)
    elseif do_plot == 1
        plot!(2013:2061, costs_zeroact ./ costs_estrat, label="", color=colors[Fi])
    elseif do_plot == 2
        plot!(2013:2061, costs_const ./ costs_estrat, label="", color=colors[Fi])
    end
end

plot!(
    xlabel = "Year",
    title = (
        do_plot == 0 ? "Cost of Economically-Optimal Actions" :
        do_plot == 1 ? "Cost of not investing in each year" :
        "Cost of never investing compared to optimal"
    ),
    ylabel = (
        do_plot == 0 ? "Action Cost (\$)" :
        "Ratio of action costs"
    ),
    legend = false,
    ylimits=(
        do_plot == 0 ? (0, 5e11) :
        do_plot == 1 ? (0.8, 1) :
        (0.9, 1.6)),
    xlimits=(
        do_plot == 0 ? (2013, 2061) :
        do_plot == 1 ? (2013, 2061) :
        (2013, 2061))
)
