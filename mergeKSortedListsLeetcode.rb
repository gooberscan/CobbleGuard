def mergeKLists(lists)
  return nil if lists.nil? || lists.empty?
  
  while lists.length > 1
    merged = []
    lists.each_slice(2) do |a, b|
      merged.push(mergeTwoLists(a, b))
    end
    lists = merged
  end
  lists[0]
end

def mergeTwoLists(l1, l2)
  dummy = ListNode.new
  current = dummy
  while l1 && l2
    if l1.val < l2.val
      current.next = l1
      l1 = l1.next
    else
      current.next = l2
      l2 = l2.next
    end
    current = current.next
  end
  current.next = l1 || l2
  dummy.next
end
