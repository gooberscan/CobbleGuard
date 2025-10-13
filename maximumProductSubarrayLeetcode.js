var maxProduct = function(nums) {
    let maxProd = nums[0];
    let minProd = nums[0];
    let result = maxProd;
    
    for (let i = 1; i < nums.length; i++) {
        let tempMax = maxProd;
        maxProd = Math.max(nums[i], nums[i] * maxProd, nums[i] * minProd);
        minProd = Math.min(nums[i], nums[i] * tempMax, nums[i] * minProd);
        
        result = Math.max(result, maxProd);
    }
    
    return result;
};
