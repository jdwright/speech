using SimpleChains, MLDatasets, CUDA

xtrain3, ytrain0 = MLDatasets.MNIST.traindata(Float32);
xtest3, ytest0 = MLDatasets.MNIST.testdata(Float32);
x = 2
xtrain4 = reshape(xtrain3, 28, 28, 1, :);
xtest4 = reshape(xtest3, 28, 28, 1, :);
ytrain1 = UInt32.(ytrain0 .+ 1);
ytest1 = UInt32.(ytest0 .+ 1);

lenet = SimpleChain(
  (static(28), static(28), static(1)),
  SimpleChains.Conv(SimpleChains.relu, (5, 5), 6),
  SimpleChains.MaxPool(2, 2),
  SimpleChains.Conv(SimpleChains.relu, (5, 5), 16),
  SimpleChains.MaxPool(2, 2),
  Flatten(3),
  TurboDense(SimpleChains.relu, 120),
  TurboDense(SimpleChains.relu, 84),
  TurboDense(identity, 10),
)
x=1
xtrain = reshape(xtrain3, (784, 60000))
xtest4 = reshape(xtest3, 28, 28, 1, :);
ytrain1 = UInt32.(ytrain0 .+ 1);
ytest1 = UInt32.(ytest0 .+ 1);

lenet = SimpleChain(
  (static(784)),
  TurboDense(SimpleChains.relu, 256),
  TurboDense(identity, 10),
)

lenetloss = SimpleChains.add_loss(lenet, LogitCrossEntropyLoss(ytrain1));

model = Chain(
    Dense(784, 256, relu),
    Dense(256, 10, relu), softmax
)
loss(x, y) = Flux.Losses.logitcrossentropy(model(x), y)
optimizer = ADAM(0.0001)
parameters = params(model)
# flatten() function converts array 28x28x60000 into 784x60000 (28*28x60000)
train_data = [(Flux.flatten(x_train), Flux.flatten(y_train))]
# Range in loop can be used smaller
@time for i in 1:400
    Flux.train!(loss, parameters, train_data, optimizer)
end
test_data = [(Flux.flatten(x_test), y_test)]
accuracy = 0
for i in 1:length(y_test)
    if findmax(model(test_data[1][1][:, i]))[2] - 1  == y_test[i]
        accuracy = accuracy + 1
    end
end
println(accuracy / length(y_test))
