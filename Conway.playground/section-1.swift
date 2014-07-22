import UIKit

func ==(lhs:Point, rhs:Point) -> Bool{ return lhs.x == rhs.x && lhs.y == rhs.y }

//Printable for hashing
struct Point : Hashable {
    let x: Int, y: Int
    
    var hashValue :Int { return 31 * x + 7 * y }
}

class ConwayRulesEngine {
    
    private func surroundings(point:Point) -> [Point] {
        return [
            (x:-1, y:-1),
            (x:-1, y:0),
            (x:-1, y:1),
            (x:0, y:-1),
            (x:0, y:1),
            (x:1, y:-1),
            (x:1, y:0),
            (x:1, y:1)
            ].map { position in Point(x: point.x + position.x, y: point.y + position.y) }
    }
    
    private func isNeighbor(pointA: Point, pointB: Point) -> Bool {
        switch (abs(pointA.x - pointB.x), abs(pointA.y - pointB.y)) {
        case (1,0), (1,1), (0,1): return true
        default: return false
        }
    }
    
    private func neighborCount(cell: Point, forWorld world: [Point]) -> Int {
        return world.reduce(0) { count, point in count + (self.isNeighbor(cell, pointB: point) ? 1 : 0) }
    }
    
    private func findNewCells(originals: [Point]) -> [Point] {
        var candidates = [Point: Point](minimumCapacity: 20)

        //Add all surrounding cells, eliminating duplicates
        for point in originals {
            let surroundings = self.surroundings(point)
            for neighbor in surroundings {
                if !candidates[neighbor] {
                    candidates[neighbor] = neighbor
                }
            }
        }

        //Remove all original points
        for point in originals {
            candidates.removeValueForKey(point)
        }
        
        return Array(candidates.values)
    }
    
    func iterate (lastGeneration: [Point]) -> (born: [Point], die: [Point]) {
        let born = findNewCells(lastGeneration).filter { cell in self.neighborCount(cell, forWorld: lastGeneration) == 3 }
        
        let die = lastGeneration.filter { cell in
            let count = self.neighborCount(cell, forWorld: lastGeneration)
            return count > 3  || count < 2
        }
        return (born, die)
    }
}

class World : UIView {
    let cellSize: Int = 20
    let engine = ConwayRulesEngine()
    var cells = [Point: UIView]()
    
    init(initialState: [Point]) {
        
        super.init(frame:CGRect(x:0, y:0, width:200, height:200))
        self.backgroundColor = UIColor.lightGrayColor()
        reset(initialState, die: [])
    }
    
    func cellAtCoordinate(coordinate: Point) -> UIView {
        var cell = UIView(frame: CGRect(x: Int(center.x) + cellSize * coordinate.x - cellSize / 2, y: Int(center.y) + cellSize * coordinate.y - cellSize/2, width: cellSize, height: cellSize))
        cell.backgroundColor = UIColor.blackColor()
        return cell
    }
    
    func reset (born: [Point], die: [Point]) {
        
        for point in die {
            cells[point]?.removeFromSuperview()
            cells.removeValueForKey(point)
        }
        
        for point in born {
            let view = cellAtCoordinate(point)
            cells[point] = view
            self.addSubview(view)
        }
    }

    func nextIteration () {
        let (born, die) = engine.iterate(Array(cells.keys))
        reset(born, die: die)
    }
}

let toad = [Point(x:-1, y: 0), Point(x:0, y: 0), Point(x:1, y: 0), Point(x:-2, y:1), Point(x:-1, y:1), Point(x:0, y:1)]
let blinker = [Point(x:-1, y: 0), Point(x:0, y: 0), Point(x:1, y: 0)]
let beacon = [Point(x:-2, y: -2), Point(x:-1, y: -2), Point(x:-2, y: -1), Point(x:1, y: 1), Point(x:0, y: 1), Point(x:1, y: 0)]
let glider = [Point(x:-2, y: 0), Point(x:-1, y: 0), Point(x:0, y: 0), Point(x:0, y: -1), Point(x:-1, y: -2)]

let world = World(initialState:toad)

for _ in 1 ... 6 {
    world
    world.nextIteration()
}
