# Training all-mechanical neural networks for task learning through in situ backpropagation
We introduce the mechanical analogue of in situ backpropagation to enable highly efficient training of Mechanical Neural Networks. With the exact gradient information, we showcase the successful training of MNNs for behavior learning and machine learning tasks, achieving high accuracy in regression and classification. The details of the approach are in our [arXiv paper](https://doi.org/10.48550/arXiv.2404.15471).
## Setup
The codes are developed in Matlab 2023a. Download the files and run Learningspring2D.m
## Examples
### In situ backpropagation & Behaviors learning
By using the element-wise multiplication of bond elongations in both forward problem and adjoint problem, the exact gradient can be obtained. Using this gradient, we can use gradient descent to minimize the loss function which defines the behaviors of MNNs.
### Regression
We demonstrate the linear regression task using MNNs. The input is a force applied on a node and the outputs are horizontal and vertical displacements defined on other output nodes.
### Classification
We demonstrate the Iris classification task. The inputs are four forces applied on four nodes from features of Iris flower. The outputs are displacements of three nodes and the node with largest horizontal displacement indicates the corresponding Iris flower.
