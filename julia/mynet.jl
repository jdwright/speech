"missing some piece of this tutorial, can't find on the web"


using Flux #: onehotbatch, onecold, crossentropy, throttle
using Base.Iterators: repeated
function trainmodel(X, Y, labelset, xy)
    # xy = size(first(imgs))
    m = Chain(
        Dense(xy[1]*xy[2], 8, relu),
        Dense(8, length(labelset)),
        softmax
    )
    loss(x, y) = crossentropy(m(x), y) 
    opt = ADAM(); # popular stochastic gradient descent variant
    n = 200
    dataset = repeated((X,Y), n) # repeat the data set 200 times, as opposed to @epochs 200 ...
    evalcb = () -> @show(loss(X, Y)) # callback to show loss
    Flux.train!(loss, params(m), dataset, opt, cb = throttle(evalcb, 10)); #took me ~5 minutes to train on CPU
    m
end

using Statistics, Flux
using Flux: onehotbatch
labels = Flux.Data.MNIST.labels();
test_X = hcat(float.(reshape.(Flux.Data.MNIST.images(:test), :))...)
test_Y = onehotbatch(Flux.Data.MNIST.labels(:test), [5, 0, 4, 1, 9, 2, 3, 6, 7, 8]);
m(test_X[:,5287]) # Note the 7th index ( corresponding to the digit 6 ) is nearly 1
onecold(m(test_X[:,5287])) - 1 #minus 1 since we start from 0, but indexing in Julia starts at 1
accuracy(x, y) = mean(onecold(m(x)) .== onecold(y)) # cute way to find average of correct guesses
X = hcat(float.(reshape.(imgs, :))...) #stack all the images
Y = onehotbatch(labels, [5, 0, 4, 1, 9, 2, 3, 6, 7, 8]) # just a common way to encode categorical variables
accuracy(X, Y)
accuracy(test_X, test_Y)
