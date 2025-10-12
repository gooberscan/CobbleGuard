import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Stack;

public class Construction {
  public ArrayList<Instruction>[] blocks;
  public ArrayList<Integer>[] succ, pred;
  public int blockCount;
  private Instruction[] instructions;
  private ArrayList<Integer>[] domTree;
  private HashMap<Integer, Integer> labelMap;
  private HashSet<Integer>[] dom, df;
  private int[] idom;
  private HashSet<Integer> globals;
  private HashMap<Integer, HashSet<Integer>> associatedBlocks;
  private HashMap<Integer, Integer>[] phiMap;
  private HashMap<Integer, Stack<Integer>> versionStacks;
  private HashMap<Integer, Integer> newVersionTracker;

  public Construction(Instruction[] instructions) {
    this.instructions = new Instruction[instructions.length];
    for (int i = 0; i < instructions.length; i++) {
      this.instructions[i] = new Instruction(instructions[i]);
    }
  }

  public void construct() {
    createBlocks();
    createCFG();
    insertPhiNodes();
    renameVariables();
  }

  private void createBlocks() {
    int[] assignedBlocks = new int[instructions.length];
    int blockTracker = 1;
    for (int i = 0; i < instructions.length; i++) {
      if (instructions[i].operator == Operation.BR || instructions[i].operator == Operation.JMP) {
        assignedBlocks[i] = blockTracker++;
      } else if (instructions[i].operator == Operation.LABEL && i > 0) {
        if (instructions[i - 1].operator == Operation.LABEL
            || instructions[i - 1].operator == Operation.BR
            || instructions[i - 1].operator == Operation.JMP) {
          assignedBlocks[i] = blockTracker;
        } else {
          assignedBlocks[i] = ++blockTracker;
        }
      } else {
        assignedBlocks[i] = blockTracker;
      }
      blockCount = Math.max(blockCount, assignedBlocks[i] + 1);
    }
    blocks = new ArrayList[blockCount];
    Arrays.setAll(blocks, blank -> new ArrayList<>());
    labelMap = new HashMap<>();
    for (int i = 0; i < instructions.length; i++) {
      blocks[assignedBlocks[i]].add(instructions[i]);
      if (instructions[i].operator == Operation.LABEL) {
        labelMap.put(instructions[i].target.base, assignedBlocks[i]);
      }
    }
  }

  private void createCFG() {
    succ = new ArrayList[blockCount];
    Arrays.setAll(succ, blank -> new ArrayList<>());
    pred = new ArrayList[blockCount];
    Arrays.setAll(pred, blank -> new ArrayList<>());
    for (int x = 0; x < blockCount; x++) {
      if (blocks[x].isEmpty()) {
        if (x + 1 < blockCount) {
          succ[x].add(x + 1);
          pred[x + 1].add(x);
        }
        continue;
      }
      if (blocks[x].getLast().operator == Operation.BR) {
        int y1 = labelMap.get(blocks[x].getLast().arguments[1].base);
        int y2 = labelMap.get(blocks[x].getLast().arguments[2].base);
        succ[x].add(y1);
        succ[x].add(y2);
        pred[y1].add(x);
        pred[y2].add(x);
      } else if (blocks[x].getLast().operator == Operation.JMP) {
        int y = labelMap.get(blocks[x].getLast().arguments[0].base);
        succ[x].add(y);
        pred[y].add(x);
      } else if (x + 1 < blockCount) {
        succ[x].add(x + 1);
        pred[x + 1].add(x);
      }
    }
  }

  private void findDominators() {
    dom = new HashSet[blockCount];
    Arrays.setAll(dom, blank -> new HashSet<>());
    dom[0].add(0);
    for (int x = 1; x < blockCount; x++) {
      for (int i = 0; i < blockCount; i++) {
        dom[x].add(i);
      }
    }
    boolean changed = true;
    while (changed) {
      changed = false;
      for (int x = 0; x < blockCount; x++) {
        HashSet<Integer> tempSet = new HashSet<>(dom[x]);
        for (int y : pred[x]) {
          tempSet.retainAll(dom[y]);
        }
        tempSet.add(x);
        if (!dom[x].equals(tempSet)) {
          dom[x] = tempSet;
          changed = true;
        }
      }
    }
  }

  private void findImmediateDominators() {
    findDominators();
    idom = new int[blockCount];
    idom[0] = -1;
    for (int x = 1; x < blockCount; x++) {
      for (int y : pred[x]) {
        if (dom[y].size() + 1 == dom[x].size()) {
          idom[x] = y;
          break;
        }
      }
    }
  }

