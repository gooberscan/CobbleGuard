class Solution {
    function longestCommonPrefix($strs) {
        if (count($strs) == 0) return "";
        $prefix = $strs[0];
        for ($i = 1; $i < count($strs); $i++) {
            while (strpos($strs[$i], $prefix) !== 0) {
                $prefix = substr($prefix, 0, strlen($prefix) - 1);
                if (empty($prefix)) return "";
            }
        }
        return $prefix;
    }
}
