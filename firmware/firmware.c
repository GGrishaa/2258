#include <stdint.h>

#define GPIO_BASE 0x10010000
#define GPIO_OUT *(volatile uint32_t *)GPIO_BASE

void *memcpy(void *dest, const void *src, unsigned int n) {
    char *d = (char *)dest;
    const char *s = (const char *)src;
    while (n--) *d++ = *s++;
    return dest;
}

void *memset(void *s, int c, unsigned int n) {
    char *p = (char *)s;
    while (n--) *p++ = (char)c;
    return s;
}

void write_gpio(uint32_t val) {
    GPIO_OUT = val;
}

void swap(int* a, int* b) {
    int t = *a;
    *a = *b;
    *b = t;
}

int partition(int arr[], int low, int high) {
    int pivot = arr[high];
    int i = (low - 1);
    for (int j = low; j <= high - 1; j++) {
        if (arr[j] < pivot) {
            i++;
            swap(&arr[i], &arr[j]);
        }
    }
    swap(&arr[i + 1], &arr[high]);
    return (i + 1);
}

void quicksort(int arr[], int low, int high) {
    if (low < high) {
        int pi = partition(arr, low, high);
        quicksort(arr, low, pi - 1);
        quicksort(arr, pi + 1, high);
    }
}

int main() {
    int arr[] = {34, 7, 25, 12, 22, 11, 90, 8, 5, 64};
    int n = sizeof(arr) / sizeof(arr[0]);
    int i;

    write_gpio(111);
    write_gpio(222);

    quicksort(arr, 0, n - 1);

    for (i = 0; i < n; i++) {
        write_gpio(arr[i]);
    }

    while (1) { ; }
    return 0;
}