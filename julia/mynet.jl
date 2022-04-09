using Flux: onehotbatch, onecold, crossentropy, throttle
using Base.Iterators: repeated
function trainmodel(imgs, labels, labelset)
    X = hcat(float.(reshape.(imgs, :))...) #stack all the images
    Y = onehotbatch(labels, labelset) # just a common way to encode categorical variables
    # xy = size(first(imgs))
    xy = ( length(first(imgs)), 1 )
    m = Chain(
        Dense(xy[1]*xy[2], 32, relu),
        Dense(32, length(labelset)),
        softmax
    )
    loss(x, y) = crossentropy(m(x), y) 
    opt = ADAM(); # popular stochastic gradient descent variant
    dataset = repeated((X,Y),200) # repeat the data set 200 times, as opposed to @epochs 200 ...
    evalcb = () -> @show(loss(X, Y)) # callback to show loss
    Flux.train!(loss, params(m), dataset, opt, cb = throttle(evalcb, 10)); #took me ~5 minutes to train on CPU
    m
end
