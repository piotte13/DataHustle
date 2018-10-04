// import algos
import croaring
import Foundation
import Dispatch
func nanotime(block: () -> Void) -> UInt64 {
            let t1 = DispatchTime.now()
            block()
            let t2 = DispatchTime.now()
            let delay = t2.uptimeNanoseconds - t1.uptimeNanoseconds
            return delay
    }

func max(_ values: [Double]) -> Double {
    if let maxValue = values.max() {
      return maxValue
    }
    
    return 0
  }
  
func min(_ values: [Double]) -> Double {
    if let minValue = values.min() {
      return minValue
    }
    
    return 0
}

func sum(_ values: [Double]) -> Double {
    return values.reduce(0, +)
}

func range(_ values1: [Double], _ values2: [Double]) -> Double{
    var mx = max(values1)
    var mn = min(values1)
    if (mx < max(values2)){
        mx = max(values2)
    }
    if (mn > min(values2)){
        mn = min(values2)
    }
    return mx - mn
}

func sort(_ values: [Double]) -> [Double] {
    return values.sorted { $0 < $1 }
}

func average(_ values: [Double]) -> Double? {
    let count = Double(values.count)
    if count == 0 { return nil }
    return sum(values) / count
  }

func variancePopulation(_ values: [Double]) -> Double? {
    let count = Double(values.count)
    if count == 0 { return nil }
    
    if let avgerageValue = average(values) {
      let numerator = values.reduce(0) { total, value in
        total + pow(avgerageValue - value, 2)
      }
      
      return numerator / count
    }
    
    return nil
}

func standardDeviationPopulation(_ values: [Double]) -> Double? {
    if let variancePopulation = variancePopulation(values) {
      return sqrt(variancePopulation)
    }
    
    return nil
}

func median(_ values: [Double]) -> Double? {
    let count = Double(values.count)
    if count == 0 { return nil }
    let sorted = sort(values)
    
    if count.truncatingRemainder(dividingBy: 2) == 0 {
      // Even number of items - return the mean of two middle values
      let leftIndex = Int(count / 2 - 1)
      let leftValue = sorted[leftIndex]
      let rightValue = sorted[leftIndex + 1]
      return (leftValue + rightValue) / 2
    } else {
      // Odd number of items - take the middle item.
      return sorted[Int(count / 2)]
    }
}

func centralMoment(_ values: [Double], order: Int) -> Double? {
    let count = Double(values.count)
    if count == 0 { return nil }
    guard let averageVal = average(values) else { return nil }
    
    let total = values.reduce(0) { sum, value in
      sum + pow((value - averageVal), Double(order))
    }
    
    return total / count
}

func skewness(_ values: [Double]) -> Double? {
    if values.count < 3 { return nil }
    guard let stdDev = standardDeviationPopulation(values) else { return nil }
    if stdDev == 0 { return nil }
    guard let moment3 = centralMoment(values, order: 3) else { return nil }
    
    return moment3 / pow(stdDev, 3)
}

func loadFolderIntoArrays(folderName: String) -> [[Int]] {
    //Load files into arrays
    let fd = FileManager.default
    let currentPath = fd.currentDirectoryPath
    return loadFolderIntoArrays(absolutePath: currentPath + "/" + folderName)
}

func loadFolderIntoArrays(absolutePath: String) -> [[Int]] {
    //Load files into arrays
    let fd = FileManager.default
    var numbers: [[Int]] = []
    fd.enumerator(atPath: absolutePath)?.forEach({ (e) in
        if let e = e as? String, let url = URL(string: e) {
            do {
                let file = try String(contentsOfFile: absolutePath + "/" + url.path)
                let list: [String] = file.components(separatedBy: ",")
                let l = list.map { Int($0.trimmingCharacters(in: .whitespacesAndNewlines))! }
                numbers.append(l)
            } catch {
                //Swift.print("Fatal Error: Couldn't read the contents!")
            }
        }
    })
    return numbers
}

