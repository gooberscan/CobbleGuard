using System;
using System.Collections.Generic;

public class MinecraftSimulation
{
    const int WorldSize = 100;
    const int MaxHeight = 50;

    public enum BlockType { Air, Dirt, Stone, Grass, Water, Sand }

    private BlockType[,] world = new BlockType[WorldSize, WorldSize];

    private int dayCycle = 0;
    private const int DayLength = 24000;

    public class Player
    {
        public int X { get; set; } = 0;
        public int Y { get; set; } = 0;
        public int Z { get; set; } = 0;

        public void Move(int deltaX, int deltaY, int deltaZ)
        {
            X += deltaX;
            Y += deltaY;
            Z += deltaZ;
            Console.WriteLine($"Player moved to: ({X}, {Y}, {Z})");
        }

        public void InteractWithBlock(BlockType blockType)
        {
            Console.WriteLine($"Player interacted with a {blockType} block!");
        }
    }

    public MinecraftSimulation()
    {
        GenerateWorld();
    }

    private void GenerateWorld()
    {
        Random rand = new Random();
        for (int x = 0; x < WorldSize; x++)
        {
            for (int z = 0; z < WorldSize; z++)
            {
                int height = rand.Next(0, MaxHeight);
                for (int y = 0; y < MaxHeight; y++)
                {
                    if (y < height)
                    {
                        world[x, z] = BlockType.Dirt;
                    }
                    else if (y == height)
                    {
                        world[x, z] = BlockType.Grass;
                    }
                    else
                    {
                        world[x, z] = BlockType.Air;
                    }
                }
            }
        }
        Console.WriteLine("World generated!");
    }

    public void SimulateTime()
    {
        dayCycle++;
        if (dayCycle > DayLength)
        {
            dayCycle = 0;
        }

        string timeOfDay = dayCycle < 12000 ? "Day" : "Night";
        Console.WriteLine($"Current Time: {timeOfDay}");
    }

    public void PlayerAction(Player player, string action)
    {
        if (action == "move")
        {
            player.Move(1, 0, 0);
        }
        else if (action == "interact")
        {
            BlockType blockAtPlayer = world[player.X, player.Z];
            player.InteractWithBlock(blockAtPlayer);
        }
        else
        {
            Console.WriteLine("Unknown action");
        }
    }

    public void DisplayWorldState()
    {
        Console.WriteLine("World Snapshot:");
        for (int x = 0; x < WorldSize; x++)
        {
            for (int z = 0; z < WorldSize; z++)
            {
                string block = world[x, z].ToString().PadRight(6);
                Console.Write(block);
            }
            Console.WriteLine();
        }
    }

    public void RunSimulation()
    {
        Player player = new Player();
        int steps = 5;

        for (int i = 0; i < steps; i++)
        {
            SimulateTime();
            PlayerAction(player, "move");
            PlayerAction(player, "interact");
            DisplayWorldState();
            Console.WriteLine($"Simulation Step {i + 1} completed...\n");
        }
    }
}

public class Program
{
    public static void Main()
    {
        MinecraftSimulation simulation = new MinecraftSimulation();
        simulation.RunSimulation();
    }
}
