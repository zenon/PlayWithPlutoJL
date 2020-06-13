### A Pluto.jl notebook ###
# v0.9.8

using Markdown

# ╔═╡ 56aebcb2-a7db-11ea-0cb0-bd951564cf86
begin
	using Pkg
	Pkg.activate("c:\\projects\\plutoJL\\stat")
	using Test
	using Distributions
	using Plots
	using StatsPlots
	using LinearAlgebra # normalize
	md"""
	# Statistical Rethinking
	### mainly chapter 2
	We start with grid approximation. Binomial experiment, 9 trials found 6 times positive.
	"""
end

# ╔═╡ 5af04f80-ac24-11ea-2b6b-575ab5b30ef6
md"missing: quadratic approximation"

# ╔═╡ 24d96060-a82a-11ea-310e-11a110903658
n = 500 # size of grid

# ╔═╡ ab288e90-a8aa-11ea-3872-f9c052867d80
# know nothing prior
prior(p) = 1.0

# ╔═╡ c8405f30-a8aa-11ea-0aa4-39edc4dfff37
likelihoodFn(p) = pdf(Binomial(9, p),6)

# ╔═╡ 67bc9db0-a817-11ea-205f-fd60cc332081
# grid approximation (2.3, p 40)
posterior = begin
	pGrid = range(0,1, length = n)
	likelihood = map(likelihoodFn, pGrid)
	normalize(prior.(pGrid) .* likelihood,1) # 1-norm
end;

# ╔═╡ a8f27e80-a817-11ea-1f85-c3fc52508939
plot(pGrid, posterior)

# ╔═╡ 00e45fc0-a89d-11ea-2e6b-7b949b0ab43c
sum(posterior)

# ╔═╡ a480f980-a899-11ea-23e0-8b5336080b14
md"## Now let's sample (cf. Code 3.3 p 52)"

# ╔═╡ bfc0fce0-a899-11ea-1256-8f54a36f1d8b
md"""Way 1, by inverting the cumulative distribution function.

Here, we are one dimensional, so it's easy."""

# ╔═╡ 182c69e0-a82d-11ea-2ee6-77bab85d4030
posteriorCDF = begin
	x = copy(posterior)
	for i in 2:length(x)
		x[i] = x[i-1] + x[i]
	end
	x
end;

# ╔═╡ 8a01f440-a82d-11ea-37c6-ebc4748ced77
plot(posteriorCDF)

# ╔═╡ a5d28592-a832-11ea-3958-4fa412eef6f0
# assumes a sorted array arr, and finds the first value larger than x 
# (may fail in strange ways, if it doesn't exist)
function findLargerThan(arr, x)
	findfirst(a -> a > x, arr)
end

# ╔═╡ 40fd6c10-a833-11ea-0e73-5fdb52f240ab
findLargerThan(posteriorCDF, 0.5)

# ╔═╡ e2c56350-a823-11ea-0ac4-3d7763d8169b
sampleFromArray(a) = findLargerThan(posteriorCDF, rand())

# ╔═╡ 34b895f0-a825-11ea-20b5-010081b62001
repeatedly(f, n) = map(f, 1:n)

# ╔═╡ fd3cafbe-a834-11ea-367b-2711cba47ecf
samples = repeatedly(x -> sampleFromArray(posteriorCDF), 1000) .* 1.0 ./ n

# ╔═╡ 1e136ce0-a824-11ea-0ff9-e52ace62048c
plot(samples, seriestype = :scatter)

# ╔═╡ 106e0440-a835-11ea-0ae0-a5b67fbe01a1
histogram(samples, bins = 100)

# ╔═╡ 43a25460-a993-11ea-117c-59a6488b90bb
md"## Alternatively we can try to fit o a normal distribution, right?"

# ╔═╡ 9d17e860-a8b8-11ea-276d-0b6fb684a052
md"What kind of fit is the following?"

# ╔═╡ 28253f80-a8b8-11ea-3ccb-21a0aebc45fb
begin
	fitted       = fit(Normal, samples)
	pdfFitted(p) = pdf(fitted, p)
	plot(pGrid, normalize(map(pdfFitted, pGrid), 1), label ="fit")
	plot!(pGrid, posterior, label = "posterior")
end

# ╔═╡ 021a14fe-a96b-11ea-0742-6d081b5e1614
md"# 2.8 p 45, Metropolis Hastings"

# ╔═╡ 12060280-a96b-11ea-005a-2f08bcb6c2f8
# brings pp into [0, 1]
function probabilify(pp)
	while pp < 0.0 || pp > 1.0
		pp = abs(pp)
		if pp > 1.0
		  pp = 2.0 - pp
		end
	end
	pp
end

