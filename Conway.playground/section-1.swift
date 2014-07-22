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

    var dieAction: SKAction!, bornAction: SKAction!
    
    func cellAtCoordinate(coordinate: Point) -> SKSpriteNode {
        var cell = SKSpriteNode(color: NSColor(red:68/255.0, green:169/255.0, blue:157/255.0, alpha:0.9), size: CGSize(width: 1, height: 1))
        cell.position = CGPoint(x: Int(size.width) / 2 + coordinate.x, y: Int(size.height) / 2 + coordinate.y)
        return cell
    }
    
    override func didMoveToView(view: SKView!) {
        let transitionTime = 0.2
        
        dieAction = SKAction.sequence([
            SKAction.fadeOutWithDuration(transitionTime),
            SKAction.removeFromParent()
        ])
        
        bornAction = SKAction.fadeInWithDuration(transitionTime)
        
        addNodes((born:[Point(x:-2, y: 0), Point(x:-1, y: 0), Point(x:0, y: 0), Point(x:0, y: -1), Point(x:-1, y: -2)], die:[]))
        
        NSTimer.scheduledTimerWithTimeInterval(1.2, target: self, selector: Selector("next"), userInfo: nil, repeats: true)
    }
    
    func next() {
        self.addNodes(self.engine.iterate(Array(self.cells.keys)))
    }
    
    func addNodes(changes: (born:[Point], die:[Point])) {
        
        for point in changes.die {
            let cell = self.cells[point]!
            self.cells.removeValueForKey(point)
            cell.runAction(dieAction)
        }
        
        for point in changes.born {
            let cell = self.cellAtCoordinate(point)
            self.cells[point] = cell
            self.addChild(cell)
            cell.alpha = 0.0
            cell.runAction(bornAction)
        }
    }
}

//let blinker = [Point(x:-1, y: 0), Point(x:0, y: 0), Point(x:1, y: 0)]
//let beacon = [Point(x:-2, y: -2), Point(x:-1, y: -2), Point(x:-2, y: -1), Point(x:1, y: 1), Point(x:0, y: 1), Point(x:1, y: 0)]
//let glider = [Point(x:-2, y: 0), Point(x:-1, y: 0), Point(x:0, y: 0), Point(x:0, y: -1), Point(x:-1, y: -2)]

let view = SKView(frame: CGRect(x:0, y:0, width:200, height:200))
XCPShowView("View", view)

let world = World(size: CGSize(width:10, height:10))
world.backgroundColor = NSColor.whiteColor()
view.presentScene(world)

