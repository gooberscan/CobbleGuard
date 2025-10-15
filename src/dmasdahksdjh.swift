import Foundation

class MinecraftSimulation {
    enum BlockType: String {
        case air = "Air"
        case dirt = "Dirt"
        case stone = "Stone"
        case grass = "Grass"
        case water = "Water"
        case sand = "Sand"
    }

    let worldSize = 100
    let maxHeight = 50
    let dayLength = 24000
    var dayCycle = 0

    var world: [[BlockType]] = []

    class Player {
        var x = 0
        var y = 0
        var z = 0

        func move(deltaX: Int, deltaY: Int, deltaZ: Int) {
            x += deltaX
            y += deltaY
            z += deltaZ
            print("Player moved to: (\(x), \(y), \(z))")
        }

        func interactWith(block: BlockType) {
            print("Player interacted with a \(block.rawValue) block!")
        }
    }

    init() {
        generateWorld()
    }

    func generateWorld() {
        var newWorld: [[BlockType]] = Array(
            repeating: Array(repeating: .air, count: worldSize),
            count: worldSize
        )

        for x in 0..<worldSize {
            for z in 0..<worldSize {
                let height = Int.random(in: 0..<maxHeight)
                for y in 0..<maxHeight {
                    if y < height {
                        newWorld[x][z] = .dirt
                    } else if y == height {
                        newWorld[x][z] = .grass
                    } else {
                        newWorld[x][z] = .air
                    }
                }
            }
        }

        world = newWorld
        print("World generated!")
    }

    func simulateTime() {
        dayCycle += 1
        if dayCycle > dayLength {
            dayCycle = 0
        }

        let timeOfDay = dayCycle < 12000 ? "Day" : "Night"
        print("Current Time: \(timeOfDay)")
    }

    func playerAction(player: Player, action: String) {
        if action == "move" {
            player.move(deltaX: 1, deltaY: 0, deltaZ: 0)
        } else if action == "interact" {
            let x = max(0, min(worldSize - 1, player.x))
            let z = max(0, min(worldSize - 1, player.z))
            let block = world[x][z]
            player.interactWith(block: block)
        } else {
            print("Unknown action")
        }
    }

    func displayWorldState() {
        print("World Snapshot:")
        for x in 0..<worldSize {
            for z in 0..<worldSize {
                let block = world[x][z]
                let padded = block.rawValue.padding(toLength: 6, withPad: " ", startingAt: 0)
                print(padded, terminator: "")
            }
            print()
        }
    }

    func runSimulation() {
        let player = Player()
        let steps = 5

        for i in 1...steps {
            simulateTime()
            playerAction(player: player, action: "move")
            playerAction(player: player, action: "interact")
            displayWorldState()
            print("Simulation Step \(i) completed...\n")
        }
    }
}

let simulation = MinecraftSimulation()
simulation.runSimulation()
