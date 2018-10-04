#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include "algos.h"

// static inline int32_t advanceUntil(const uint16_t *array, int32_t pos,
//                                    int32_t length, uint16_t min) {
//     int32_t lower = pos + 1;

//     if ((lower >= length) || (array[lower] >= min)) {
//         return lower;
//     }

//     int32_t spansize = 1;

//     while ((lower + spansize < length) && (array[lower + spansize] < min)) {
//         spansize <<= 1;
//     }
//     int32_t upper = (lower + spansize < length) ? lower + spansize : length - 1;

//     if (array[upper] == min) {
//         return upper;
//     }
//     if (array[upper] < min) {
//         // means
//         // array
//         // has no
//         // item
//         // >= min
//         // pos = array.length;
//         return length;
//     }

//     // we know that the next-smallest span was too small
//     lower += (spansize >> 1);

//     int32_t mid = 0;
//     while (lower + 1 != upper) {
//         mid = (lower + upper) >> 1;
//         if (array[mid] == min) {
//             return mid;
//         } else if (array[mid] < min) {
//             lower = mid;
//         } else {
//             upper = mid;
//         }
//     }
//     return upper;
// }

// int32_t intersect_skewed_uint16_cardinality(const uint16_t *small,
//                                             size_t size_s,
//                                             const uint16_t *large,
//                                             size_t size_l) {
//     size_t pos = 0, idx_l = 0, idx_s = 0;

//     if (0 == size_s) {
//         return 0;
//     }

//     uint16_t val_l = large[idx_l], val_s = small[idx_s];

//     while (true) {
//         if (val_l < val_s) {
//             idx_l = advanceUntil(large, (int32_t)idx_l, (int32_t)size_l, val_s);
//             if (idx_l == size_l) break;
//             val_l = large[idx_l];
//         } else if (val_s < val_l) {
//             idx_s++;
//             if (idx_s == size_s) break;
//             val_s = small[idx_s];
//         } else {
//             pos++;
//             idx_s++;
//             if (idx_s == size_s) break;
//             val_s = small[idx_s];
//             idx_l = advanceUntil(large, (int32_t)idx_l, (int32_t)size_l, val_s);
//             if (idx_l == size_l) break;
//             val_l = large[idx_l];
//         }
//     }

//     return (int32_t)pos;
// }

// int32_t intersect_uint16_cardinality(const uint16_t *A, const size_t lenA,
//                                      const uint16_t *B, const size_t lenB) {
//     int32_t answer = 0;
//     if (lenA == 0 || lenB == 0) return 0;
//     const uint16_t *endA = A + lenA;
//     const uint16_t *endB = B + lenB;

//     while (1) {
//         while (*A < *B) {
//         SKIP_FIRST_COMPARE:
//             if (++A == endA) return answer;
//         }
//         while (*A > *B) {
//             if (++B == endB) return answer;
//         }
//         if (*A == *B) {
//             ++answer;
//             if (++A == endA || ++B == endB) return answer;
//         } else {
//             goto SKIP_FIRST_COMPARE;
//         }
//     }
//     return answer;  // NOTREACHED
// }

