import OnnxRuntimeBindings
import Foundation
import CoreImage
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

/// Entrypoint into using the SwiftSegmentAnything package. Will load the models and provide inference capabilities.
public actor SwiftSegmentAnything {
    
    private var sessionPre: ORTSession?
    private var sessionSam: ORTSession?
    
    private var loadModelsTask: Task<Void, Error>?
    
    static var imageInputSize: (width: Int, height: Int) {
        return (width: 1024, height: 720)
    }
    
    private lazy var ortEnv: ORTEnv = {
        return try! ORTEnv(loggingLevel: ORTLoggingLevel.error)
    }()
    
    public init() {}
    
    // Generates an inference for a CGImage
    nonisolated public func inference(forCGImage: CGImage) throws -> SwiftSegmentAnythingInference {
        let ciImage = CIImage.init(cgImage: forCGImage)
        return inference(forCiImage: ciImage)
    }
    
    #if canImport(UIKit)
    /// Generates an inference for a UIImage
    nonisolated public func inference(forUiImage: UIImage) throws -> SwiftSegmentAnythingInference {
        guard let ciImage = CIImage.init(image: forUiImage) else {
            throw SwiftSegmentAnythingError.invalidImage
        }
        return inference(forCiImage: ciImage)
    }
    #endif
    
    /// Generates an inferences for a CIImage
    nonisolated public func inference(forCiImage: CIImage) -> SwiftSegmentAnythingInference {
        let inference = SwiftSegmentAnythingInference(ciImage: forCiImage, segmentAnyting: self)
        return inference
    }
    
    func sessionSam() async throws -> ORTSession {
        try await self.warmIfNeeded()
        guard let sessionSam else {
            throw SwiftSegmentAnythingError.internalError(description: "could not get session sam")
        }
        return sessionSam
    }
    
    func sessionPre() async throws -> ORTSession {
        try await self.warmIfNeeded()
        guard let sessionPre else {
            throw SwiftSegmentAnythingError.internalError(description: "could not get session pre")
        }
        return sessionPre
    }
    
    /// Loads the models from disk and configures the inference session.
    ///
    /// It is not required to call this method. It is implicitly called the first time when an inference is performed. However, calling this method ahead of time will improve the speed of the first inference that is performed.
    public func warmIfNeeded() async throws {
        if sessionPre != nil && sessionSam != nil {
            // no work to do, models already loaded
            return
        }
        if loadModelsTask == nil {
            // we need to actually load
            loadModelsTask = Task {
                try await loadModels()
            }
        }
        try await loadModelsTask?.value
    }
    
    private func loadModels() async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                try await self.loadPreModel()
            }
            group.addTask {
                try await self.loadSamModel()
            }
            try await group.waitForAll()
        }
    }
    
    private func loadPreModel() throws {
        let modelUrl = Bundle.module.url(forResource: "mobile_sam_preprocess", withExtension: "onnx")
        self.sessionPre = try self.loadModel(url: modelUrl)
    }
    
    private func loadSamModel() throws {
        let modelUrl = Bundle.module.url(forResource: "mobile_sam", withExtension: "onnx")
        self.sessionSam = try loadModel(url: modelUrl)
    }
    
    private func loadModel(url: URL?) throws -> ORTSession {
        guard let url else {
            throw SwiftSegmentAnythingError.internalError(description: "Could not pull model from bundle.")
        }
        let path = if #available(iOS 16.0, macOS 13.0, *) {
            url.path()
        } else {
            url.path
        }
        guard FileManager.default.fileExists(atPath: path) else {
            throw SwiftSegmentAnythingError.internalError(description: "Model file does not exist at \(path)")
        }
        let options = try ORTSessionOptions.init()
        try options.setLogID("onnx")
        try options.setLogSeverityLevel(.error)
        return try ORTSession(env: ortEnv, modelPath: path, sessionOptions: options)
    }
}
