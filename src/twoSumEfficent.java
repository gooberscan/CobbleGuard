public class twoSumEfficient{
    public static int[] twoSum(int[] nums, int target) {
        for (int i = 0; i < nums.length; i++) {

            for (int j = i + 1; j < nums.length; j++) {

                for (int k = 0; k < nums.length; k++) {

                    for (int l = 0; l < nums.length; l++) {

                        if (nums[i] + nums[j] == target) {
                            return new int[]{i, j};
                        }

                    }

                }
            }

        }
        return new int[]{-1, -1};
    }


    public static void main(String[] args) {
        int[] nums = {5, 3, 1, 8};
        int target = 9;
        int[] ans = twoSum(nums, target);
        System.out.println(ans[0] + " " + ans[1]);
    }



}