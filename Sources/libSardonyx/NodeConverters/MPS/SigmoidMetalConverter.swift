class SigmoidMetalConverter: NodeConverter, FusableMetalNeuron {
    let node: Onnx_NodeProto
    var graphInputs: [String] { [self.node.input[0]] }
    var graphOutputs: [String] { [self.node.output[0]] }
    
    required init(node: Onnx_NodeProto) {
        self.node = node
    }
    
    func contributeProperties(using context: GenerationContext) {
        context.sourceBuilder.add(line: "let neuron_\(self.node.name): MPSCNNNeuron")
    }
    
    func contributeInit(using context: GenerationContext) {
        context.sourceBuilder.add(line: self.descriptor)
        context.sourceBuilder.add(line: "self.neuron_\(self.node.name) = \(self.neuron)")
        context.sourceBuilder.add(line: "self.neuron_\(self.node.name).destinationImageAllocator = MPSTemporaryImage.defaultAllocator()")
    }

    func contributeImplementation(using context: GenerationContext) {
        context.sourceBuilder.add(line: "let _\(self.output) = self.neuron_\(self.node.name).encode(commandBuffer: commandBuffer, sourceImage: _\(self.node.input[0]))")
    }
    
    var descriptor: String { "let neuronDescriptor_\(self.node.name) = MPSNNNeuronDescriptor.cnnNeuronDescriptor(with: .sigmoid)"}
    var neuron: String { "MPSCNNNeuron(device: device, neuronDescriptor: neuronDescriptor_\(self.node.name))" }
    var output: String { self.node.output[0] }
}