func writeToFile(data: String, fileName: String, append: Bool){
    let fd = FileManager.default
    let currentPath = fd.currentDirectoryPath
    let url = URL(fileURLWithPath: "\(currentPath)/Results/\(fileName).csv")
    do{
    try fd.createDirectory(atPath: "\(currentPath)/Results/",withIntermediateDirectories: true, attributes: nil)
    } catch {
        print("Error: \(error.localizedDescription)")
    }
    //writing
    if append , let fileHandle = FileHandle(forWritingAtPath: url.path)  {
        fileHandle.seekToEndOfFile()
        let dta = data.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        fileHandle.write(dta)
    } else {
        print(url.absoluteURL)
        do{
            try data.write(to: url, atomically: false, encoding: .utf8)
        }
        catch{
            print("ERROR: Failed attempt at writing to file!")
            }
    }
        
}
print("Loading data...")
var values = loadFolderIntoArrays(folderName: "realdata")
print("Done loading data...")
func buildDataset(algo: (UnsafePointer<UInt16>, size_t, UnsafePointer<UInt16>, size_t) -> Int32, paramsInverted: Bool, filename: String){
    print("Building \(filename)...")
    var dataset = "range, n1 , average1, median1, std1, n2 , average2, median2, std2, time\n"
    writeToFile(data: dataset, fileName: filename, append: false)
    for i in 0..<(values.count - 1){
        dataset = ""
        for ii in 1..<(values.count){
            /*************** Converting to UInt16 ***************/
            var v1: [UInt16] = []
            var v2: [UInt16] = []
            for j in 0..<values[i].count{
                if(values[i][j] <= UInt16.max){
                    v1.append(UInt16(values[i][j]))
                }
            }
            for j in 0..<values[ii].count{
                if(values[ii][j] <= UInt16.max){
                    v2.append(UInt16(values[ii][j]))
                }
            }
            /****************************************************/
            // let l1 = UnsafeMutablePointer<UInt16>.allocate(capacity:v1.count)
            // for j in 0..<v1.count{
            //     l1[j] = v1[j]
            // }
            // let l2 = UnsafeMutablePointer<UInt16>.allocate(capacity:v2.count)
            // for j in 0..<v2.count{
            //     l2[j] = v2[j]
            // }
            let l1 = UnsafeMutablePointer<UInt16>(&v1)
            let l2 = UnsafeMutablePointer<UInt16>(&v2)

            let ld1 = v1.map { Double($0) }
            let ld2 = v2.map { Double($0) }
            if(ld1.count == 0 || ld2.count == 0){
                continue
            }
            let rng = range(ld1, ld2)
            let a1 =  average(ld1)!
            let a2 =  average(ld2)!
            let m1 =  median(ld1)!
            let m2 =  median(ld2)!
            let s1 =  standardDeviationPopulation(ld1)!
            let s2 =  standardDeviationPopulation(ld2)!
            //let sk1 = skewness(ld1)!
            //let sk2 = skewness(ld2)!
            var time: UInt64 = 0
            if(paramsInverted){
                time = nanotime(block: {_ = algo(l2, v2.count, l1, v1.count)})
            }
            else{
                time = nanotime(block: {_ = algo(l1, v1.count, l2, v2.count)})
            }

            dataset += "\(rng), \(ld1.count), \(a1), \(m1), \(s1), \(ld2.count), \(a2), \(m2), \(s2), \(time)\n"
        }
        writeToFile(data: dataset, fileName: filename, append: true)
    }
}

buildDataset(algo: croaring.intersect_skewed_uint16_cardinality, paramsInverted: false, filename: "dataset_skewed_1")
buildDataset(algo: croaring.intersect_skewed_uint16_cardinality, paramsInverted: true, filename: "dataset_skewed_2")
buildDataset(algo: croaring.intersect_uint16_cardinality, paramsInverted: false, filename: "dataset_non_skewed")
buildDataset(algo: croaring.intersect_vector16_cardinality, paramsInverted: false, filename: "dataset_vector")
