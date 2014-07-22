import UIKit

struct Coordinate : Printable {
    let x: Int, y: Int, cell: UIView?

    init (x:Int, y:Int) {
        self.x = x
        self.y = y
    }
    
    init (x:Int, y:Int, cell: UIView) {
        self.x = x
        self.y = y
        self.cell = cell
    }
    
    func surroundings() -> [Coordinate] {
        let positions = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]
        
        return positions.map { position in Coordinate(x: self.x + position.0, y: self.y + position.1)
        }
    }
    
    func isNeighbor(candidate: Coordinate) -> Bool {
        switch (abs(x - candidate.x), abs(y - candidate.y)) {
        case (1,0), (1,1), (0,1): return true
        default: return false
        }
    }
   
    var description : String { return "\(x),\(y)" }
}

class ConwayEngine {
    
    class func _findNewCells(points: [Coordinate]) -> [Coordinate] {
        var candidates = Dictionary<String, Coordinate>(minimumCapacity: 10)
        
        for point in points {
            candidates[point.description] = point
        }
        
        for point in points {
            let surroundings = point.surroundings()
            for surroundingsPoint in surroundings {
                if !candidates[surroundingsPoint.description] {
                    candidates[surroundingsPoint.description] = surroundingsPoint
                }
            }
        }
        
        return Array(candidates.values)
    }
    
    class func iterate (points: [Coordinate]) -> (born: [Coordinate], die: [Coordinate]) {
        var born = Array<Coordinate>(),
            die = Array<Coordinate>()
        var newPoints = _findNewCells(points)
        for cell in newPoints {
            var count: Int = 0
            for candidate in points {
                candidate
                if cell.isNeighbor(candidate) {
                    count++
                }
            }
            if cell.cell {
                if count > 3  || count < 2 {
                    die.append(cell)
                }
            } else {
                if count == 3 {
                    born.append(cell)
                }
            }
        }
        return (born, die)
    }
}

class CellFactory {
    
    let cellSize: Int, canvasSize: Int
    
    var center:CGPoint {
        return CGPoint(x: canvasSize / 2, y: canvasSize / 2)
    }
    
    init (cellSize: Int, canvasSize: Int) {
        self.cellSize = cellSize
        self.canvasSize = canvasSize
    }
    
    func cellAtCoordinate(coordinate: Coordinate) -> UIView {
        var cell = UIView(frame: CGRect(x: Int(center.x) + cellSize * coordinate.x - cellSize / 2, y: Int(center.y) + cellSize * coordinate.y - cellSize/2, width: cellSize, height: cellSize))
        cell.backgroundColor = UIColor.blackColor()
        return cell
    }
    
    func coordinateOfCell(cell: UIView) -> Coordinate {
        let cellOrigin = cell.frame.origin,
        normalizedCenterOrigin = CGPointApplyAffineTransform(center, CGAffineTransformMakeTranslation(CGFloat(-cellSize/2), CGFloat(-cellSize/2)))
        return Coordinate(x:Int((cellOrigin.x - normalizedCenterOrigin.x) / CGFloat(cellSize)), y:Int((cellOrigin.y - normalizedCenterOrigin.y) / CGFloat(cellSize)), cell: cell)
    }
}


class World : UIView {
    
    let cellFactory = CellFactory(cellSize: 20, canvasSize: 200)
    
    init(initialState: [Coordinate]) {
        
        super.init(frame:CGRect(x:0, y:0, width:cellFactory.canvasSize, height:cellFactory.canvasSize))
        self.backgroundColor = UIColor.lightGrayColor()
        reset(initialState, die: [])
    }
    
    func reset (born: [Coordinate], die: [Coordinate]) {
        let newCells = born.map { cell in self.cellFactory.cellAtCoordinate(cell) }
        for cell in newCells {
            self.addSubview(cell)
        }
        
        for cell in die {
            if let c = cell.cell {
                c.removeFromSuperview()
            }
        }
    }

    func nextIteration () {
        let (born, die) = ConwayEngine.iterate(subviews.map { cell in self.cellFactory.coordinateOfCell(cell as UIView) })
        reset(born, die: die)
    }
}

let toad = [Coordinate(x:-1, y: 0), Coordinate(x:0, y: 0), Coordinate(x:1, y: 0), Coordinate(x:-2, y:1), Coordinate(x:-1, y:1), Coordinate(x:0, y:1)]
let blinker = [Coordinate(x:-1, y: 0), Coordinate(x:0, y: 0), Coordinate(x:1, y: 0)]
let beacon = [Coordinate(x:-2, y: -2), Coordinate(x:-1, y: -2), Coordinate(x:-2, y: -1), Coordinate(x:1, y: 1), Coordinate(x:0, y: 1), Coordinate(x:1, y: 0)]
let glider = [Coordinate(x:-2, y: 0), Coordinate(x:-1, y: 0), Coordinate(x:0, y: 0), Coordinate(x:0, y: -1), Coordinate(x:-1, y: -2)]

let world = World(initialState:toad)

for _ in 1 ... 4 {
    world
    world.nextIteration()
}
