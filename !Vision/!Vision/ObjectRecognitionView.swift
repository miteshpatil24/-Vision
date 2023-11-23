import SwiftUI
import AVFoundation
import Vision
import CoreML

struct ObjectRecognitionView: View {
    @State private var isCameraActive = false
    @State private var detectedObjects: [String] = []
    @State private var objectRecognitionModel: ImageClassification?
    private func getModelConfiguration() -> MLModelConfiguration {
           let configuration = MLModelConfiguration()
           configuration.computeUnits = .cpuAndGPU
           return configuration
       }


    var body: some View {
        VStack {
            if isCameraActive {
                if let model = objectRecognitionModel {
                    CameraView(detectedObjects: $detectedObjects, model: model)
                        //.edgesIgnoringSafeArea(.all)
                } else {
                    Text("Error: Failed to initialize ObjectRecognitionModel")
                        .foregroundColor(.red)
                        .padding()
                }
                RectangleView(detectedObjects: $detectedObjects)
                    .padding()
            } else {
                Button("Start Camera") {
                    do {
                        objectRecognitionModel = try ImageClassification(configuration: getModelConfiguration())
                        isCameraActive.toggle()
                    } catch {
                        print("Error initializing ObjectRecognitionModel: \(error)")
                    }
                }
                .padding()
            }
            
            
            
        }
      
    }
                        
                   }
               
        
   

struct CameraView: UIViewControllerRepresentable {
    @Binding var detectedObjects: [String]
    var model: ImageClassification

    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var parent: CameraView
        var model: ImageClassification

        init(parent: CameraView, model: ImageClassification) {
            self.parent = parent
            self.model = model
        }

        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

            do {
                let model = try VNCoreMLModel(for: model.model)
                let request = VNCoreMLRequest(model: model) { (request, error) in
                    if let error = error {
                        print("Error performing vision request: \(error)")
                        return
                    }

                    guard let results = request.results as? [VNClassificationObservation], let firstResult = results.first else {
                        return
                    }

                    // Extract the recognized object and update the UI
                    DispatchQueue.main.async {
                        self.parent.detectedObjects = [firstResult.identifier]
                    }
                }

                try VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
            } catch {
                print("Error preparing vision request: \(error)")
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, model: model)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()

        // Configure the camera
        let captureSession = AVCaptureSession()

        guard let backCamera = AVCaptureDevice.default(for: .video) else { return viewController }

        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            captureSession.addInput(input)
        } catch {
            print("Error adding AVCaptureDeviceInput: \(error)")
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        viewController.view.layer.addSublayer(previewLayer)
        previewLayer.frame = viewController.view.layer.bounds

        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "cameraQueue"))

        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        DispatchQueue.global(qos: .userInitiated).async {
                captureSession.startRunning()
            }

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
       
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectRecognitionView()
    }
}

