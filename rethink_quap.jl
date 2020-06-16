### A Pluto.jl notebook ###
# v0.9.9

using Markdown

# ╔═╡ e767c600-afe9-11ea-398d-21e54d671237
begin
	using Pkg
	Pkg.activate("c:\\projects\\plutoJL\\stat")	
	using DataFrames
	using Distributions
	using KernelDensity # kde
	using StatsBase # Histogram
	using Plots
end

# ╔═╡ 4de3c1a0-affd-11ea-1c8d-7778e79982be
md"""
# quap and precis

from [Statistical Rethinking in Julia](https://github.com/StatisticalRethinkingJulia/StatisticalRethinking.jl)

with small changes. I currently have several versions of them. Will clean up later.
I hope.
"""

# ╔═╡ e25937c0-afe9-11ea-04a9-e9e2c72a5656
# some sample data
data = begin
	n = 10000
	df = DataFrame()
	df.Nr = 1.0 .* 1:n
	df.x = rand(Normal(12.7, 0.7777), n)
	df
end

# ╔═╡ ce1c66b0-afe9-11ea-2377-455e5d90ed66
function quap(df::DataFrame)
	d = Dict{Symbol, typeof(Normal(0.0, 1.0))}()
	for var in Symbol.(names(df))
		# kde from KernelDensity. Don't know what it does, yet.
		dens = kde(df[:, var])
		mu = collect(dens.x)[findmax(dens.density)[2]]
		sigma = std(df[:, var], mean=mu)
		d[var] = Normal(mu, sigma)
	end
	(; d...)
end

# ╔═╡ b6b344d0-affd-11ea-25c1-e7ad08862092
md"about right"

# ╔═╡ 4572c920-afea-11ea-3318-fd4c1cacb210
quap(data).x

# ╔═╡ 269ecbc2-aff9-11ea-1937-350774fee2e5
quap(data).Nr # strange :-)

# ╔═╡ 337babe0-aff6-11ea-182d-d5e9daedeba8
function unicode_histogram(data, nbins = 12)
	bars = collect("▁▂▃▄▅▆▇█")
	f = fit(Histogram, data, nbins = nbins)  # nbins: more like a guideline than a rule, really
  	# scale weights between 1 and 8 (length(BARS)) to fit the indices in BARS
  	# eps is needed so indices are in the interval [0, 8) instead of [0, 8] which could
  	# result in indices 0:8 which breaks things
  	scaled = f.weights .* (length(bars) / maximum(f.weights) - eps())
  	indices = floor.(Int, scaled) .+ 1
  	return join((bars[i] for i in indices))
end

# ╔═╡ 321b71e0-aff1-11ea-1cc5-7993e0920640
function precis(df::DataFrame; digits=3, depth=Inf, alpha=0.11)
	m = zeros(length(names(df)), 5)
	histograms = Array{String, 1}(undef, length(names(df))) 
  	for (indx, col) in enumerate(names(df))
    	m[indx, 1] = mean(df[:, col])
    	m[indx, 2] = std(df[:, col])
    	q = quantile(df[:, col], [alpha/2, 0.5, 1-alpha/2])
    	m[indx, 3] = q[1]
    	m[indx, 4] = q[2]
    	m[indx, 5] = q[3]
		histograms[indx] = unicode_histogram(df[:, col])
  	end
	# TODO alpha not used in table
  	vcat(["" "mean" "sd" "5.5%" "50%" "94.5%" ""], 
		 hcat(hcat(names(df), round.(m, digits=digits)), histograms))
end


# ╔═╡ 36df1470-aff1-11ea-03a8-e91c82a8f350
precis(data)

# ╔═╡ 2f12b2d0-affe-11ea-30b9-99abd04dda0d
# WHY??
unicode_histogram(1.0:1000.0)

# ╔═╡ Cell order:
# ╠═4de3c1a0-affd-11ea-1c8d-7778e79982be
# ╠═e767c600-afe9-11ea-398d-21e54d671237
# ╠═e25937c0-afe9-11ea-04a9-e9e2c72a5656
# ╠═ce1c66b0-afe9-11ea-2377-455e5d90ed66
# ╠═b6b344d0-affd-11ea-25c1-e7ad08862092
# ╠═4572c920-afea-11ea-3318-fd4c1cacb210
# ╠═269ecbc2-aff9-11ea-1937-350774fee2e5
# ╠═337babe0-aff6-11ea-182d-d5e9daedeba8
# ╠═321b71e0-aff1-11ea-1cc5-7993e0920640
# ╠═36df1470-aff1-11ea-03a8-e91c82a8f350
# ╠═2f12b2d0-affe-11ea-30b9-99abd04dda0d