  private void findDominanceFrontiers() {
    findImmediateDominators();
    df = new HashSet[blockCount];
    Arrays.setAll(df, blank -> new HashSet<>());
    for (int x = 0; x < blockCount; x++) {
      for (int y : pred[x]) {
        int runner = y;
        while (runner != idom[x]) {
          df[runner].add(x);
          runner = idom[runner];
        }
      }
    }
  }

  private void findGlobalVariables() {
    globals = new HashSet<>();
    associatedBlocks = new HashMap<>();
    for (int x = 0; x < blockCount; x++) {
      HashSet<Integer> killed = new HashSet<>();
      for (Instruction instruction : blocks[x]) {
        for (Operand argument : instruction.arguments) {
          if (argument.isVariable() && !killed.contains(argument.base)) {
            globals.add(argument.base);
          }
        }
        if (instruction.hasTarget()) {
          killed.add(instruction.target.base);
          associatedBlocks
              .computeIfAbsent(instruction.target.base, blank -> new HashSet<>())
              .add(x);
        }
      }
    }
  }

  private void insertPhiNodes() {
    findDominanceFrontiers();
    findGlobalVariables();
    phiMap = new HashMap[blockCount];
    Arrays.setAll(phiMap, blank -> new HashMap<>());
    for (int variable : globals) {
      ArrayDeque<Integer> queue = new ArrayDeque<>(associatedBlocks.get(variable));
      while (!queue.isEmpty()) {
        int x = queue.poll();
        for (int y : df[x]) {
          if (phiMap[y].containsKey(variable)) {
            continue;
          }
          Operand[] arguments = new Operand[pred[y].size()];
          Arrays.setAll(arguments, blank -> new Operand(variable));
          Instruction inserted = new Instruction(Operation.PHI, new Operand(variable), arguments);
          // Just to ensure that the phi functions don't come before
          // labels, as when we convert back, the phi functions are
          // turned into useful copy operations.
          int firstNonLabel = 0;
          while (firstNonLabel < blocks[y].size()
              && blocks[y].get(firstNonLabel).operator == Operation.LABEL) {
            firstNonLabel++;
          }
          int insertIndex = phiMap[y].size() + firstNonLabel;
          blocks[y].add(insertIndex, inserted);
          phiMap[y].put(variable, insertIndex);
          if (!associatedBlocks.get(variable).contains(y)) {
            associatedBlocks.get(variable).add(y);
            queue.add(y);
          }
        }
      }
    }
  }

  private void createDominatorTree() {
    domTree = new ArrayList[blockCount];
    Arrays.setAll(domTree, blank -> new ArrayList<>());
    for (int x = 1; x < blockCount; x++) {
      domTree[idom[x]].add(x);
    }
  }

  private void renameVariables() {
    createDominatorTree();
    versionStacks = new HashMap<>();
    newVersionTracker = new HashMap<>();
    recRenameVariables(0);
  }

  private void recRenameVariables(int x) {
    HashMap<Integer, Integer> popCount = new HashMap<>();
    for (Instruction instruction : blocks[x]) {
      if (instruction.operator != Operation.PHI) {
        for (Operand argument : instruction.arguments) {
          if (argument.isVariable()) {
            argument.version = versionStacks.get(argument.base).peek();
          }
        }
      }
      if (instruction.hasTarget() && instruction.target.isVariable()) {
        int base = instruction.target.base;
        int version = newVersionTracker.getOrDefault(base, -1) + 1;
        instruction.target.version = version;
        newVersionTracker.put(base, version);
        versionStacks.computeIfAbsent(base, blank -> new Stack<>()).add(version);
        popCount.merge(base, 1, Integer::sum);
      }
    }
    for (int y : succ[x]) {
      for (int variable : phiMap[y].keySet()) {
        int backEdgeIndex = pred[y].indexOf(x);
        int instructionIndex = phiMap[y].get(variable);
        blocks[y].get(instructionIndex).arguments[backEdgeIndex].version =
            versionStacks.get(variable).peek();
      }
    }
    for (int y : domTree[x]) {
      recRenameVariables(y);
    }
    for (int variable : popCount.keySet()) {
      for (int y = 0; y < popCount.get(variable); y++) {
        versionStacks.get(variable).pop();
      }
    }
  }
}
