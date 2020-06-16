### A Pluto.jl notebook ###
# v0.9.9

using Markdown

# ╔═╡ 48830ebe-ae1b-11ea-38e1-b19aee8f67bc
begin
	using Pkg
	Pkg.activate("c:\\projects\\plutoJL\\stat")
	using Test
	using Distributions
	using Plots
	using StatsPlots
	using LinearAlgebra # normalize
	md"""
	# Bad Expectations
	### (thoughts about expectation values)
	"""
end

# ╔═╡ 7e5b15b0-ae1b-11ea-38f3-e58c3cbce52c
md"There are about two popes per square kilometer in Vatican City."
# is this an expectation value in the first place?

# ╔═╡ 90524710-ae1c-11ea-3e57-bb5ca6dc207a
md"""
In throwing one dice, the average is 3.5.

Task: Try to get 3.5 with your die.
"""

# ╔═╡ c1e2aeb0-ae1b-11ea-0fc6-058ab7e2e2e3
md"### The overwhelming majority of german people has more than the average number of legs."

# ╔═╡ 0e408c50-ae1c-11ea-26af-13f0d2faad4d
md"""
- The majority has two legs.
- There is (next to?) nobody who has three legs.
- A small, but existing minority has less than two legs, thus the average is below two.
"""

# ╔═╡ 8d9ac830-ae1c-11ea-35bf-115779221f7f
md"""
### Divergence
We know from Euler, that $$\sum_1^\infty \frac1{n^2} = \frac{\pi^2}6$$ ,
see [Basel Problem](https://en.wikipedia.org/wiki/Basel_problem). 

Thus for $$n=1,2,\dots$$, i.e. the positive integers, 

### $$\rho(n) = \frac6{(n\cdot\pi)^2}$$

sums to one; and we can play with it to find out how it behaves when 
seen as probability distribution.
"""

# ╔═╡ abc24930-ae1e-11ea-0144-a5f24bdff73b
md"""
Why do I think this may be interesting? Well, while the sum over $1/n^2$ converges, the sum over $1/n$ doesn't. Thus the expectation value of $n$, given as 
$$\sum{n\cdot\rho(n)}$$ doesn't exist.
"""

# ╔═╡ 0dc99cb0-ae1e-11ea-0797-cdc1d634ff30
md"First, let's go and sample."

# ╔═╡ 93a1a3ae-ae1d-11ea-3f2b-093108211c67
# No, I don't try to be fast. Why do you ask?
function sample64()
	r = rand()
	n = 1
	piSquared = pi*pi
	s = 6.0/piSquared
	while s < r
		n = n + 1
		nSquared64 = Float64(n*n)
		s = s + 6.0/(piSquared*nSquared64)
	end
	n
end

# ╔═╡ f4e754e0-ae1c-11ea-15b8-611fbe88bd50
@time sample64()

# ╔═╡ 6696d520-ae27-11ea-29f8-474192bbe420
repeatedly(f, n) = map(f, 1:n)

# ╔═╡ 68dc0a30-ae27-11ea-181f-63f8f0a24f05
samples1 = repeatedly(x -> sample64(), 5000);

# ╔═╡ 99c82610-ae27-11ea-3fd5-0717fa04e610
md"Lagest sample: $(maximum(samples1)), percentage of ones: $(length(filter(x -> x==1, samples1))*100/length(samples1)), percentage of twos: $(length(filter(x -> x==2, samples1))*100/length(samples1))."

# ╔═╡ 99d53380-ae29-11ea-010b-31abe6389822
expectation(samples) = sum(samples)/length(samples)

# ╔═╡ 0c2e6cd0-ae2a-11ea-20d5-971396f6c4f2
let	runs = 3, args = 100000:100000:5000000, averages = Array{Array{Float64, 1}}(undef, runs)
	for i in 1:runs
		vals = repeatedly(x -> sample64(),maximum(args))
		parts = map(n -> vals[1:n], args)
		averages[i] = map(samples -> expectation(samples), parts)
	end
	plot(args, 
		averages, 
		title="Averages over number of samples, $runs runs.",
		label = reshape(map(i -> "Run $i", 1:runs), 1, :),
		xlabel = "samples drawn",
		ylabel = "average"
		#,seriestype = :scatter
	)
end

# ╔═╡ 25267c00-ae2a-11ea-31ec-b137d22f1f5b
md"I'm not completely sure what I expected and why. But this isn't it."

# ╔═╡ 912cdbb0-ae34-11ea-05c5-e9761ccda4f3
md"Compare to normal distribution."

# ╔═╡ 97b82972-ae35-11ea-2f65-11116833b7e3
let	runs = 5, args = 100000:100000:5000000, averages = Array{Array{Float64, 1}}(undef, runs)
	for i in 1:runs
		vals = repeatedly(x -> randn(),maximum(args))
		parts = map(n -> vals[1:n], args)
		averages[i] = map(samples -> expectation(samples), parts)
	end
	plot(args, 
		averages, 
		title="Averages over number of samples, $runs runs.",
		label = reshape(map(i -> "Run $i", 1:runs), 1, :),
		xlabel = "samples drawn",
		ylabel = "average"
		#,seriestype = :scatter
	)
end

# ╔═╡ 9f95f260-ae37-11ea-13cf-fd8072ea5bd7


# ╔═╡ bbf58170-ae35-11ea-24a4-89f44b56a461
[1, 2, 3]'

# ╔═╡ Cell order:
# ╠═48830ebe-ae1b-11ea-38e1-b19aee8f67bc
# ╠═7e5b15b0-ae1b-11ea-38f3-e58c3cbce52c
# ╠═90524710-ae1c-11ea-3e57-bb5ca6dc207a
# ╟─c1e2aeb0-ae1b-11ea-0fc6-058ab7e2e2e3
# ╟─0e408c50-ae1c-11ea-26af-13f0d2faad4d
# ╟─8d9ac830-ae1c-11ea-35bf-115779221f7f
# ╟─abc24930-ae1e-11ea-0144-a5f24bdff73b
# ╟─0dc99cb0-ae1e-11ea-0797-cdc1d634ff30
# ╠═93a1a3ae-ae1d-11ea-3f2b-093108211c67
# ╠═f4e754e0-ae1c-11ea-15b8-611fbe88bd50
# ╠═6696d520-ae27-11ea-29f8-474192bbe420
# ╠═68dc0a30-ae27-11ea-181f-63f8f0a24f05
# ╠═99c82610-ae27-11ea-3fd5-0717fa04e610
# ╠═99d53380-ae29-11ea-010b-31abe6389822
# ╠═0c2e6cd0-ae2a-11ea-20d5-971396f6c4f2
# ╠═25267c00-ae2a-11ea-31ec-b137d22f1f5b
# ╠═912cdbb0-ae34-11ea-05c5-e9761ccda4f3
# ╠═97b82972-ae35-11ea-2f65-11116833b7e3
# ╠═9f95f260-ae37-11ea-13cf-fd8072ea5bd7
# ╠═bbf58170-ae35-11ea-24a4-89f44b56a461