# ╔═╡ 603cac50-a8fe-11ea-228f-6160493035bc
mmSamples = begin
	nSamples = 500
	p = Array{Float64, 1}(undef, nSamples)
	p[1] = 0.5
	W, L = 6, 3
	for i in 2:nSamples
		pp = probabilify(rand(Normal(p[i-1], 0.1))) # 0.1? adjust?
		q0 = pdf(Binomial(W+L, p[i-1]), W)
		q1 = pdf(Binomial(W+L, pp), W)
		p[i] = rand() < q1/q0 ? pp : p[i-1]          # quotient of probabilities???
	end
	p
end;

# ╔═╡ 03166bd0-a96a-11ea-196f-f1a15b93b4b8
begin
	pl01 = plot(mmSamples, seriestype = :scatter)
	pl02 = histogram(mmSamples, bins = 100)
	plot(pl01, pl02, layout=2)
end

# ╔═╡ 3a30a1b0-a8a4-11ea-3980-37e11924ef6d
md"""
## Posterior Predictive Distribution
This posterior describes our current state of knowledge about the probability.

So if we want to predict the next outcome of an experiment, we need to do 
the **posterior predictive distribution**.
"""

# ╔═╡ aded5c80-acdf-11ea-0e4b-f37455e0fa31
p0, mx0 = 0.6, 14

# ╔═╡ b585a2e0-acdf-11ea-046e-85161c3cf40e
md"Prediction for the next $(mx0) outcomes, given that p=$(p0)."

# ╔═╡ 56b0e0d0-ac13-11ea-32a8-ab88417f76fb
begin
	local m = 14
	local f(p, n) = pdf(Binomial(m, p),n)
	local r = 0:13
	local ppd = map(s -> f(0.7, s), r)
	bar(r, ppd)
end

# ╔═╡ bf7a97a0-ac13-11ea-21d5-299146bfd950
md"Now apply to all samples."

# ╔═╡ afc6dbb0-ac14-11ea-370e-dfd30ae975e3
numTrials = 9

# ╔═╡ 810153e2-ac15-11ea-02f3-d9b6158fde19
# may still be wrong. How do the first and last argument interact?
# R: rbinom(1e4, size = numTrials, prob = mmSamples)
begin
	mx2 = numTrials # highest shown in the plot (no sense to be above numTrials)
	ff2(p) = rand(Binomial(numTrials, p))
	ppd2 = map(ff2, mmSamples)
	histogram(ppd2,
		title="posterior predictive distribution for $numTrials trials")
end

# ╔═╡ Cell order:
# ╠═5af04f80-ac24-11ea-2b6b-575ab5b30ef6
# ╠═56aebcb2-a7db-11ea-0cb0-bd951564cf86
# ╠═24d96060-a82a-11ea-310e-11a110903658
# ╠═ab288e90-a8aa-11ea-3872-f9c052867d80
# ╠═c8405f30-a8aa-11ea-0aa4-39edc4dfff37
# ╠═67bc9db0-a817-11ea-205f-fd60cc332081
# ╠═a8f27e80-a817-11ea-1f85-c3fc52508939
# ╠═00e45fc0-a89d-11ea-2e6b-7b949b0ab43c
# ╠═a480f980-a899-11ea-23e0-8b5336080b14
# ╟─bfc0fce0-a899-11ea-1256-8f54a36f1d8b
# ╠═182c69e0-a82d-11ea-2ee6-77bab85d4030
# ╠═8a01f440-a82d-11ea-37c6-ebc4748ced77
# ╠═a5d28592-a832-11ea-3958-4fa412eef6f0
# ╠═40fd6c10-a833-11ea-0e73-5fdb52f240ab
# ╠═e2c56350-a823-11ea-0ac4-3d7763d8169b
# ╠═34b895f0-a825-11ea-20b5-010081b62001
# ╠═fd3cafbe-a834-11ea-367b-2711cba47ecf
# ╠═1e136ce0-a824-11ea-0ff9-e52ace62048c
# ╠═106e0440-a835-11ea-0ae0-a5b67fbe01a1
# ╠═43a25460-a993-11ea-117c-59a6488b90bb
# ╠═9d17e860-a8b8-11ea-276d-0b6fb684a052
# ╠═28253f80-a8b8-11ea-3ccb-21a0aebc45fb
# ╠═021a14fe-a96b-11ea-0742-6d081b5e1614
# ╠═12060280-a96b-11ea-005a-2f08bcb6c2f8
# ╠═603cac50-a8fe-11ea-228f-6160493035bc
# ╠═03166bd0-a96a-11ea-196f-f1a15b93b4b8
# ╠═3a30a1b0-a8a4-11ea-3980-37e11924ef6d
# ╠═aded5c80-acdf-11ea-0e4b-f37455e0fa31
# ╠═b585a2e0-acdf-11ea-046e-85161c3cf40e
# ╠═56b0e0d0-ac13-11ea-32a8-ab88417f76fb
# ╠═bf7a97a0-ac13-11ea-21d5-299146bfd950
# ╠═afc6dbb0-ac14-11ea-370e-dfd30ae975e3
# ╠═810153e2-ac15-11ea-02f3-d9b6158fde19
