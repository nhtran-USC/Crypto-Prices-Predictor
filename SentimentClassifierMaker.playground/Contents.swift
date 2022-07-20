import CreateML
import Foundation

// read into a data table instance

let baseUrl = "/Users/nguyentran/Documents/Summer_2022/Personal_Projects/Cryto_Price_Predictor/data/twitter-sanders-apple3.csv"

let data = try MLDataTable(contentsOf: URL(fileURLWithPath: baseUrl))

//let data = try MLDataTable(contentsOf:

let (trainingData, testingData) = data.randomSplit(by: 0.8, seed: 5)


let sentimentClassifier = try MLTextClassifier(trainingData: trainingData,
                                               textColumn: "text",
                                               labelColumn: "class")

// Training accuracy as a percentage
let trainingAccuracy = (1.0 - sentimentClassifier.trainingMetrics.classificationError) * 100

// Validation accuracy as a percentage
let validationAccuracy = (1.0 - sentimentClassifier.validationMetrics.classificationError) * 100


let evaluationMetrics = sentimentClassifier.evaluation(on: testingData, textColumn: "text", labelColumn: "class")

// Evaluation accuracy as a percentage
let evaluationAccuracy = (1.0 - evaluationMetrics.classificationError) * 100


let metadata = MLModelMetadata(author: "Nguyen Tran",
                               shortDescription: "A model trained to classify Twitter posts sentiment",
                               version: "1.0")

try sentimentClassifier.write(to: URL(fileURLWithPath: "/Users/nguyentran/Documents/Summer_2022/Personal_Projects/Cryto_Price_Predictor/data/"),
                              metadata: metadata)
