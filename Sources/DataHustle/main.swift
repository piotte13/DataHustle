import croaring
import Foundation
import Dispatch
import Math

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
    try fd.createDirectory(atPath: url.deletingLastPathComponent().relativePath,withIntermediateDirectories: true, attributes: nil)
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

func getCPUModel() -> String {
    // Create a Task instance
    let task = Foundation.Process()

    // Set the task parameters
    task.launchPath = "/bin/bash"
    task.arguments = ["-c", "cat /proc/cpuinfo | grep 'model name' | sed -n 1p | cut -d ':' -f 2 | awk '{$1=$1};1' | tr -d '\n'"]
    
    // Create a Pipe and make the task
    // put all the output there
    let pipe = Pipe()
    task.standardOutput = pipe

    // Launch the task
    task.launch()
    
    // Get the data
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: String.Encoding.utf8)

    return output!
}

print("Loading data...")
var values = loadFolderIntoArrays(folderName: "realdata")
print("Done loading data...")

func buildDataset(algos: (inout [UInt16], inout [UInt16]) -> [UInt64], algoNames: String, filename: String){
    print("Building \(filename)...")
    var dataset = "range, n1 , average1, median1, std1, n2 , average2, median2, std2, "
    dataset += "\(algoNames)\n"
    writeToFile(data: dataset, fileName: filename, append: false)
    for i in 0..<(values.count - 1){
        dataset = ""
        /*************** Converting to UInt16 ***************/
        var v1: [UInt16] = []
        for j in 0..<values[i].count{
            if(values[i][j] > UInt16.max){
                v1.append(UInt16(values[i][j] >> 16))    
            }
            v1.append(UInt16(values[i][j] & 0xFFFF))
        }
        /****************************************************/ 
        let ld1 = v1.map { Double($0) }
        let a1 =  Math.average(ld1)!
        let m1 =  Math.median(ld1)!
        let s1 =  Math.standardDeviationPopulation(ld1)!
        for ii in 1..<(values.count){
            /*************** Converting to UInt16 ***************/
            var v2: [UInt16] = []
            for j in 0..<values[ii].count{
                if(values[ii][j] > UInt16.max){
                    v2.append(UInt16(values[ii][j] >> 16))
                }
                v2.append(UInt16(values[ii][j] & 0xFFFF))
            }
            /****************************************************/    
            let ld2 = v2.map { Double($0) }
            
            let rng = range(ld1, ld2)
            let a2 =  Math.average(ld2)!
            let m2 =  Math.median(ld2)!
            let s2 =  Math.standardDeviationPopulation(ld2)!

            let times = algos(&v1, &v2)
            dataset += "\(rng), \(ld1.count), \(a1), \(m1), \(s1), \(ld2.count), \(a2), \(m2), \(s2)"
            for t in times{
                dataset += ", \(t)"
            }
            dataset += "\n"
        }
        writeToFile(data: dataset, fileName: filename, append: true)
    }
}

func runIntersectAlgos(_ v1: inout [UInt16], _ v2: inout [UInt16]) -> [UInt64] {
    var times: [UInt64] = []
    let minCard = min([Double(v1.count), Double(v2.count)])
    let l1 = UnsafeMutablePointer<UInt16>(&v1)
    let l2 = UnsafeMutablePointer<UInt16>(&v2)
    let l3 = UnsafeMutablePointer<UInt16>.allocate(capacity: Int(minCard))

    var time = nanotime(block: {_ = croaring.intersect_skewed_uint16(l1, v1.count, l2, v2.count, l3)})
    times.append(time)

    time = nanotime(block: {_ = croaring.intersect_skewed_uint16(l2, v2.count, l1, v1.count, l3)})
    times.append(time)

    time = nanotime(block: {_ = croaring.intersect_uint16(l1, v1.count, l2, v2.count, l3)})
    times.append(time)

    l3.deallocate()
    return times
}

func runIntersectCardAlgos(_ v1: inout [UInt16], _ v2: inout [UInt16]) -> [UInt64] {
    var times: [UInt64] = []
    let l1 = UnsafeMutablePointer<UInt16>(&v1)
    let l2 = UnsafeMutablePointer<UInt16>(&v2)

    var time = nanotime(block: {_ = croaring.intersect_skewed_uint16_cardinality(l1, v1.count, l2, v2.count)})
    times.append(time)

    time = nanotime(block: {_ = croaring.intersect_skewed_uint16_cardinality(l2, v2.count, l1, v1.count)})
    times.append(time)

    time = nanotime(block: {_ = croaring.intersect_uint16_cardinality(l1, v1.count, l2, v2.count)})
    times.append(time)

    time = nanotime(block: {_ = croaring.intersect_vector16_cardinality(l1, v1.count, l2, v2.count)})
    times.append(time)

    return times
}

buildDataset(algos: runIntersectAlgos, algoNames: "skewed_1, skewed_2, non_skewed", filename: "\(getCPUModel())/Intersect_dataset")
buildDataset(algos: runIntersectCardAlgos, algoNames: "skewed_1, skewed_2, non_skewed, vector", filename: "\(getCPUModel())/Intersect_card_dataset")