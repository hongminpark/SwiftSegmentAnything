import Foundation
import CoreImage
import OnnxRuntimeBindings
import CoreImage.CIFilterBuiltins

private func arrayCopiedFromData<T>(_ data: Data) -> [T]? {
  guard data.count % MemoryLayout<T>.stride == 0 else { return nil }
  return data.withUnsafeBytes { bytes -> [T] in
    return Array(bytes.bindMemory(to: T.self))
  }
}

/// An instance of an inference to Segment Anything on a given image.
public actor SwiftSegmentAnythingInference {
    
    private let segmentAnything: SwiftSegmentAnything
    private let ciImage: CIImage
    
    private var proprocessTask: Task<ORTValue, Error>?
    
    init(ciImage: CIImage, segmentAnyting: SwiftSegmentAnything) {
        self.segmentAnything = segmentAnyting
        self.ciImage = ciImage
    }
    
    public func warm() async throws {
        let _ = try await self.proprocessIfNeeded()
    }
    
    public func getMask(includePoints: [CGPoint] = [], includeBoxes: [CGRect] = [], excludePoints: [CGPoint] = []) async throws -> SwiftSegmentAnythingMask {
        guard !includeBoxes.isEmpty || !includePoints.isEmpty || !excludePoints.isEmpty else {
            throw SwiftSegmentAnythingError.noInput
        }
        let inputSize = SwiftSegmentAnything.imageInputSize
        let preprocessedData = try await self.proprocessIfNeeded()
        let sessionSam = try await segmentAnything.sessionSam()
        var pointCoords = [Float32]()
        let scaleX = Double(inputSize.width) / ciImage.extent.width
        let scaleY = Double(inputSize.height) / ciImage.extent.height
        for point in includePoints {
            pointCoords.append(Float32(point.x * scaleX))
            pointCoords.append(Float32(point.y * scaleY))
        }
        for point in excludePoints {
            pointCoords.append(Float32(point.x * scaleX))
            pointCoords.append(Float32(point.y * scaleY))
        }
        var pointLabels = [Float32]()
        for _ in includePoints {
            pointLabels.append(1)
        }
        for _ in excludePoints {
            pointLabels.append(0)
        }
        if includeBoxes.isEmpty {
            // include the padding point
            pointCoords.append(0)
            pointCoords.append(0)
            pointLabels.append(-1)
        } else {
            for box in includeBoxes {
                pointCoords.append(Float32(box.minX * scaleX))
                pointCoords.append(Float32(box.minY * scaleY))
                pointLabels.append(2)
                pointCoords.append(Float32(box.maxX * scaleX))
                pointCoords.append(Float32(box.maxY * scaleY))
                pointLabels.append(3)
            }
        }
        let pointData = pointCoords.toData()
        let ortPointData = try ORTValue(tensorData: NSMutableData(data: pointData), elementType: .float, shape: [1, NSNumber(value: pointCoords.count / 2), 2])
        let pointLabelData = pointLabels.toData()
        let ortPointLabels = try ORTValue(tensorData: NSMutableData(data: pointLabelData), elementType: .float, shape: [1, NSNumber(value: pointLabels.count)])
        let hasMask: Float = 0
        let hasMaskBytes = withUnsafeBytes(of: hasMask, Array.init)
        let hasMaskData = Data(hasMaskBytes)
        let ortHasMask = try ORTValue(tensorData: NSMutableData(data: hasMaskData), elementType: .float, shape: [1])
        let origImSizeData = [ // H,W format per docs
            Float(inputSize.height),
            Float(inputSize.width)
        ].toData()
        let ortOrigImSize = try ORTValue(tensorData: NSMutableData(data: origImSizeData), elementType: .float, shape: [2])
        let mask = [Float32].init(repeating: 0, count: 256 * 256).toData()
        let ortMask = try ORTValue(tensorData: NSMutableData(data: mask), elementType: .float, shape: [1, 1, 256, 256])
        let inputs = [
            "image_embeddings": preprocessedData,
            "point_coords": ortPointData,
            "point_labels": ortPointLabels,
            "has_mask_input": ortHasMask,
            "orig_im_size": ortOrigImSize,
            "mask_input": ortMask
        ]
        let outputMasksMutbleData = NSMutableData(length: 1024 * 720 * 4 * 4)! // * 4 for float
        let outputMasks = try ORTValue(tensorData: outputMasksMutbleData, elementType: .float, shape: [1, 4, 720, 1024])
        try sessionSam.run(withInputs: inputs, outputs: [
            "masks": outputMasks
        ], runOptions: nil)
        let typeAndShape = try outputMasks.tensorTypeAndShapeInfo()
        let tensorData = try outputMasks.tensorData()
        let maskOutputWidth = typeAndShape.shape[2].intValue
        let maskOutputHeight = typeAndShape.shape[3].intValue
        var numOver = 0
        var numUnder = 0
        guard let cArr: [Float32] = arrayCopiedFromData(tensorData as Data) else {
            throw SwiftSegmentAnythingError.internalError(description: "failed to copy output data")
        }
        var writingPixelBuffer: CVPixelBuffer? = nil
        let writingPixelBufferCreateStatus = CVPixelBufferCreate(kCFAllocatorDefault, maskOutputHeight, maskOutputWidth, kCVPixelFormatType_OneComponent32Float, nil, &writingPixelBuffer)
        guard writingPixelBufferCreateStatus == kCVReturnSuccess else {
            throw SwiftSegmentAnythingError.internalError(description: "could not create pixel buffer for writing")
        }
        guard let writingPixelBuffer else {
            throw SwiftSegmentAnythingError.internalError(description: "pixel buffer was nil")
        }
        CVPixelBufferLockBaseAddress(writingPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        guard let buffer = CVPixelBufferGetBaseAddress(writingPixelBuffer) else {
            throw SwiftSegmentAnythingError.internalError(description: "could not get px base address")
        }
        let writingPxBytesPerRow = CVPixelBufferGetBytesPerRow(writingPixelBuffer)
        let writingPxBytesPerPixel = 4
        var testFloats = [Float32]()
        for i in 0..<1024 {
            for j in 0..<720 {
                let value = cArr[(j * 1024) + i]
                let pixelBufferAddr = buffer.advanced(by: (j * writingPxBytesPerRow) + (i * writingPxBytesPerPixel))
                testFloats.append(value)
                    if value > 0 {
                        numOver += 1
                        pixelBufferAddr.storeBytes(of: 1, as: Float.self)
                    } else {
                        numUnder += 1
                        pixelBufferAddr.storeBytes(of: 0, as: Float.self)
                    }
            }
        }
        CVPixelBufferUnlockBaseAddress(writingPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let outputMask = CIImage(cvPixelBuffer: writingPixelBuffer)
        guard let resizedOutput = outputMask.resized(toWidth: Int(self.ciImage.extent.width), height: Int(self.ciImage.extent.height)) else {
            throw SwiftSegmentAnythingError.internalError(description: "could not undo scale")
        }
        return resizedOutput
    }
    
    private func taskValue() async throws -> ORTValue {
        let sessionPre = try await segmentAnything.sessionPre()
        
        let inputSize = SwiftSegmentAnything.imageInputSize
        guard let ciImage: CIImage = self.ciImage.resized(toWidth: inputSize.width, height: inputSize.height) else {
            throw SwiftSegmentAnythingError.internalError(description: "could not resize an image")
        }
        let context = CIContext()
//        guard let cgImage = context.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: ciImage.extent.width, height: ciImage.extent.height)) else {
//            throw SwiftSegmentAnythingError.internalError(description: "could not create image")
//        }
        
        var inputTensorValues = [UInt8](repeating: 0, count: inputSize.width * inputSize.height * 3)

        
        var inputPixelBuffer: CVPixelBuffer?
        let inputPixelBufferStatus = CVPixelBufferCreate(kCFAllocatorDefault, 1024, 720, kCVPixelFormatType_32ARGB, nil, &inputPixelBuffer)
        guard inputPixelBufferStatus == kCVReturnSuccess, let inputPixelBuffer else {
            throw SwiftSegmentAnythingError.internalError(description: "could not create input pixel buffer")
        }
        context.render(ciImage, to: inputPixelBuffer)
        
        CVPixelBufferLockBaseAddress(inputPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        guard let buffer = CVPixelBufferGetBaseAddress(inputPixelBuffer)?.assumingMemoryBound(to: UInt8.self) else {
            throw SwiftSegmentAnythingError.internalError(description: "could not get px base address")
        }
        
        let maxI = 720
        let maxJ = 1024
        
        let writingPxBytesPerRow = CVPixelBufferGetBytesPerRow(inputPixelBuffer)
        let writingPxBytesPerPixel = 4

        for i in 0..<maxI {
            for j in 0..<maxJ {
                let lookupIdx = 0 //Int((i * maxJ) + j)
                let pixelBufferAddr = buffer.advanced(by: (Int(i) * writingPxBytesPerRow) + (Int(j) * writingPxBytesPerPixel))
                let r = pixelBufferAddr.advanced(by: lookupIdx + 1).pointee
                let g = pixelBufferAddr.advanced(by: lookupIdx + 2).pointee
                let b = pixelBufferAddr.advanced(by: lookupIdx + 3).pointee
                let bIdx = Int(2 * maxI * maxJ + i * maxJ + j)
                inputTensorValues[Int((i * maxJ) + j)] = b
                inputTensorValues[Int(maxI * maxJ + i * maxJ + j)] = g
                inputTensorValues[bIdx] = r
            }
        }
        
        CVPixelBufferUnlockBaseAddress(inputPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        let tensorData = Data(inputTensorValues)
        let inputValue = try ORTValue(
            tensorData: NSMutableData(data: tensorData),
            elementType: .uInt8,
            shape: [1, 3, NSNumber(value: inputSize.height), NSNumber(value: inputSize.width)]
        )
        
        let outputs = try sessionPre.run(withInputs: ["input": inputValue], outputNames: ["output"], runOptions: nil)
        guard let outputOrtValue = outputs["output"] else {
            throw SwiftSegmentAnythingError.preprocessingFailed
        }
        
        return outputOrtValue
    }
    
    private func proprocessIfNeeded() async throws -> ORTValue {
        if let existingPreprocessTask = self.proprocessTask {
            return try await existingPreprocessTask.value
        }
        let newTask = Task {
            return try await self.taskValue()
        }
        self.proprocessTask = newTask
        return try await newTask.value
    }
}
