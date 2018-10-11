import Foundation
import Dispatch

public func max(_ values: [Double]) -> Double {
    if let maxValue = values.max() {
      return maxValue
    }
    
    return 0
}
  
public func min(_ values: [Double]) -> Double {
    if let minValue = values.min() {
      return minValue
    }
    
    return 0
}

public func sum(_ values: [Double]) -> Double {
    return values.reduce(0, +)
}

public func range(_ values1: [Double], _ values2: [Double]) -> Double{
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

public func sort(_ values: [Double]) -> [Double] {
    return values.sorted { $0 < $1 }
}

public func average(_ values: [Double]) -> Double? {
    let count = Double(values.count)
    if count == 0 { return nil }
    return sum(values) / count
}

public func variancePopulation(_ values: [Double]) -> Double? {
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

public func standardDeviationPopulation(_ values: [Double]) -> Double? {
    if let variancePopulation = variancePopulation(values) {
      return sqrt(variancePopulation)
    }
    
    return nil
}

public func median(_ values: [Double]) -> Double? {
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

public func centralMoment(_ values: [Double], order: Int) -> Double? {
    let count = Double(values.count)
    if count == 0 { return nil }
    guard let averageVal = average(values) else { return nil }
    
    let total = values.reduce(0) { sum, value in
      sum + pow((value - averageVal), Double(order))
    }
    
    return total / count
}

public func skewness(_ values: [Double]) -> Double? {
    if values.count < 3 { return nil }
    guard let stdDev = standardDeviationPopulation(values) else { return nil }
    if stdDev == 0 { return nil }
    guard let moment3 = centralMoment(values, order: 3) else { return nil }
    
    return moment3 / pow(stdDev, 3)
}

public func nanotime(block: () -> Void) -> UInt64 {
    let t1 = DispatchTime.now()
    block()
    let t2 = DispatchTime.now()
    let delay = t2.uptimeNanoseconds - t1.uptimeNanoseconds
    return delay
}