// int32_t intersect_vector16_cardinality(const uint16_t *__restrict__ A,
//                                        size_t s_a,
//                                        const uint16_t *__restrict__ B,
//                                        size_t s_b) {
//     size_t count = 0;
//     size_t i_a = 0, i_b = 0;
//     const int vectorlength = sizeof(__m128i) / sizeof(uint16_t);
//     const size_t st_a = (s_a / vectorlength) * vectorlength;
//     const size_t st_b = (s_b / vectorlength) * vectorlength;
//     __m128i v_a, v_b;
//     if ((i_a < st_a) && (i_b < st_b)) {
//         v_a = _mm_lddqu_si128((__m128i *)&A[i_a]);
//         v_b = _mm_lddqu_si128((__m128i *)&B[i_b]);
//         while ((A[i_a] == 0) || (B[i_b] == 0)) {
//             const __m128i res_v = _mm_cmpestrm(
//                 v_b, vectorlength, v_a, vectorlength,
//                 _SIDD_UWORD_OPS | _SIDD_CMP_EQUAL_ANY | _SIDD_BIT_MASK);
//             const int r = _mm_extract_epi32(res_v, 0);
//             count += _mm_popcnt_u32(r);
//             const uint16_t a_max = A[i_a + vectorlength - 1];
//             const uint16_t b_max = B[i_b + vectorlength - 1];
//             if (a_max <= b_max) {
//                 i_a += vectorlength;
//                 if (i_a == st_a) break;
//                 v_a = _mm_lddqu_si128((__m128i *)&A[i_a]);
//             }
//             if (b_max <= a_max) {
//                 i_b += vectorlength;
//                 if (i_b == st_b) break;
//                 v_b = _mm_lddqu_si128((__m128i *)&B[i_b]);
//             }
//         }
//         if ((i_a < st_a) && (i_b < st_b))
//             while (true) {
//                 const __m128i res_v = _mm_cmpistrm(
//                     v_b, v_a,
//                     _SIDD_UWORD_OPS | _SIDD_CMP_EQUAL_ANY | _SIDD_BIT_MASK);
//                 const int r = _mm_extract_epi32(res_v, 0);
//                 count += _mm_popcnt_u32(r);
//                 const uint16_t a_max = A[i_a + vectorlength - 1];
//                 const uint16_t b_max = B[i_b + vectorlength - 1];
//                 if (a_max <= b_max) {
//                     i_a += vectorlength;
//                     if (i_a == st_a) break;
//                     v_a = _mm_lddqu_si128((__m128i *)&A[i_a]);
//                 }
//                 if (b_max <= a_max) {
//                     i_b += vectorlength;
//                     if (i_b == st_b) break;
//                     v_b = _mm_lddqu_si128((__m128i *)&B[i_b]);
//                 }
//             }
//     }
//     // intersect the tail using scalar intersection
//     while (i_a < s_a && i_b < s_b) {
//         uint16_t a = A[i_a];
//         uint16_t b = B[i_b];
//         if (a < b) {
//             i_a++;
//         } else if (b < a) {
//             i_b++;
//         } else {
//             count++;
//             i_a++;
//             i_b++;
//         }
//     }
//     return (int32_t)count;
// }


// bool intersect_skewed_uint16_nonempty(const uint16_t *small, size_t size_s,
//                                 const uint16_t *large, size_t size_l) {
//     size_t idx_l = 0, idx_s = 0;

//     if (0 == size_s) {
//         return false;
//     }

//     uint16_t val_l = large[idx_l], val_s = small[idx_s];

//     while (true) {
//         if (val_l < val_s) {
//             idx_l = advanceUntil(large, (int32_t)idx_l, (int32_t)size_l, val_s);
//             if (idx_l == size_l) break;
//             val_l = large[idx_l];
//         } else if (val_s < val_l) {
//             idx_s++;
//             if (idx_s == size_s) break;
//             val_s = small[idx_s];
//         } else {
//             return true;
//         }
//     }

//     return false;
// }


// bool intersect_uint16_nonempty(const uint16_t *A, const size_t lenA,
//                          const uint16_t *B, const size_t lenB) {
//     if (lenA == 0 || lenB == 0) return 0;
//     const uint16_t *endA = A + lenA;
//     const uint16_t *endB = B + lenB;

//     while (1) {
//         while (*A < *B) {
//         SKIP_FIRST_COMPARE:
//             if (++A == endA) return false;
//         }
//         while (*A > *B) {
//             if (++B == endB) return false;
//         }
//         if (*A == *B) {
//             return true;
//         } else {
//             goto SKIP_FIRST_COMPARE;
//         }
//     }
//     return false;  // NOTREACHED
// }