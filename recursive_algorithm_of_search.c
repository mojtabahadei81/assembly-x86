int binarySearch(int arr[], int l, int r, int x) { 
    if (r >= l) { 
        int mid = l + (r - l) / 2; 
        if (arr[mid] == x) 
            return mid; 
        if (arr[mid] > x) 
            return binarySearch(arr, l, mid - 1, x);  
        return binarySearch(arr, mid + 1, r, x); 
    } 
    return -1; 
}




static int insertSorted(int arr[], int n, int key, int capacity) {
	// Cannot insert more elements if n is already
	// more than or equal to capacity
	if (n >= capacity) {
		return n;
	}
	int i;
	for (i = n - 1; (i >= 0 && arr[i] > key); i--) {
		arr[i + 1] = arr[i];
	}
	arr[i + 1] = key;
	return (n + 1);
}



static int deleteElement(int arr[], int n, int key) {
	// Find position of element to be deleted
	int pos = binarySearch(arr, 0, n - 1, key);

	if (pos == -1) {
		System.out.println("Element not found");
		return n;
	}

	// Deleting element
	int i;
	for (i = pos; i < n - 1; i++)
		arr[i] = arr[i + 1];

	return n - 1;
}












