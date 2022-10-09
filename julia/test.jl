include("timit.jl")
all = readtimit("/Users/jdwright/Downloads/opt/local/corpora/timit")
using WAV, DSP
using Flux: onehotbatch, onecold, crossentropy, throttle
# x = selectphn(all, "ae")
cache = Dict()
f = x -> cacheread(cache, x)
mapsource( f, allphn(all) )

f = x -> length(cacheread(cache, x))
f = x -> cacheread(cache, x)[x.btime+1:x.etime+1]

alltrain = filter(x -> x.set == "train", all)
alltest = filter(x -> x.set == "test", all)


function getsamples(cache, x)
    c = cacheread(cache, x)
    b = x.btime + 1
    e = x.etime + 1
    if e > length(c)
        e = length(c)
    end
    c[b:e]
end
f = x -> getsamples(cache, x)
mapsource( f, x )


x = tryf(cache, first(all))
oneh = alltrain#[1:1000]
x = map( x -> tryf(cache, x), oneh)
x = vcat(x...)
# imgs = hcat([ first(y) for y in x ]...)
imgs = map( first, x )
imgs = map( x -> x[1:20], imgs )
labels = map(last, x)
labelset = unique(labels)
xy = ( length(first(imgs)), 1 )
X = hcat(float.(reshape.(imgs, :))...) #stack all the images
Y = onehotbatch(labels, labelset) # just a common way to encode categorical variables
m = trainmodel(X, Y, labelset, xy)
using Statistics
labels = Flux.Data.MNIST.labels();
test_X = hcat(float.(reshape.(Flux.Data.MNIST.images(:test), :))...)
test_Y = onehotbatch(Flux.Data.MNIST.labels(:test), [5, 0, 4, 1, 9, 2, 3, 6, 7, 8]);
m(test_X[:,5287]) # Note the 7th index ( corresponding to the digit 6 ) is nearly 1
onecold(m(test_X[:,5287])) - 1 #minus 1 since we start from 0, but indexing in Julia starts at 1
accuracy(x, y) = mean(onecold(m(x)) .== onecold(y)) # cute way to find average of correct guesses
# X = hcat(float.(reshape.(imgs, :))...) #stack all the images
# Y = onehotbatch(labels, [5, 0, 4, 1, 9, 2, 3, 6, 7, 8]) # just a common way to encode categorical variables
accuracy(X, Y)
accuracy(test_X, test_Y)
