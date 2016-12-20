// Battleship

typealias Distance = Double

struct Position {
    var x: Double
    var y: Double
}

extension Position {
    func inRange(range: Distance) -> Bool {
        return (x * x + y * y).squareRoot() <= range
    }
}

extension Position {
    func minus(p: Position) -> Position {
        return Position(x: x - p.x, y: y - p.y)
    }
    var length: Double {
        return (x * x + y * y).squareRoot()
    }
}

struct Ship {
    var position: Position
    var firingRange: Distance
    var unsafeRange: Distance
}

typealias Region = (Position) -> Bool

func circle(radius: Distance) -> Region {
    return { point in point.length <= radius }
}

func circle2(radius: Distance, center: Position) -> Region {
    return { point in point.minus(p: center).length <= radius }
}

func shift(region: @escaping Region, offset: Position) -> Region {
    return { point in region(point.minus(p: offset)) }
}
shift(region: circle(radius: 10), offset: Position(x: 5, y: 5))

func invert(region: @escaping Region) -> Region {
    return { point in !region(point) }
}

func intersection(region1: @escaping Region, region2: @escaping Region) -> Region {
    return { point in region1(point) && region2(point) }
}

func union(region1: @escaping Region, region2: @escaping Region) -> Region {
    return { point in region1(point) || region2(point) }
}

func difference(region: @escaping Region, minus: @escaping Region) -> Region {
    return intersection(region1: region, region2: invert(region: minus))
}

extension Ship {
    func canSafelyEngageShip(target: Ship, friendly: Ship) -> Bool {
        let rangeRegion = difference(region: circle(radius: firingRange), minus: circle(radius: unsafeRange))
        let firingRegion = shift(region: rangeRegion, offset: position)
        let friendlyRegion = shift(region: circle(radius: unsafeRange), offset: friendly.position)
        let resultRegion = difference(region: firingRegion, minus: friendlyRegion)
        return resultRegion(target.position)
    }
}

