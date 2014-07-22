import SpriteKit
import XCPlayground

func ==(lhs:Point, rhs:Point) -> Bool{ return lhs.x == rhs.x && lhs.y == rhs.y }

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

class World : SKScene {
    let engine = ConwayRulesEngine()
    var cells = [Point: SKSpriteNode]()
    
//    func cellAtCoordinate(coordinate: Point) -> SKSpriteNode {
//        var cell = SKSpriteNode(color: UIColor.blackColor(), size: CGSize(width: 10, height: 10))
//        let point = CGPoint(x: Int(size.width) / 2 + coordinate.x, y: Int(size.height) / 2 + coordinate.y)
//        cell.position = point
//        return cell
//    }
//    
//    override func didMoveToView(view: SKView!) {
//        addNodes([Point(x:-1, y: 0), Point(x:0, y: 0), Point(x:1, y: 0), Point(x:-2, y:1), Point(x:-1, y:1), Point(x:0, y:1)])
//    }
//    
//    func removeNodes(points: [Point]) {
//        for point in points {
//            if let node = self.cells[point] {
//                self.removeChildrenInArray([node])
//                cells.removeValueForKey(point)
//            }
//        }
//    }
//    
//    func addNodes(points: [Point]) {
//        for point in points {
//            let view = cellAtCoordinate(point)
//            cells[point] = view
//            self.addChild(view)
//        }
//    }
//    
//    override func update(currentTime: NSTimeInterval) {
//
//    }
}

//let toad =
//let blinker = [Point(x:-1, y: 0), Point(x:0, y: 0), Point(x:1, y: 0)]
//let beacon = [Point(x:-2, y: -2), Point(x:-1, y: -2), Point(x:-2, y: -1), Point(x:1, y: 1), Point(x:0, y: 1), Point(x:1, y: 0)]
//let glider = [Point(x:-2, y: 0), Point(x:-1, y: 0), Point(x:0, y: 0), Point(x:0, y: -1), Point(x:-1, y: -2)]

let view = SKView(frame: CGRect(x:0, y:0, width:200, height:200))
XCPShowView("View", view)

let world = World(size: CGSize(width:200, height:200))
world.backgroundColor = UIColor.greenColor()
view.presentScene(world)

